module main

import cli { Command }

fn run_cmd() Command {
	return Command {
		name: 'run'
		usage: '<file|directory> [arguments...]'
		description: 'Builds and executes the provided V file/module'
		execute: run_fn,
	}
}

fn run_fn(cmd Command) {
	// TODO(timbasel) implement run functionality
	println('V RUN')
}