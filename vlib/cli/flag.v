module cli

type FlagType = []bool | []f64 | []int | []string | bool | f64 | int | string

pub enum FlagKind {
	bool
	int
	float
	string
	int_array
	float_array
	string_array
}

// Flag holds information for a command line flag.
// (flags are also commonly referred to as "options" or "switches")
// These are typically denoted in the shell by a short form `-f` and/or a long form `--flag`
[heap]
pub struct Flag {
pub mut:
	kind        FlagKind [required]
	name        string
	aliases     []string
	abbrev      string
	description string
	global      bool
	required    bool
	default     FlagType
mut:
	value FlagType
	found bool
}

fn (flag &Flag) value_undefined() bool {
	return flag.value.type_name().split(' ')[0] == 'unknown'
}

fn (flag &Flag) default_undefined() bool {
	return flag.default.type_name().split(' ')[0] == 'unknown'
}

fn (mut flag Flag) setup() {
	if !flag.default_undefined() {
		flag.value = flag.default
	} else {
		match flag.kind {
			.bool { flag.value = false }
			.int { flag.value = 0 }
			.float { flag.value = 0.0 }
			.string { flag.value = '' }
			.int_array { flag.value = []int{} }
			.float_array { flag.value = []f64{} }
			.string_array { flag.value = []string{} }
		}
	}
}

fn (flags []&Flag) setup() {
	for i in 0 .. flags.len {
		mut flag := flags[i]
		if flag.value_undefined() {
			flag.setup()
		}
	}
}

// parses the value as the specified flag type and returns the number of parsed arguments
fn (mut flag Flag) parse(args []string) ?int {
	match flag.kind {
		.bool { flag.parse_bool(args[0]) ? }
		.int { flag.parse_int(args[0]) ? }
		.float { flag.parse_float(args[0]) ? }
		.string { flag.parse_string(args[0]) ? }
		.int_array { return flag.parse_int_array(args) }
		.float_array { return flag.parse_float_array(args) }
		.string_array { return flag.parse_string_array(args) }
	}
	return 1
}

fn (flags []&Flag) parse(args []string, strict bool) ?int {
	if args.len == 0 {
		return error('cli error: no arguments given to parse')
	}
	flags.setup()

	split := args[0].split_nth('=', 2)
	mut arg := split[0]

	if arg.starts_with('--') { // long flag
		mut flag := flags.get(arg[2..]) or { // `flag`
			flags.get(arg) or { // `--flag`
				if !strict {
					return 0 // skip undefined flag
				}
				return error('cli error: no flag `$arg` found')
			}
		}
		flag.found = true

		if split.len == 2 {
			// --flag=value
			flag.parse([split[1]]) ?
		} else if flag.kind == .bool {
			// --flag
			flag.parse(['true']) ?
		} else if args.len >= 2 {
			// --flag arg0 arg1 ...
			return flag.parse(args[1..])
		} else {
			return error('cli error: flag `$flag.name` requires an argument value')
		}
		return 0
	} else if arg.starts_with('-') {
		if flags.contains(arg) { // custom flag
			mut flag := flags.get(arg) or { // `-flag`
				panic('cli error: failed to get command `$arg` that should exist')
			}
			flag.found = true

			if split.len == 2 {
				// -flag=value
				flag.parse([split[1]]) ?
			} else if flag.kind == .bool {
				// -flag
				flag.parse(['true']) ?
			} else if args.len >= 2 {
				// -flag arg0 arg1 ...
				return flag.parse(args[1..])
			} else {
				return error('cli error: flag `$flag.name` requires an argument value')
			}
			return 0
		} else { // short flag
			arg = args[0][1..] // trim leading `-`

			mut flag := flags.get_abbrev(arg[0..1]) or {
				if !strict {
					return 0 // skip undefined flag
				}
				return error('cli error: no flag `$arg` found')
			}
			flag.found = true

			if arg.len > 2 && arg[1] == `=` {
				// -f=value
				flag.parse([arg[2..]]) ?
			} else if flag.kind == .bool {
				// -f
				flag.parse(['true']) ?
				arg = arg[1..]

				for arg.len > 0 { // parse combined boolean flags
					flag = flags.get_abbrev(arg[0..1]) or {
						if !strict {
							return 0 // skip undefined flag
						}
						return error('cli error: no flag `$arg` found')
					}
					if flag.kind != .bool {
						return error('cli error: can not combine non boolean flags')
					}
					flag.found = true
					flag.parse(['true']) ?
					arg = arg[1..]
				}
			} else if args.len >= 2 {
				// -f value
				return flag.parse(args[1..])
			} else if arg.len > 1 {
				// -fvalue
				flag.parse([arg[1..]]) ?
			} else {
				return error('cli error: flag `$flag.name` (abbrev: `$flag.abbrev`) requires an argument value')
			}
		}
	}
	return 0
}

fn (flags []&Flag) get(name string) ?&Flag {
	for flag in flags {
		if flag.name == name {
			return flag
		}
	}
	return error('cli error: no flag `$name` found')
}

fn (flags []&Flag) get_abbrev(abbrev string) ?&Flag {
	if abbrev == '' {
		return error('cli error: no abbrev given.')
	}

	for flag in flags {
		if flag.abbrev == abbrev {
			return flag
		}
	}
	return error('cli error: no flag `$abbrev` found')
}

fn (flags []&Flag) contains(name string) bool {
	flags.get(name) or { return false }
	return true
}

fn (flags []&Flag) contains_abbrev(abbrev string) bool {
	flags.get_abbrev(abbrev) or { return false }
	return true
}
