import cli { Flag }

const strict = true

fn test_if_long_float_flag_parses()? {
	mut flag := &Flag{
		kind: .float
		name: 'flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float() ? == 0.0

	flags.parse(['--flag=1.5'], strict) ?
	assert flag.get_float() ? == 1.5

	flags.parse(['--flag', '2.5'], strict) ?
	assert flag.get_float() ? == 2.5
}

fn test_if_custom_float_flag_parses()? {
	mut flag := &Flag{
		kind: .float
		name: '-flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float() ? == 0.0

	flags.parse(['-flag=1.5'], strict) ?
	assert flag.get_float() ? == 1.5

	flags.parse(['-flag', '2.5'], strict) ?
	assert flag.get_float() ? == 2.5
}

fn test_if_abbrev_float_flag_parses()? {
	mut flag := &Flag{
		kind: .float
		name: 'flag'
		abbrev: 'f'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float() ? == 0

	flags.parse(['-f=1.5'], strict) ?
	assert flag.get_float() ? == 1.5

	flags.parse(['-f2.5'], strict) ?
	assert flag.get_float() ? == 2.5

	flags.parse(['-f', '3.5'], strict) ?
	assert flag.get_float() ? == 3.5
}

fn test_if_float_default_value_is_set()? {
	mut flag := &Flag{
		kind: .float
		name: 'flag'
		default: 1.234
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float() ? == 1.234

	flag = &Flag{
		kind: .float
		name: 'flag'
		default: 3.14159
	}
	flags = [flag]

	flags.parse([''], strict) ?
	assert flag.get_float() ? == 3.14159
}

fn test_if_long_float_array_flag_parses()? {
	mut flag := &Flag{
		kind: .float_array
		name: 'flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float_array() ? == []

	flag.setup() // clear array
	flags.parse(['--flag=1.1,2.2'], strict) ?
	assert flag.get_float_array() ? == [1.1, 2.2]

	flag.setup() // clear array
	flags.parse(['--flag', '3.3,4.4'], strict) ?
	assert flag.get_float_array() ? == [3.3, 4.4]

	flag.setup() // clear array
	flags.parse(['--flag', '5.5,' '6.6'], strict) ?
	assert flag.get_float_array() ? == [5.5, 6.6]
}

fn test_if_custom_float_array_flag_parses()? {
	mut flag := &Flag{
		kind: .float_array
		name: '-flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float_array() ? == []

	flag.setup() // clear array
	flags.parse(['-flag=1.1,2.2'], strict) ?
	assert flag.get_float_array() ? == [1.1, 2.2]

	flag.setup() // clear array
	flags.parse(['-flag', '3.3,4.4'], strict) ?
	assert flag.get_float_array() ? == [3.3, 4.4]

	flag.setup() // clear array
	flags.parse(['-flag', '5.5,' '6.6'], strict) ?
	assert flag.get_float_array() ? == [5.5, 6.6]
}

fn test_if_abbrev_float_array_flag_parses()? {
	mut flag := &Flag{
		kind: .float_array
		name: 'flag'
		abbrev: 'f'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float_array() ? == []

	flag.setup() // clear array
	flags.parse(['-f=1.1,2.2'], strict) ?
	assert flag.get_float_array() ? == [1.1, 2.2]

	flag.setup() // clear array
	flags.parse(['-f', '3.3,4.4'], strict) ?
	assert flag.get_float_array() ? == [3.3, 4.4]

	flag.setup() // clear array
	flags.parse(['-f5.5,6.6'], strict) ?
	assert flag.get_float_array() ? == [5.5, 6.6]

}

fn test_if_float_array_default_value_is_set()? {
	mut flag := &Flag{
		kind: .float_array
		name: 'flag'
		default: [3.14159]
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_float_array() ? == [3.14159]

	flag = &Flag{
		kind: .float_array
		name: 'flag'
		default: [1.2345, 6.789]
	}
	flags = [flag]

	flags.parse([''], strict) ?
	assert flag.get_float_array() ? == [1.2345, 6.789]
}

