module main

import cli { Command }

fn fmt_cmd() &Command {
	return &Command {
		name: 'fmt'
		usage: '<file|directory>'
		description: 'Formats the provided V code.'
		execute: fmt_fn
	}
}

fn fmt_fn(cmd Command)? {
	
}