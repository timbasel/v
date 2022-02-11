module cli

type FlagValue = []f64 | []int | []string | bool | f64 | int | string

fn (value &FlagValue) str() string {
	match value {
		bool { return value.str() }
		int { return value.str() }
		f64 { return value.str() }
		string { return value }
		[]int { return value.str() }
		[]f64 { return value.str() }
		[]string { return value.str() }
	}
}

fn (value &FlagValue) undefined() bool {
	return value.type_name().split(' ')[0] == 'unknown'
}

fn (value &FlagValue) to_kind() FlagKind {
	match value {
		bool { return .bool }
		int { return .int }
		f64 { return .float }
		string { return .string }
		[]int { return .int_array }
		[]f64 { return .float_array }
		[]string { return .string_array }
	}
}

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
	kind        FlagKind          [required]
	name        string            [required]
	aliases     []string
	abbrev      string
	description string
	global      bool
	required    bool
	default     FlagValue
	validate    fn (flag &Flag) ?
mut:
	value FlagValue
	found bool
}

fn (mut flag Flag) setup() ? {
	if !flag.default.undefined() {
		if flag.default.to_kind() != flag.kind {
			return cli_error('kind of flag `$flag.name` does not match default value type')
		}
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

fn (flags []&Flag) setup() ? {
	for i in 0 .. flags.len {
		mut flag := flags[i]
		if flag.value.undefined() {
			flag.setup() ?
		}
	}
}

// parses the arguments as the specified flag kind and returns the number of parsed arguments
fn (mut flag Flag) parse(args []string) ?int {
	mut i := 1
	match flag.kind {
		.bool { flag.parse_bool(args[0]) ? }
		.int { flag.parse_int(args[0]) ? }
		.float { flag.parse_float(args[0]) ? }
		.string { flag.parse_string(args[0]) ? }
		.int_array { i = flag.parse_int_array(args) ? }
		.float_array { i = flag.parse_float_array(args) ? }
		.string_array { i = flag.parse_string_array(args) ? }
	}
	if !isnil(flag.validate) {
		flag.validate(flag) ?
	}
	return i
}

fn (flags []&Flag) parse(args []string, strict bool) ?int {
	if args.len == 0 {
		return cli_error('no arguments given to parse')
	}
	flags.setup() ?

	split := args[0].split_nth('=', 2)
	mut arg := split[0]

	if arg.starts_with('--') { // long flag
		mut flag := flags.get(arg[2..]) or { // `flag`
			flags.get(arg) or { // `--flag`
				if !strict {
					return 0 // skip undefined flag
				}
				return flag_not_found_error(arg) 
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
			return cli_error('flag `$flag.name` requires an argument value')
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
				return cli_error('flag `$flag.name` requires an argument value')
			}
			return 0
		} else { // short flag
			arg = args[0][1..] // trim leading `-`

			mut flag := flags.get_abbrev(arg[0..1]) or {
				if !strict {
					return 0 // skip undefined flag
				}
				return flag_not_found_error(arg)
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
						return flag_not_found_error(arg)
					}
					if flag.kind != .bool {
						return cli_error('can not combine non boolean flags')
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
				return cli_error('flag `$flag.name` (abbrev: `$flag.abbrev`) requires an argument value')
			}
		}
	}
	return 0
}

fn (flags []&Flag) get(name string) ?&Flag {
	for flag in flags {
		if flag.name == name {
			return flag
		} else if flag.aliases.contains(name) {
			return flag
		}
	}
	return cli_error('no flag `$name` found')
}

fn (flags []&Flag) get_abbrev(abbrev string) ?&Flag {
	if abbrev == '' {
		return cli_error('no abbrev given.')
	}

	for flag in flags {
		if flag.abbrev == abbrev {
			return flag
		}
	}
	return cli_error('no flag `$abbrev` found')
}

fn (flags []&Flag) contains(name string) bool {
	flags.get(name) or { return false }
	return true
}

fn (flags []&Flag) contains_abbrev(abbrev string) bool {
	flags.get_abbrev(abbrev) or { return false }
	return true
}

fn flag_not_found_error(name string) IError {
	return cli_error('no flag `$name` found')
}

fn flag_required_error(flag &Flag, cmd &Command) IError {
	return cli_error('flag `$flag.name` is required by `$cmd.full_name()`')
}

fn invalid_flag_kind_error(flag &Flag, expected_kind FlagKind) IError {
	return cli_error('tried to get `$expected_kind` value of `$flag.name`, which is of kind `$flag.kind`')
}

fn invalid_flag_format_error(value string, kind FlagKind) IError {
	return cli_error('invalid $kind format: `$value`')
}