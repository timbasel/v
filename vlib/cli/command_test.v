import cli { Command, Flag }

fn test_if_command_parses_empty_args() ? {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {}
	}
	cmd.parse(['cmd']) ?

	assert cmd.name == 'cmd'
	assert compare_arrays(cmd.args, [])
}

fn test_if_command_is_executed() ? {
	mut called := false

	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {
			return error('cmd')
		}
	}
	cmd.parse(['cmd']) or {
		match err.msg {
			'cmd' { called = true }
			else { panic(err) }
		}
	}

	assert called == true
}

fn test_if_command_parses_args() ? {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {
			assert cmd.name == 'cmd'
			assert compare_arrays(cmd.args, ['arg0', 'arg1'])
		}
	}
	cmd.parse(['cmd', 'arg0', 'arg1']) ?
}

fn test_if_subcommand_is_executed() ? {
	mut called := false

	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_command(&Command{
		name: 'subcmd'
		execute: fn (cmd &Command) ? {
			return error('subcmd')
		}
	})
	cmd.parse(['cmd', 'subcmd']) or {
		match err.msg {
			'subcmd' { called = true }
			else { panic(err) }
		}
	}

	assert called == true
}

fn test_if_correct_subcommand_is_executed() ? {
	mut subcmd1_called := false
	mut subcmd2_called := false

	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_command(&Command{
		name: 'subcmd1'
		execute: fn (cmd &Command) ? {
			return error('subcmd1')
		}
	})
	cmd.add_command(&Command{
		name: 'subcmd2'
		execute: fn (cmd &Command) ? {
			return error('subcmd2')
		}
	})

	cmd.parse(['cmd']) or {
		match err.msg {
			'subcmd1' { subcmd1_called = true }
			'subcmd2' { subcmd2_called = true }
			else { panic(err) }
		}
	}
	assert subcmd1_called == false
	assert subcmd2_called == false

	cmd.parse(['cmd', 'subcmd1']) or {
		match err.msg {
			'subcmd1' { subcmd1_called = true }
			'subcmd2' { subcmd2_called = true }
			else { panic(err) }
		}
	}
	assert subcmd1_called == true
	assert subcmd2_called == false

	subcmd1_called = false

	cmd.parse(['cmd', 'subcmd2']) or {
		match err.msg {
			'subcmd1' { subcmd1_called = true }
			'subcmd2' { subcmd2_called = true }
			else { panic(err) }
		}
	}
	assert subcmd1_called == false
	assert subcmd2_called == true
}

fn test_if_aliased_subcommand_is_executed() ? {
	mut called := false

	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_command(&Command{
		name: 'subcmd'
		aliases: ['alias']
		execute: fn (cmd &Command) ? {
			return error('subcmd')
		}
	})

	cmd.parse(['cmd', 'alias']) or {
		match err.msg {
			'subcmd' { called = true }
			else { panic(err) }
		}
	}
	assert called == true
}

fn test_if_subcommands_parse_args() ? {
	mut cmd := &Command{
		name: 'cmd'
	}
	subcmd := &Command{
		name: 'subcmd'
		execute: fn (cmd &Command) ? {
			assert cmd.name == 'subcmd'
			assert compare_arrays(cmd.args, ['arg0', 'arg1'])
		}
	}
	cmd.add_command(subcmd)
	cmd.parse(['cmd', 'subcmd', 'arg0', 'arg1']) ?
}

fn test_if_command_has_default_help_command_if_it_has_subcommnds() ? {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_command(&Command{
		name: 'subcmd'
	})
	cmd.parse(['cmd']) ?

	assert has_command(cmd, 'help')
}

fn test_if_command_has_default_version_command_if_it_has_version_and_subcommands() ? {
	mut cmd := &Command{
		name: 'cmd'
		version: '1.0.0'
	}
	cmd.add_command(&Command{
		name: 'subcmd'
	})
	cmd.parse(['cmd']) ?

	assert has_command(cmd, 'version')
}

fn test_if_command_has_no_default_commands_if_no_subcommand_is_added() ? {
	mut cmd := &Command{
		name: 'cmd'
		version: '1.0.0'
	}
	cmd.parse(['cmd']) ?

	assert cmd.commands.len == 0
}

fn test_if_flag_gets_set() ? {
	mut cmd := &Command{
		name: 'cmd'
		execute: string_flag_is_set_fn
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'string'
	})
	cmd.parse(['cmd', '--string', 'foo']) ?
}

fn test_if_flag_gets_set_with_abbrev() ? {
	mut cmd := &Command{
		name: 'cmd'
		execute: string_flag_is_set_fn
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'string'
		abbrev: 's'
	})
	cmd.parse(['cmd', '-s', 'foo']) ?
}

fn test_if_flag_gets_set_with_long_arg() ? {
	mut cmd := &Command{
		name: 'cmd'
		execute: string_flag_is_set_fn
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'string'
		abbrev: 'f'
	})
	cmd.parse(['cmd', '--string', 'foo']) ?
}

