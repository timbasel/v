module cli2

import encoding.csv
import strconv

pub fn (flags []&Flag) get_float(name string) f64 {
	flag := flags.get(name) or {
		println('cli error: No flag `$name` found.')
		exit(1)
	}
	return flag.get_float()
}

pub fn (flag &Flag) get_float() f64 {
	if flag.kind != .float {
		println('cli error: Tried to get `float` value of flag `$flag.name`, which is of kind `$flag.kind`')
		exit(1)
	}
	return flag.value as f64
}

fn (mut flag Flag) parse_float(arg string) {
	// TODO: Check if provided floating point number is valid
	flag.value = strconv.atof64(arg)
}

pub fn (flags []&Flag) get_float_array(name string) []f64 {
	flag := flags.get(name) or {
		println('cli error: No flag `$name` found.')
		exit(1)
	}

	return flag.get_float_array()
}

pub fn (flag &Flag) get_float_array() []f64 {
	if flag.kind != .float_array {
		println('cli error: Tried to get `float_array` value of flag `$flag.name`, which is of kind `$flag.kind`')
		exit(1)
	}
	return flag.value as []f64
}

fn (mut flag Flag) parse_float_array(args []string) int {
	mut num_args := 0
	if mut flag.value is []f64 {
		for arg in args {
			if arg.starts_with('-') {
				break
			}

			mut reader := csv.new_reader(arg + '\n')
			split := reader.read() or {
				println('cli error: Failed to parse array flag `$flag.name`: $err')
				exit(1)
			}.filter(it.len > 0)

			flag.value << split.map(it.f64())
			num_args += 1

			// QUESTION: Should we allow arrays to be split across multiple args (e.g. `--array Hello, World`), i.e. allow spaces between commas
			if !arg.ends_with(',') {
				break
			}
		}
	}
	return num_args
}
