module cli2

pub fn (flags []&Flag) get_bool(name string) bool {
	flag := flags.get(name) or {
		println('cli error: No flag `$name` found.')
		exit(1)
	}
	return flag.get_bool()
}

pub fn (flag &Flag) get_bool() bool {
	if flag.kind != .bool {
		println('Tried to get `bool` value of flag `$flag.name`, which is of kind `$flag.kind`')
		exit(1)
	}
	return flag.value as bool
}

fn (mut flag Flag) parse_bool(arg string) {
	if arg == 'true' {
		flag.value = true
	} else {
		flag.value = false
	}
}
