module main

import cli { Command, Flag }
import os

fn main() {
	mut cmd := &Command{
		name: 'cli'
		description: 'An example of the cli library.'
		version: '1.0.0'
	}

	mut greet_cmd := &Command{
		name: 'greet'
		description: 'Prints greeting in different languages.'
		usage: '<name>'
		required_args: 1
		execute: greet_func
	}

	greet_cmd.add_flag(&Flag{
		flag: .string
		required: true
		name: 'language'
		abbrev: 'l'
		description: 'Language of the message.'
	})
	greet_cmd.add_flag(&Flag{
		flag: .int
		name: 'times'
		default_value: ['3']
		description: 'Number of times the message gets printed.'
	})
	greet_cmd.add_flag(&Flag{
		flag: .string_array
		name: 'fun'
		description: 'Just a dumby flags to show multiple.'
	})

	cmd.add_command(mut greet_cmd)
	cmd.parse(os.args)
}

fn greet_func(cmd &Command) ? {
	language := cmd.flags.get_string('language') or { panic('Failed to get `language` flag: $err') }
	times := cmd.flags.get_int('times') or { panic('Failed to get `times` flag: $err') }
	name := cmd.args[0]

	for _ in 0 .. times {
		match language {
			'english', 'en' {
				println('Welcome $name')
			}
			'german', 'de' {
				println('Willkommen $name')
			}
			'dutch', 'nl' {
				println('Welkom $name')
			}
			else {
				println('Unsupported language')
				println('Supported languages are `english`, `german` and `dutch`.')
				break
			}
		}
	}

	fun := cmd.flags.get_strings('fun') or { panic('Failed to get `fun` flag: $err') }
	for f in fun {
		println('fun: $f')
	}
}
