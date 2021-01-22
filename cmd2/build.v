module main

import cli { Command, Flag }
import os

import v.pref
import v.builder

fn build_cmd() &Command {
	return &Command {
		name: 'build'
		usage: '[build flags] <file|directory> [arguments...]'
		description: 'Builds the provided target and its dependencies into an executable.'
		execute: build_fn
		flags: build_flags
	}
}

const build_flags = [
	Flag {
		flag: .string
		name: 'output'
		abbrev: 'o'
		description: 'Specify output location for executable.'
	},
	Flag {
		flag: .string
		name: 'backend'
		abbrev: 'b'
		description: 'Specify the compiler backend used to build the exectutable (currently supported: `c` | `js` | `x64`).'
	},
	Flag {
		flag: .bool
		name: 'debug'
		abbrev: 'd'
		description: 'Builds executable in debug mode.'
	},
	Flag {
		flag: .bool
		name: 'production'
		abbrev: 'prod' 
		description: 'Builds executable in production mode. Optimizations are enabled. Warnings will be treated as errors.'
	},
	Flag {
		flag: .bool
		name: 'obfuscate'
		abbrev: 'obf'
		description: 'Enables obfuscation of executable (currently only renames symbols)'
	},
	Flag {
		flag: .bool
		name: 'apk'
		description: 'Builds executable in Android .apk format'
	}
	Flag {
		flag: .bool
		name: 'show-timings'
		description: 'Outputs the time each compiler stage took'
	}
	Flag {
		flag: .bool
		name: 'check-syntax'
		description: 'Only scan and parse source files, and not produce an executable'
	}
	Flag {
		flag: .bool
		name: 'silent'
		description: 'Hides output from the compiler'
	}
	Flag {
		flag: .bool
		name: 'repl'
		description: 'Lauches the V REPL (read-eval-print loop)'
	}

]

fn build_fn(cmd Command) {
	if cmd.args.len < 1 {
		println('error: no file/module provided.')
	}

	pref := parse_build_flags(cmd.args[0], cmd.flags)
	println(pref.is_prod)
	builder.compile(cmd.args[0], pref)
}

fn parse_build_flags(path string, flags []Flag) &pref.Preferences {
	mut prefs := &pref.Preferences{}
	$if x64 {
		prefs.m64 = true
	}
	prefs.path = path

	prefs.fill_with_defaults()

	for flag in flags.get_all_found() {
		match flag.name {
			'apk' { 
				prefs.is_apk = true
			}
			'show-timings' {
				prefs.show_timings = true
			}
			'check-syntax' {
				prefs.only_check_syntax = true
			}
			'Winpure-v' {
				prefs.warn_impure_v = true
			}
			'Wfatal-errors' {
				prefs.fatal_errors = true
			}
			'silent' {
				prefs.output_mode = .silent
			}
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
			'production' {
				prefs.is_prod = true
			}
			'obfuscate' {
				prefs.obfuscate = true
			}
			'verbose' {
				prefs.is_verbose = true
			}
			// TODO(timbasel): add remaining options
			else {
				panic("flag ${flag.name} is not handled")
			}
		}
	}
	return prefs
}
