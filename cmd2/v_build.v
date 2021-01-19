module main

import cli { Command, Flag }
import os

import v.pref

fn build_cmd() Command {
	mut build_cmd := Command {
		name: 'build'
		usage: '[build flags] <file|directory> [arguments...]'
		description: 'Builds the provided target and its dependencies into an executable.'
		execute: build_fn,
	}

	build_cmd.add_flags(build_flags())

	return build_cmd
}

fn build_fn(cmd Command) {
	// TODO(timbasel) implement build functionality
	println('V BUILD')
}

fn build_flags() []Flag {
	mut flags := []Flag{}

	flags << Flag {
		flag: .string
		name: 'output'
		abbrev: 'o'
		description: 'Specify output location for executable.'
	}
	flags << Flag {
		flag: .string
		name: 'backend'
		abbrev: 'b'
		description: 'Specify the compiler backend used to build the exectutable (currently supported: `c` | `js` | `x64`).'
	}
	flags << Flag {
		flag: .bool
		name: 'debug'
		abbrev: 'd'
		description: 'Builds executable in debug mode.'
	}
	flags << Flag {
		flag: .bool
		name: 'production'
		abbrev: 'prod' 
		description: 'Builds executable in production mode. Optimizations are enabled. Warnings will be treated as errors.'
	}
	flags << Flag {
		flag: .bool
		name: 'obfuscate'
		abbrev: 'obf'
		description: 'Enables obfuscation of executable (currently only renames symbols)'
	}
	// TODO(timbasel): add remaining options

	return flags
}

fn parse_build_flags(flags []Flag) pref.Preferences {
	mut prefs := pref.new_preferences()

	for flag in flags.get_all_found() {
		match flag.name {
			'output' {
				prefs.out_name = flag.get_string() or { '' }
				if prefs.out_name.ends_with('.js') {
					prefs.backend = .js
				}
				if !os.is_abs_path(prefs.out_name) {
					prefs.out_name = os.join_path(os.getwd(), prefs.out_name)
				}
			}
			'backend' { 
				backend := flag.get_string() or { 'c' }
				prefs.backend = pref.backend_from_string(backend) or { panic(err) }
			}
			'debug' {
				prefs.is_debug = true
				prefs.is_vlines = false
			}
			'production' { prefs.is_prod = true }
			'obfuscate' { prefs.obfuscate = true }
			// TODO(timbasel): add remaining options
			else {
				panic("flag ${flag.name} is not handled")
			}
		}
	}
	return prefs
}