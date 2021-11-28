module cli2

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

[heap]
pub struct Flag {
pub mut:
	kind        FlagKind [required]
	name        string
	abbrev      string
	description string
	global      bool
	required    bool
	default     FlagType
mut:
	value FlagType
	found bool
}

fn (mut flag Flag) set_default() {
	if flag.default.type_name().split(' ')[0] != 'unknown' { // check if default value is undefined
		flag.value = flag.default
	} else {
		match flag.kind {
			.bool {
				flag.value = false
			}
			.int {
				flag.value = 0
			}
			.float {
				flag.value = f64(0)
			}
			.string {
				flag.value = ''
			}
			.int_array {
				flag.value = []int{}
			}
			.float_array {
				flag.value = []f64{}
			}
			.string_array {
				flag.value = []string{}
			}
		}
	}
}

// parses the value of the specific flag type and returns the number of parsed arguments
fn (mut flag Flag) parse(args []string) int {
	match flag.kind {
		.bool {
			flag.parse_bool(args[0])
		}
		.int {
			flag.parse_int(args[0])
		}
		.float {
			flag.parse_float(args[0])
		}
		.string {
			flag.parse_string(args[0])
		}
		.int_array {
			return flag.parse_int_array(args)
		}
		.float_array {
			return flag.parse_float_array(args)
		}
		.string_array {
			return flag.parse_string_array(args)
		}
	}
	return 1
}

fn (flags []&Flag) get(name string) ?&Flag {
	for flag in flags {
		if flag.name == name {
			return flag
		}
	}
	return error('Flag `$name` not found in $flags')
}

fn (flags []&Flag) get_abbrev(abbrev string) ?&Flag {
	for flag in flags {
		if flag.abbrev == abbrev {
			return flag
		}
	}
	return error('Flag `$abbrev` not found in $flags')
}

fn (flags []&Flag) contains(name string) bool {
	flags.get(name) or { return false }
	return true
}

fn (flags []&Flag) contains_abbrev(name string) bool {
	flags.get_abbrev(name) or { return false }
	return true
}
