module main

import cli { Command, Flag }
import os
import os.cmdline
import v.pref
import v.util.recompilation

fn main() {
	cmd := Command {
		name: 'self'
		description: 'Run V self-compiler'
		execute: self_fn
	}
	cmd.parse(os.args)
}

fn self_fn(cmd Command) {
	vexe := pref.vexe_path()
	vroot := os.dir(vexe)

	recompilation.must_be_enabled(vroot, 'Please install V from source, to use \'v self\'.')

	os.chdir(vroot)
	os.setenv('VCOLORS', 'always', true)

	println('V self compiling...')

	build_flags := cmd.args.join(' ')
	cmd := '${vexe} build ${build_flags} cmd/v'
	compile(vroot, cmd)
	backup_old_version_and_rename_newer() or { panic(err) }

	println('V build successfully.')
}

fn compile(vroot string, cmd string) {
	result := os.exec(cmd) or { panic(err) }
	if result.exit_code != 0 {
		eprintln('cannot compile to `$vroot`: \n$result.output')
		exit(1)
	}
	if result.output.len > 0 {
		println(result.output.trim_space())
	}
}

fn backup_old_version_and_rename_newer() ? {
	v_file := if os.user_os() == 'windows' { 'v.exe' } else { 'v' }
	v2_file := if os.user_os() == 'windows' { 'v2.exe' } else { 'v2' }
	bak_file := if os.user_os() == 'windows' { 'v_old.exe' } else { 'v_old' }
	if os.exists(bak_file) {
		os.rm(bak_file) ?
	}
	os.mv(v_file, bak_file) ?
	os.mv(v2_file, v_file) ?
}
