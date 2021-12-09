module main

import cli { Command, Flag }
import os
import time

fn main() {
	// define a root command
	mut cmd := &Command{
		name: 'git'
	}
	// add a flag to root command
	quiet_flag := cmd.add_flag(&Flag{
		kind: .bool
		name: 'quiet'
		description: 'Only print error messages'
		abbrev: 'q'
		global: true // flag is added to all subcommands
		default: false // default value of the flag
	})

	// add a subcommand to the root command
	cmd.add_command(&Command{
		name: 'init'
		usage: '<directory>' // description of argumemnt usage
		description: 'Initializes a new repository'
		execute: fn (cmd &Command) ? { // you can use either named or anonymous functions for `execute`
			quiet := cmd.flags.get_bool('quiet') ? // get global flag
			if cmd.args.len < 1 {
				return error('cli error: directory argument required')
			}
			if !quiet {
				println('Initializes new repository in ${cmd.args[0]}')
				// ...
			}
		}
	})
	// NOTE: for more complex CLIs it can be helpful to split the command creation into seperate functions
	cmd.add_command(add_cmd())
	cmd.add_command(commit_cmd())

	start := time.now()

	// Parse arguments and if a matching command is found its execute function is called
	cmd.parse(os.args) or {
		println(err)
		exit(1)
	}

	// you can access the value of the flags after `cmd.parse` is called
	quiet := quiet_flag.get_bool() or { panic(err) }
	if !quiet {
		println('\nExecution Time: ${f64(time.since(start).microseconds()) / 1000}ms')
	}
}

fn add_cmd() &Command {
	mut add_cmd := &Command{
		name: 'add'
		usage: '<path>...'
		description: 'Add file contents to the index'
		execute: add_fn
	}
	return add_cmd
}

fn add_fn(cmd &Command) ? {
	if cmd.args.len < 1 {
		return error('cli error: `$cmd.name` does require at least one path argument')
	}
	for arg in cmd.args {
		println('$arg added')
	}
	// ...
}

// Flags can also be defined as an annotated struct
struct CommitFlags {
	amend   bool   [cli.aliases: 'fixup,reword']
	message string [cli.abbrev: 'm']
	// ...
}

fn commit_cmd() &Command {
	mut commit_cmd := &Command{
		name: 'commit'
		usage: '<path>...'
		description: 'Record changes to the repository'
		execute: commit_fn
	}
	// add flags in struct to the command
	commit_cmd.add_flag_struct<CommitFlags>()
	return commit_cmd
}

fn commit_fn(cmd &Command) ? {
	flags := cmd.flags.get_struct<CommitFlags>() ?

	if flags.amend {
		println('Amend commit: \'$flags.message\'...')
	} else {
		println('Commit: \'$flags.message\'')
	}
	// ...
}
