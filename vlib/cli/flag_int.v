module cli

import encoding.csv
import strconv

pub fn (flags []&Flag) get_int(name string) ?int {
	flag := flags.get(name) or { return error('cli error: no flag `$name` found') }
	return flag.get_int()
}

pub fn (flag &Flag) get_int() ?int {
	if flag.kind != .int {
		return error('cli error: tried to get `int` value of `$flag.name`, which is of kind `$flag.kind`')
	}
	return flag.value as int
}

fn (mut flag Flag) parse_int(arg string) ? {
	flag.value = strconv.atoi(arg) or { return error('cli error: invalid integer format: `$arg`') }
}

pub fn (flags []&Flag) get_int_array(name string) ?[]int {
	flag := flags.get(name) or { return error('cli error: no flag `$name` found') }
	return flag.get_int_array()
}

pub fn (flag &Flag) get_int_array() ?[]int {
	if flag.kind != .int_array {
		return error('cli error: tried to get `int_array` value of `$flag.name`, which is of kind `$flag.kind`')
	}
	return flag.value as []int
}

fn (mut flag Flag) parse_int_array(args []string) ?int {
	mut num_args := 0
	if mut flag.value is []int {
		for arg in args {
			if arg.starts_with('-') {
				break
			}

			mut reader := csv.new_reader(arg + '\n')
			split := reader.read() or {
				return error('cli error: failed to parse integer array flag `$flag.name`: $err')
			}.filter(it.len > 0)

			flag.value << split.map(strconv.atoi(it) or {
				return error('cli error: invalid integer format: `$it`')
			})
			num_args += 1

			// QUESTION: should we allow arrays to be split across multipe arguments (e.g. `--array Hello, World`), i.e. allow spaces between commas
			if !arg.ends_with(',') {
				break
			}
		}
	}
	return num_args
}
