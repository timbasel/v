module main

import os
import cli { Command, Flag }
import v.util

fn main() {
	mut v_cmd := Command{
		name: 'V',
		description: 'V is a tool for managing V source code.'
		version: util.full_v_version(true)
		// sort_commands: false
		execute: main_func
	}

	v_cmd.add_flag(Flag {
		flag: .bool
		name: 'verbose'
		description: 'Set the verbosity of the output.'
		abbrev: 'v'
		global: true
	})

	v_cmd.add_command(init_cmd())
	v_cmd.add_command(exec_cmd())
	/*
	v_cmd.add_commands([
		tool_cmd('fmt', 'Format the V code provided.')
		tool_cmd('vet' , 'Reports suspicious code constructs in code provided.')
		tool_cmd('up', 'Format the V code provided.')
		tool_cmd('self', 'Run the V-self-compiler, use -prod to optimize compilation.')
		tool_cmd('tracev', 'Run the V-self-compiler, use -prod to optimize compilation.') // TODO: just trace?
	])
	*/

	v_cmd.parse(os.args)
}

/*
fn tool_cmd(name string, description string) Command {
	return Command {
		name: name, 
		description: description,
		execute: fn(cmd Command) {
			is_verbose := cmd.flags.get_bool('verbose') or { false }
			util.launch_tool(is_verbose, 'v' + cmd.name, cmd.args)
		}
	}
}
*/

fn main_func(cmd Command) {
	if cmd.args.len > 0 {
		if tool_exists(cmd.args[0]) {
			mut args := ['v']
			args << cmd.args
			exec_cmd().parse(args)
			return
		}
	}
	println('not found')
}