fn test_if_multiple_flags_get_set() ? {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {
			string_flag_is_set_fn(cmd) ?
			int_flag_is_set_fn(cmd) ?
		}
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'string'
	})
	cmd.add_flag(&Flag{
		kind: .int
		name: 'int'
	})
	cmd.parse(['cmd', '--string', 'foo', '--int', '42']) ?
}

fn test_if_required_flags_get_set() ? {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {
			string_flag_is_set_fn(cmd) ?
			int_flag_is_set_fn(cmd) ?
		}
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'string'
	})
	cmd.add_flag(&Flag{
		kind: .int
		name: 'int'
		required: true
	})
	cmd.parse(['cmd', '--string', 'foo', '--int', '42']) ?
}

fn test_if_flag_gets_set_in_subcommand() ? {
	mut cmd := &Command{
		name: 'cmd'
	}
	mut subcmd := &Command{
		name: 'subcmd'
		execute: string_flag_is_set_fn
	}
	subcmd.add_flag(&Flag{
		kind: .string
		name: 'string'
	})
	cmd.add_command(subcmd)
	cmd.parse(['cmd', 'subcmd', '--string', 'foo']) ?
}

fn test_if_global_flag_gets_set_in_subcommand() ? {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'string'
		global: true
	})
	cmd.add_command(&Command{
		name: 'subcmd'
		execute: string_flag_is_set_fn
	})
	cmd.parse(['cmd', '--string', 'foo', 'subcmd']) ?
}

fn test_if_combined_bool_flags_gets_set() ? {
	mut cmd := &Command{
		name: 'cmd'
	}
	flag_a := cmd.add_flag(&Flag{
		kind: .bool
		name: 'flag-a'
		abbrev: 'a'
	})
	flag_b := cmd.add_flag(&Flag{
		kind: .bool
		name: 'flag-b'
		abbrev: 'b'
	})

	cmd.parse(['cmd']) ?

	assert flag_a.get_bool() ? == false
	assert flag_b.get_bool() ? == false

	cmd.parse(['cmd', '-ab']) ?

	assert flag_a.get_bool() ? == true
	assert flag_b.get_bool() ? == true
}

fn test_command_validators() {
	$if x64 && !windows {
		mut cmd := &Command{
			name: 'cmd'
		}

		cmd.validate = cli.no_args
		cmd.args = []
		cmd.parse(['cmd']) or {
			assert false // should parse without error
		}
		cmd.args = []
		cmd.parse(['cmd', 'foo', 'bar']) or { assert err.msg().contains('does not take any arguments') }

		cmd.validate = cli.minimum_number_of_args(1)
		cmd.args = []
		cmd.parse(['cmd']) or { assert err.msg().contains('expects at least') }
		cmd.args = []
		cmd.parse(['cmd', 'foo']) or {
			assert false // should parse without error
		}

		cmd.validate = cli.maximum_number_of_args(2)
		cmd.args = []
		cmd.parse(['cmd', 'foo']) or {
			assert false // should parse without error
		}
		cmd.args = []
		cmd.parse(['cmd', 'foo', 'bar', 'baz']) or { assert err.msg().contains('expects at most') }

		cmd.validate = cli.exact_number_of_args(2)
		cmd.args = []
		cmd.parse(['cmd', 'foo', 'bar']) or {
			assert false // should parse without error
		}
		cmd.args = []
		cmd.parse(['cmd', 'foo']) or { assert err.msg().contains('expects exactly') }

		cmd.validate = cli.number_of_args_between(1, 3)
		cmd.args = []
		cmd.parse(['cmd']) or { assert err.msg().contains('expects between') }
		cmd.parse(['cmd', 'foo', 'bar']) or {
			assert false // should parse without error
		}

		cmd.validate = cli.only_valid_args(['foo', 'bar'])
		cmd.args = []
		cmd.parse(['cmd']) or {
			assert false // should parse without error
		}
		cmd.args = []
		cmd.parse(['cmd', 'foo', 'bar']) or {
			assert false // should parse without error
		}
		cmd.args = []
		cmd.parse(['cmd', 'baz']) or { assert err.msg().contains('invalid argument `baz`') }
	}
}

// Helper functions

fn string_flag_is_set_fn(cmd &Command) ? {
	flag := cmd.flags.get_string('string') ?
	assert flag == 'foo'
}

fn int_flag_is_set_fn(cmd &Command) ? {
	value := cmd.flags.get_int('int') ?
	assert value == 42
}

fn has_command(cmd Command, name string) bool {
	for subcmd in cmd.commands {
		if subcmd.name == name {
			return true
		}
	}
	return false
}

fn compare_arrays(array0 []string, array1 []string) bool {
	if array0.len != array1.len {
		return false
	}
	for i in 0 .. array0.len {
		if array0[i] != array1[i] {
			return false
		}
	}
	return true
}
