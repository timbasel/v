module main

import cli { Command }

import v.builder

fn run_cmd() &Command {
	return &Command {
		name: 'run'
		usage: '<file|directory> [arguments...]'
		description: 'Builds and executes the provided V file/module.'
		execute: run_fn,
		flags: build_flags,
	}
}

fn run_fn(cmd Command) {
	if cmd.args.len < 1 {
		println('error: no v files provided')
	}

	mut prefs := parse_build_flags(cmd.args[0], cmd.flags)
	prefs.is_run = true

	builder.compile(cmd.args[0], prefs)
}