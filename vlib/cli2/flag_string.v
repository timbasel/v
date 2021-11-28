module cli2

import encoding.csv

pub fn (flags []&Flag) get_string(name string) string {
	flag := flags.get(name) or {
		println('cli error: No flag `$name` found.')
		exit(1)
	}
	return flag.get_string()
}

pub fn (flag &Flag) get_string() string {
	if flag.kind != .string {
		println('Tried to get `string` value of flag `$flag.name`, which is of kind `$flag.kind`')
		exit(1)
	}
	return flag.value as string
}

fn (mut flag Flag) parse_string(arg string) {
	println('$flag.name - parse_string: $arg')

	if mut flag.value is string {
		flag.value = arg
	}
}

pub fn (flags []&Flag) get_string_array(name string) []string {
	flag := flags.get(name) or {
		println('cli error: No flag `$name` found.')
		exit(1)
	}

	return flag.get_string_array()
}

pub fn (flag &Flag) get_string_array() []string {
	if flag.kind != .string_array {
		println('cli error: Tried to get `string_array` value of flag `$flag.name`, which is of kind `$flag.kind`')
		exit(1)
	}
	return flag.value as []string
}

fn (mut flag Flag) parse_string_array(args []string) int {
	mut num_args := 0
	if mut flag.value is []string {
		for arg in args {
			if arg.starts_with('-') {
				break
			}

			mut reader := csv.new_reader(arg + '\n')
			split := reader.read() or {
				println('cli error: Failed to parse array flag `$flag.name`: $err')
				exit(1)
			}.filter(it.len > 0)

			flag.value << split
			num_args += 1

			// QUESTION: Should we allow arrays to be split across multiple args (e.g. `--array Hello, World`), i.e. allow spaces between commas
			if !arg.ends_with(',') {
				break
			}
		}
	}
	return num_args
}
