module main

import cli { Command, Flag }
import os
import v.pref


fn exec_cmd() &Command {
 	return &Command {
		name: 'exec',
		// Comment
		usage: '<tool>'
		description: 'Execute a tool defined in your project.'
		execute: exec_fn,
		// Comment
		flags: [
			Flag {
				flag: .string
				name: 'recompile'
				abbrev: 'r'
				description: 'Force the tool to be recompiled.'
			}
		]
	}
}

fn exec_fn(cmd Command)? {
	// Comment
	is_verbose := cmd.flags.get_bool('verbose') or { false }
	force_recompile := cmd.flags.get_bool('recompile') or { false }

	if cmd.args.len < 1 {
		println('no tool provided')
		return
	}


	tool := cmd.args[0]
	tool_args := escape_args(cmd.args[1..])
	tool_source, tool_exe := find_tool(tool) or {
		println('error: ${err}')
		return
	}

	if is_verbose {
		println('found tool \'${tool}\' in \'${tool_source}\'')
	}

	should_compile := force_recompile || should_compile_tool(tool_source, tool_exe)
	if should_compile {
		// TODO(timbasel): install external modules if required

		// TODO?: recompile using the builder api
		v_exe := pref.vexe_path()
		compile_cmd := '${v_exe} ${tool_source}'
		if is_verbose {
			println('compiling tool \'${tool}\': \'${compile_cmd}\'')
		}

		compile_result := os.execute_or_panic(compile_cmd)
		if compile_result.exit_code != 0 {
			println('error: failed to compile \'${tool}\': \n${compile_result.output}')
		}
	}
	
	tool_cmd := '${tool_exe} ${tool_args}'
	if is_verbose {
		println('executing tool \'${tool}\': ${tool_cmd}')
	}
	exit(os.system(tool_cmd))
}

fn find_tool(tool string) ?(string, string) {
	project_path := find_vmod_path(os.getwd()) or {
		return error('no V project found.')
	}

	mut tool_source := os.real_path(os.join_path(project_path, 'tools', tool))
	mut tool_exe := ''
	if os.is_dir(tool_source) {
		tool_exe = os.real_path(os.join_path(tool_source, to_executable(tool)))
	} else if os.is_file(tool_source + '.v') {
		tool_exe = os.real_path(to_executable(tool_source))
		tool_source = tool_source + '.v'
	} else {
		return error('no tool named \'${tool}\' found')
	}
	return tool_source, tool_exe
}

fn tool_exists(tool string) bool {
	find_tool(tool) or {
		return false
	}
	return true
}

fn find_vmod_path(path string) ?string {
	content := os.ls(path) or { return err }

	if content.contains('v.mod') {
		return path
	} else if path == '' {
		return error("no v.mod found")
	} else {
		return find_vmod_path(os.dir(path))
	}
}

fn to_executable(name string) string {
	$if windows {
		return name + '.exe'
	}
	return name
}

fn should_compile_tool(tool_source string, tool_exe string) bool {
	if !os.exists(tool_exe) {
		return true
	}

	if os.is_dir(tool_source) {
		files := os.walk_ext(tool_source, '.v')
		mut newest_file := ''
		mut newest_file_last_mod := 0

		for file in files {
			last_mod := os.file_last_mod_unix(file)
			if last_mod > newest_file_last_mod {
				newest_file = file
				newest_file_last_mod = last_mod
			}
		}
		return should_compile_tool(newest_file, tool_exe) // determine recompile based on newest file
	}

	v_exe_last_mod := os.file_last_mod_unix(pref.vexe_path())
	tool_exe_last_mod := os.file_last_mod_unix(tool_exe)
	tool_source_last_mod := os.file_last_mod_unix(tool_source)

	mut should_compile := false
	if tool_exe_last_mod <= v_exe_last_mod {
		// v was recompiled after last tool compilation
		should_compile = true
	}
	if tool_exe_last_mod <= tool_source_last_mod {
		// tool source changed after last tool compilation
		should_compile = true
	}
	if v_exe_last_mod < 1024 && tool_exe_last_mod < 1024 {
		// GNU Guix and possibly other environments, have bit for bit reproducibility in mind,
		// including filesystem attributes like modification times, so they set the modification
		// times of executables to a small number like 0, 1 etc. In this case, we should not
		// recompile even if other heuristics say that we should. Users in such environments,
		// have to explicitly compile their tools, using `v build $project/tools/$tool`
		should_compile = false
	}

	return should_compile
}

fn escape_arg(arg string) string {
	mut escaped := arg
	escaped = escaped.replace('&', '\\&')
	if escaped.contains(' ') {
		return '"${escaped}"'
	}
	return escaped
}

fn escape_args(args []string) string {
	mut result := []string{}
	for arg in args {
		result << escape_arg(arg)
	}
	return result.join(' ')
}
