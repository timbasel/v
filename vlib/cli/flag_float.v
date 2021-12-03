module cli

import encoding.csv
import strconv

pub fn (flags []&Flag) get_float(name string) ?f64 {
	flag := flags.get(name) or { return error('cli error: no flag `$name` found') }
	return flag.get_float()
}

pub fn (flag &Flag) get_float() ?f64 {
	if flag.kind != .float {
		return error('cli error: tried to get `float` value of `$flag.name`, which is of kind `$flag.kind`')
	}
	return flag.value as f64
}

fn (mut flag Flag) parse_float(arg string) ? {
	// TODO: check if argument is valid floating point number
	flag.value = strconv.atof64(arg)
}

pub fn (flags []&Flag) get_float_array(name string) ?[]f64 {
	flag := flags.get(name) or { return error('cli error: no flag `$name` found') }
	return flag.get_float_array()
}

pub fn (flag &Flag) get_float_array() ?[]f64 {
	if flag.kind != .float_array {
		return error('cli error: tried to get `float_array` value of `$flag.name`, which is of kind `$flag.kind`')
	}
	return flag.value as []f64
}

fn (mut flag Flag) parse_float_array(args []string) ?int {
	mut num_args := 0
	if mut flag.value is []f64 {
		for arg in args {
			if arg.starts_with('-') {
				break
			}

			mut reader := csv.new_reader(arg + '\n')
			split := reader.read() or {
				return error('cli error: failed to parse float array flag `$flag.name`: $err')
			}.filter(it.len > 0)

			// TODO: check if argument is valid floating point number
			flag.value << split.map(strconv.atof64(it))
			num_args += 1

			// QUESTION: should we allow arrays to be split across multipe arguments (e.g. `--array Hello, World`), i.e. allow spaces between commas
			if !arg.ends_with(',') {
				break
			}
		}
	}
	return num_args
}
