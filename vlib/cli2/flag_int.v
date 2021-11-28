module cli2

import encoding.csv
import strconv

pub fn (flags []&Flag) get_int(name string) int {
	flag := flags.get(name) or {
		println('cli error: No flag `$name` found.')
		exit(1)
	}
	return flag.get_int()
}

pub fn (flag &Flag) get_int() int {
	if flag.kind != .int {
		println('Tried to get `int` value of flag `$flag.name`, which is of kind `$flag.kind`')
		exit(1)
	}
	return flag.value as int
}

fn (mut flag Flag) parse_int(arg string) {
	flag.value = strconv.atoi(arg) or {
		println('cli error: invalid integer number: `$arg`')
		exit(1)
	}
}

pub fn (flags []&Flag) get_int_array(name string) []int {
	flag := flags.get(name) or {
		println('cli error: No flag `$name` found.')
		exit(1)
	}

	return flag.get_int_array()
}

pub fn (flag &Flag) get_int_array() []int {
	if flag.kind != .int_array {
		println('cli error: Tried to get `int_array` value of flag `$flag.name`, which is of kind `$flag.kind`')
		exit(1)
	}
	return flag.value as []int
}

fn (mut flag Flag) parse_int_array(args []string) int {
	mut num_args := 0
	if mut flag.value is []int {
		for arg in args {
			if arg.starts_with('-') {
				break
			}

			mut reader := csv.new_reader(arg + '\n')
			split := reader.read() or {
				println('cli error: Failed to parse array flag `$flag.name`: $err')
				exit(1)
			}.filter(it.len > 0)

			flag.value << split.map(it.int())
			num_args += 1

			// QUESTION: Should we allow arrays to be split across multiple args (e.g. `--array Hello, World`), i.e. allow spaces between commas
			if !arg.ends_with(',') {
				break
			}
		}
	}
	return num_args
}
