import cli { Flag }

const strict = true

fn test_if_long_int_flag_parses() ? {
	mut flag := &Flag{
		kind: .int
		name: 'flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int() ? == 0

	flags.parse(['--flag=1'], strict) ?
	assert flag.get_int() ? == 1

	flags.parse(['--flag', '2'], strict) ?
	assert flag.get_int() ? == 2
}

fn test_if_custom_int_flag_parses() ? {
	mut flag := &Flag{
		kind: .int
		name: '-flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int() ? == 0

	flags.parse(['-flag=1'], strict) ?
	assert flag.get_int() ? == 1

	flags.parse(['-flag', '2'], strict) ?
	assert flag.get_int() ? == 2
}

fn test_if_abbrev_int_flag_parses() ? {
	mut flag := &Flag{
		kind: .int
		name: 'flag'
		abbrev: 'f'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int() ? == 0

	flags.parse(['-f=1'], strict) ?
	assert flag.get_int() ? == 1

	flags.parse(['-f2'], strict) ?
	assert flag.get_int() ? == 2

	flags.parse(['-f', '3'], strict) ?
	assert flag.get_int() ? == 3
}

fn test_if_aliased_int_flag_parses() ? {
	mut flag := &Flag{
		kind: .int
		name: 'flag'
		aliases: ['foo', 'bar']
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int() ? == 0

	flags.parse(['--foo=1'], strict) ?
	assert flag.get_int() ? == 1

	flags.parse(['--bar', '2'], strict) ?
	assert flag.get_int() ? == 2
}

fn test_if_int_default_value_is_set() ? {
	mut flag := &Flag{
		kind: .int
		name: 'flag'
		default: 42
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int() ? == 42

	flag = &Flag{
		kind: .int
		name: 'flag'
		default: 7
	}
	flags = [flag]

	flags.parse([''], strict) ?
	assert flag.get_int() ? == 7
}

fn test_if_long_int_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .int_array
		name: 'flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['--flag=1,2'], strict) ?
	assert flag.get_int_array() ? == [1, 2]

	flag.setup() ? // clear array
	flags.parse(['--flag', '3,4'], strict) ?
	assert flag.get_int_array() ? == [3, 4]

	flag.setup() ? // clear array
	flags.parse(['--flag', '5,', '6'], strict) ?
	assert flag.get_int_array() ? == [5, 6]
}

fn test_if_custom_int_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .int_array
		name: '-flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['-flag=1,2'], strict) ?
	assert flag.get_int_array() ? == [1, 2]

	flag.setup() ? // clear array
	flags.parse(['-flag', '3,4'], strict) ?
	assert flag.get_int_array() ? == [3, 4]

	flag.setup() ? // clear array
	flags.parse(['-flag', '5,', '6'], strict) ?
	assert flag.get_int_array() ? == [5, 6]
}

fn test_if_abbrev_int_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .int_array
		name: 'flag'
		abbrev: 'f'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['-f=1,2'], strict) ?
	assert flag.get_int_array() ? == [1, 2]

	flag.setup() ? // clear array
	flags.parse(['-f', '3,4'], strict) ?
	assert flag.get_int_array() ? == [3, 4]

	flag.setup() ? // clear array
	flags.parse(['-f5,6'], strict) ?
	assert flag.get_int_array() ? == [5, 6]
}

fn test_if_aliased_int_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .int_array
		name: 'flag'
		aliases: ['foo', 'bar']
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['--foo=1,2'], strict) ?
	assert flag.get_int_array() ? == [1, 2]

	flag.setup() ? // clear array
	flags.parse(['--bar', '3,4'], strict) ?
	assert flag.get_int_array() ? == [3, 4]
}

fn test_if_int_array_default_value_is_set() ? {
	mut flag := &Flag{
		kind: .int_array
		name: 'flag'
		default: [42]
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_int_array() ? == [42]

	flag = &Flag{
		kind: .int_array
		name: 'flag'
		default: [1234, 5678]
	}
	flags = [flag]

	flags.parse([''], strict) ?
	assert flag.get_int_array() ? == [1234, 5678]
}
