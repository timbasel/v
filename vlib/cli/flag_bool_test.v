import cli { Flag }

const strict = true

fn test_if_long_bool_flag_parses() ? {
	mut flag := &Flag{
		kind: .bool
		name: 'flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_bool() ? == false

	flags.parse(['--flag'], strict) ?
	assert flag.get_bool() ? == true

	flags.parse(['--flag=true'], strict) ?
	assert flag.get_bool() ? == true

	flags.parse(['--flag=false'], strict) ?
	assert flag.get_bool() ? == false
}

fn test_if_custom_bool_flag_parses() ? {
	mut flag := &Flag{
		kind: .bool
		name: '-flag'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_bool() ? == false

	flags.parse(['-flag'], strict) ?
	assert flag.get_bool() ? == true

	flags.parse(['-flag=true'], strict) ?
	assert flag.get_bool() ? == true

	flags.parse(['-flag=false'], strict) ?
	assert flag.get_bool() ? == false
}

fn test_if_abbrev_bool_flag_parses() ? {
	mut flag := &Flag{
		kind: .bool
		name: 'flag'
		abbrev: 'f'
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_bool() ? == false

	flags.parse(['-f'], strict) ?
	assert flag.get_bool() ? == true

	flags.parse(['-f=false'], strict) ?
	assert flag.get_bool() ? == false

	flags.parse(['-f=true'], strict) ?
	assert flag.get_bool() ? == true
}

fn test_if_aliased_bool_flag_parses() ? {
	mut flag := &Flag{
		kind: .bool
		name: 'flag'
		aliases: ['foo', 'bar']
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_bool() ? == false

	flags.parse(['--foo'], strict) ?
	assert flag.get_bool() ? == true

	flags.parse(['--foo=false'], strict) ?
	assert flag.get_bool() ? == false

	flags.parse(['--bar'], strict) ?
	assert flag.get_bool() ? == true

	flags.parse(['--bar=false'], strict) ?
	assert flag.get_bool() ? == false
}

fn test_if_bool_default_value_is_set() ? {
	mut flag := &Flag{
		kind: .bool
		name: 'flag'
		default: true
	}
	mut flags := [flag]

	flags.parse([''], strict) ?
	assert flag.get_bool() ? == true

	flag = &Flag{
		kind: .bool
		name: 'flag'
		default: false
	}
	flags = [flag]

	flags.parse([''], strict) ?
	assert flag.get_bool() ? == false
}

fn test_if_combined_bool_flags_parse() ? {
	mut flag_a := &Flag{
		kind: .bool
		name: 'flag-a'
		abbrev: 'a'
	}
	mut flag_b := &Flag{
		kind: .bool
		name: 'flag-b'
		abbrev: 'b'
	}
	flags := [flag_a, flag_b]

	flags.parse([''], strict) ?
	assert flag_a.get_bool() ? == false
	assert flag_b.get_bool() ? == false

	flags.parse(['-ab'], strict) ?
	assert flag_a.get_bool() ? == true
	assert flag_b.get_bool() ? == true
}
