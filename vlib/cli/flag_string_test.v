import cli { Flag }

const strict = true

fn test_if_long_string_flag_parses() ? {
	mut flag := &Flag{
		kind: .string
		name: 'flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string() ? == ''

	flags.parse(['--flag=foo'], strict) ?
	assert flag.get_string() ? == 'foo'

	flags.parse(['--flag', 'bar'], strict) ?
	assert flag.get_string() ? == 'bar'
}

fn test_if_custom_string_flag_parses() ? {
	mut flag := &Flag{
		kind: .string
		name: '-flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string() ? == ''

	flags.parse(['-flag=foo'], strict) ?
	assert flag.get_string() ? == 'foo'

	flags.parse(['-flag', 'bar'], strict) ?
	assert flag.get_string() ? == 'bar'
}

fn test_if_abbrev_string_flag_parses() ? {
	mut flag := &Flag{
		kind: .string
		name: 'flag'
		abbrev: 'f'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string() ? == ''

	flags.parse(['-f=foo'], strict) ?
	assert flag.get_string() ? == 'foo'

	flags.parse(['-fbar'], strict) ?
	assert flag.get_string() ? == 'bar'

	flags.parse(['-f', 'baz'], strict) ?
	assert flag.get_string() ? == 'baz'
}

fn test_if_aliased_string_flag_parses() ? {
	mut flag := &Flag{
		kind: .string
		name: 'flag'
		aliases: ['foo', 'bar']
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string() ? == ''

	flags.parse(['--foo=foo'], strict) ?
	assert flag.get_string() ? == 'foo'

	flags.parse(['--bar', 'bar'], strict) ?
	assert flag.get_string() ? == 'bar'
}

fn test_if_string_default_value_is_set() ? {
	mut flag := &Flag{
		kind: .string
		name: 'flag'
		default: 'hello'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string() ? == 'hello'

	flag = &Flag{
		kind: .string
		name: 'flag'
		default: 'world'
	}
	flags = [flag]

	flags.parse([''], strict) ?
	assert flag.get_string() ? == 'world'
}

fn test_if_long_string_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .string_array
		name: 'flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['--flag=foo,bar'], strict) ?
	assert flag.get_string_array() ? == ['foo', 'bar']

	flag.setup() ? // clear array
	flags.parse(['--flag', 'hello,world'], strict) ?
	assert flag.get_string_array() ? == ['hello', 'world']

	flag.setup() ? // clear array
	flags.parse(['--flag', 'alice,', 'bob'], strict) ?
	assert flag.get_string_array() ? == ['alice', 'bob']
}

fn test_if_custom_string_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .string_array
		name: '-flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['-flag=foo,bar'], strict) ?
	assert flag.get_string_array() ? == ['foo', 'bar']

	flag.setup() ? // clear array
	flags.parse(['-flag', 'hello,world'], strict) ?
	assert flag.get_string_array() ? == ['hello', 'world']

	flag.setup() ? // clear array
	flags.parse(['-flag', 'alice,', 'bob'], strict) ?
	assert flag.get_string_array() ? == ['alice', 'bob']
}

fn test_if_abbrev_string_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .string_array
		name: 'flag'
		abbrev: 'f'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['-f=foo,bar'], strict) ?
	assert flag.get_string_array() ? == ['foo', 'bar']

	flag.setup() ? // clear array
	flags.parse(['-f', 'hello,world'], strict) ?
	assert flag.get_string_array() ? == ['hello', 'world']

	flag.setup() ? // clear array
	flags.parse(['-falice,bob'], strict) ?
	assert flag.get_string_array() ? == ['alice', 'bob']
}

fn test_if_aliased_string_array_flag_parses() ? {
	mut flag := &Flag{
		kind: .string_array
		name: 'flag'
		aliases: ['foo', 'bar']
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string_array() ? == []

	flag.setup() ? // clear array
	flags.parse(['--foo=foo,bar'], strict) ?
	assert flag.get_string_array() ? == ['foo', 'bar']

	flag.setup() ? // clear array
	flags.parse(['--bar', 'hello,world'], strict) ?
	assert flag.get_string_array() ? == ['hello', 'world']
}

fn test_if_string_array_default_value_is_set() ? {
	mut flag := &Flag{
		kind: .string_array
		name: 'flag'
		default: ['Hello World']
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_string_array() ? == ['Hello World']

	flag = &Flag{
		kind: .string_array
		name: 'flag'
		default: ['foo', 'bar']
	}
	flags = [flag]

	flags.parse([''], strict) ?
	assert flag.get_string_array() ? == ['foo', 'bar']
}
