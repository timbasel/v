import cli { Flag }

fn test_if_string_flag_parses() {
	mut flag := &Flag{
		kind: .string
		name: 'flag1'
	}
	flag.parse(['--flag1', 'value1']) or { panic(err) }
	mut value := flag.get_string() or { panic(err) }
	assert value == 'value1'

	flag = &Flag{
		kind: .string
		name: 'flag2'
	}
	flag.parse(['--flag2=value2']) or { panic(err) }
	value = flag.get_string() or { panic(err) }
	assert value == 'value2'

	flag = &Flag{
		kind: .string_array
		name: 'flag'
	}
	flag.parse(['--flag=value1']) or { panic(err) }
	flag.parse(['--flag=value2']) or { panic(err) }
	mut values := flag.get_string_array() or { panic(err) }
	assert values == ['value1', 'value2']

	flags := [
		&Flag{
			kind: .string_array
			name: 'flag'
			value: ['a', 'b', 'c']
		},
		&Flag{
			kind: .string
			name: 'flag2'
		},
	]

	values = flags.get_string_array('flag') or { panic(err) }
	assert values == ['a', 'b', 'c']
}

fn test_if_bool_flag_parses() {
	mut flag := &Flag{
		kind: .bool
		name: 'flag'
	}
	mut value := false
	flag.parse(['--flag']) or { panic(err) }
	value = flag.get_bool() or { panic(err) }
	assert value == true
	flag.parse(['--flag', 'false']) or { panic(err) }
	value = flag.get_bool() or { panic(err) }
	assert value == false
	flag.parse(['--flag', 'true']) or { panic(err) }
	value = flag.get_bool() or { panic(err) }
	assert value == true
	flag.parse(['--flag=false']) or { panic(err) }
	value = flag.get_bool() or { panic(err) }
	assert value == false
	flag.parse(['--flag=true']) or { panic(err) }
	value = flag.get_bool() or { panic(err) }
	assert value == true
}

fn test_if_int_flag_parses() {
	mut flag := &Flag{
		kind: .int
		name: 'flag'
	}

	mut value := 0
	flag.parse(['--flag', '42']) or { panic(err) }
	value = flag.get_int() or { panic(err) }
	assert value == 42

	flag = &Flag{
		kind: .int
		name: 'flag'
	}

	flag.parse(['--flag=45']) or { panic(err) }
	value = flag.get_int() or { panic(err) }
	assert value == 45

	flag = &Flag{
		kind: .int_array
		name: 'flag'
	}

	flag.parse(['--flag=42']) or { panic(err) }
	flag.parse(['--flag=45']) or { panic(err) }
	mut values := flag.get_int_array() or { panic(err) }
	assert values == [42, 45]

	flags := [
		&Flag{
			kind: .int_array
			name: 'flag'
			value: [1, 2, 3]
		},
		&Flag{
			kind: .int
			name: 'flag2'
		},
	]

	values = flags.get_int_array('flag') or { panic(err) }
	assert values == [1, 2, 3]
}

fn test_if_float_flag_parses() {
	mut flag := &Flag{
		kind: .float
		name: 'flag'
	}
	mut value := f64(0)
	flag.parse(['--flag', '3.14158']) or { panic(err) }
	value = flag.get_float() or { panic(err) }
	assert value == 3.14158

	flag = &Flag{
		kind: .float
		name: 'flag'
	}

	flag.parse(['--flag=3.14159']) or { panic(err) }
	value = flag.get_float() or { panic(err) }
	assert value == 3.14159

	flag = &Flag{
		kind: .float_array
		name: 'flag'
	}

	flag.parse(['--flag=3.1']) or { panic(err) }
	flag.parse(['--flag=1.3']) or { panic(err) }
	mut values := flag.get_float_array() or { panic(err) }
	assert values == [3.1, 1.3]

	flags := [
		&Flag{
			kind: .float_array
			name: 'flag'
			value: [1.1, 2.2, 3.3]
		},
		&Flag{
			kind: .float
			name: 'flag2'
		},
	]

	values = flags.get_float_array('flag') or { panic(err) }
	assert values == [1.1, 2.2, 3.3]
}

fn test_if_flag_parses_with_abbrev() {
	mut flag := &Flag{
		kind: .bool
		name: 'flag'
		abbrev: 'f'
	}
	mut value := false
	flag.parse(['--flag']) or { panic(err) }
	value = flag.get_bool() or { panic(err) }
	assert value == true

	value = false
	flag = &Flag{
		kind: .bool
		name: 'flag'
		abbrev: 'f'
	}
	flag.parse(['-f']) or { panic(err) }
	value = flag.get_bool() or { panic(err) }
	assert value == true
}

/*
fn test_if_multiple_value_on_single_value() {
	mut flag := &Flag{
		kind: .float
		name: 'flag'
	}

	flag.parse(['--flag', '3.14158']) or { panic(err) }

	if _ := flag.parse(['--flag', '3.222']) {
		panic("No multiple value flag don't raise an error!")
	} else {
		assert true
	}
}
*/

fn test_default_value() {
	mut flag := &Flag{
		kind: .float
		name: 'flag'
		default: 1.234
	}

	flag.parse(['--flag', '3.14158']) or { panic(err) }
	mut value := flag.get_float() or { panic(err) }
	assert value == 3.14158

	flag = &Flag{
		kind: .float
		name: 'flag'
		default: 1.234
	}

	flag.parse([]) or { panic(err) }
	value = flag.get_float() or { panic(err) }
	assert value == 1.234
}
