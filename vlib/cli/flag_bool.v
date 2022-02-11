module cli

pub fn (flags []&Flag) get_bool(name string) ?bool {
	flag := flags.get(name) or { return flag_not_found_error(name) }
	return flag.get_bool()
}

pub fn (flag &Flag) get_bool() ?bool {
	if flag.kind != .bool {
		return invalid_flag_kind_error(flag, .bool)
	}
	return flag.value as bool
}

fn (mut flag Flag) parse_bool(arg string) ? {
	// QUESTION: should we support more truthy values (e.g. 'y' or 'yes' etc.)
	if arg.to_lower() == 'true' {
		flag.value = true
	} else {
		flag.value = false
	}
}
