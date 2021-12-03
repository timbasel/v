module cli

pub fn (flags []&Flag) get_bool(name string) ?bool {
	flag := flags.get(name) or { return error('cli error: no flag `$name` found') }
	return flag.get_bool()
}

pub fn (flag &Flag) get_bool() ?bool {
	if flag.kind != .bool {
		return error('cli error: tried to get `bool` value of `$flag.name`, which is of kind `$flag.kind`')
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
