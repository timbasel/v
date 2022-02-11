module cli

import encoding.csv
import strconv

pub fn (flags []&Flag) get_int(name string) ?int {
	flag := flags.get(name) or { return flag_not_found_error(name) }
	return flag.get_int()
}

pub fn (flag &Flag) get_int() ?int {
	if flag.kind != .int {
		return invalid_flag_kind_error(flag, .int)
	}
	return flag.value as int
}

fn (mut flag Flag) parse_int(arg string) ? {
	flag.value = strconv.atoi(arg) or { return invalid_flag_format_error(arg, .int) }
}

pub fn (flags []&Flag) get_int_array(name string) ?[]int {
	flag := flags.get(name) or { return flag_not_found_error(name) }
	return flag.get_int_array()
}

pub fn (flag &Flag) get_int_array() ?[]int {
	if flag.kind != .int_array {
		return invalid_flag_kind_error(flag, .int_array)
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
				return cli_error('failed to parse integer array flag `$flag.name`: $err')
			}.filter(it.len > 0)

			flag.value << split.map(strconv.atoi(it) or {
				return invalid_flag_format_error(it, .int)
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
