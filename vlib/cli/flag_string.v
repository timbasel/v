module cli

import encoding.csv

pub fn (flags []&Flag) get_string(name string) ?string {
	flag := flags.get(name) or { return error('cli error: no flag `$name` found') }
	return flag.get_string()
}

pub fn (flag &Flag) get_string() ?string {
	if flag.kind != .string {
		return error('cli error: tried to get `string` value of `$flag.name`, which is of kind `$flag.kind`')
	}
	return flag.value as string
}

fn (mut flag Flag) parse_string(arg string) ? {
	flag.value = arg
}

pub fn (flags []&Flag) get_string_array(name string) ?[]string {
	flag := flags.get(name) or { return error('cli error: no flag `$name` found') }
	return flag.get_string_array()
}

pub fn (flag &Flag) get_string_array() ?[]string {
	if flag.kind != .string_array {
		return error('cli error: tried to get `string_array` value of `$flag.name`, which is of kind `$flag.kind`')
	}
	return flag.value as []string
}

fn (mut flag Flag) parse_string_array(args []string) ?int {
	mut num_args := 0
	if mut flag.value is []string {
		for arg in args {
			if arg.starts_with('-') {
				break
			}

			mut reader := csv.new_reader(arg + '\n')
			split := reader.read() or {
				return error('cli error: failed to parse string array flag `$flag.name`: $err')
			}.filter(it.len > 0)

			flag.value << split
			num_args += 1

			// QUESTION: should we allow arrays to be split across multipe arguments (e.g. `--array Hello, World`), i.e. allow spaces between commas
			if !arg.ends_with(',') {
				break
			}
		}
	}
	return num_args
}
