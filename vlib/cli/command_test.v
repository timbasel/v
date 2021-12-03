import cli { Command, Flag }

fn test_if_command_parses_empty_args() {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {}
	}
	cmd.parse(['cmd']) or { panic(err) }

	assert cmd.name == 'cmd' && compare_arrays(cmd.args, [])
}

fn xtest_if_command_execute_fn_is_called() {
	mut called := false
	mut called_ref := &called

	mut cmd := &Command{
		name: 'cmd'
		execute: fn [mut called_ref] (cmd &Command) ? {
			unsafe {
				*called_ref = true
			}
		}
	}
	cmd.parse(['cmd']) or { panic(err) }

	assert called == true
}

fn test_if_command_parses_args() {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {
			assert cmd.name == 'cmd'
			assert compare_arrays(cmd.args, ['arg0', 'arg1'])
		}
	}
	cmd.parse(['cmd', 'arg0', 'arg1']) or { panic(err) }
}

fn xtest_if_subcommand_execute_fn_is_called() {
	mut called := false
	mut called_ref := &called

	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_command(&Command{
		name: 'subcmd'
		execute: fn [mut called_ref] (cmd &Command) ? {
			unsafe {
				*called_ref = true
			}
		}
	})
	cmd.parse(['cmd', 'subcmd']) or { panic(err) }

	assert called == true
}

fn xtest_if_correct_subcommand_is_executed() {
	mut subcmd1_called := false
	mut subcmd1_called_ref := &subcmd1_called
	mut subcmd2_called := false
	mut subcmd2_called_ref := &subcmd2_called

	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_command(&Command{
		name: 'subcmd1'
		execute: fn [mut subcmd1_called_ref] (cmd &Command) ? {
			unsafe {
				*subcmd1_called_ref = true
			}
		}
	})
	cmd.add_command(&Command{
		name: 'subcmd2'
		execute: fn [mut subcmd2_called_ref] (cmd &Command) ? {
			unsafe {
				*subcmd2_called_ref = true
			}
		}
	})

	cmd.parse(['cmd']) or { panic(err) }
	assert subcmd1_called == false
	assert subcmd2_called == false

	cmd.parse(['cmd', 'subcmd1']) or { panic(err) }
	assert subcmd1_called == true
	assert subcmd2_called == false

	subcmd1_called = false

	cmd.parse(['cmd', 'subcmd2']) or { panic(err) }
	assert subcmd1_called == false
	assert subcmd2_called == true
}

fn test_if_subcommands_parse_args() {
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
	cmd.parse(['cmd', 'subcmd', 'arg0', 'arg1']) or { panic(err) }
}

fn test_if_command_has_default_help_subcommand() {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.parse(['cmd']) or { panic(err) }

	assert has_command(cmd, 'help')
}

fn test_if_command_has_default_version_subcommand_if_version_is_set() {
	mut cmd := &Command{
		name: 'cmd'
		version: '1.0.0'
	}
	cmd.parse(['cmd']) or { panic(err) }

	assert has_command(cmd, 'version')
}

fn test_if_flag_gets_set() {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) ? {
			flag := cmd.flags.get_string('flag') ?

			assert flag == 'value'
		}
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.parse(['cmd', '--flag', 'value']) or { panic(err) }
}

fn test_if_flag_gets_set_with_abbrev() {
	mut cmd := &Command{
		name: 'cmd'
		execute: flag_should_be_set_fn
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
		abbrev: 'f'
	})
	cmd.parse(['cmd', '-f', 'value']) or { panic(err) }
}

fn test_if_flag_gets_set_with_long_arg() {
	mut cmd := &Command{
		name: 'cmd'
		execute: flag_should_be_set_fn
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
		abbrev: 'f'
	})
	cmd.parse(['cmd', '--flag', 'value']) or { panic(err) }
}

fn test_if_multiple_flags_get_set() {
	mut cmd := &Command{
		name: 'cmd'
		execute: flag_should_have_value_of_42_fn
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.add_flag(&Flag{
		kind: .int
		name: 'value'
	})
	cmd.parse(['cmd', '--flag', 'value', '--value', '42']) or { panic(err) }
}

fn test_if_required_flags_get_set() {
	mut cmd := &Command{
		name: 'cmd'
		execute: flag_should_have_value_of_42_fn
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.add_flag(&Flag{
		kind: .int
		name: 'value'
		required: true
	})
	cmd.parse(['cmd', '--flag', 'value', '--value', '42']) or { panic(err) }
}

fn test_if_flag_gets_set_in_subcommand() {
	mut cmd := &Command{
		name: 'cmd'
	}
	mut subcmd := &Command{
		name: 'subcmd'
		execute: flag_is_set_in_subcommand_fn
	}
	subcmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.add_command(subcmd)
	cmd.parse(['cmd', 'subcmd', '--flag', 'value']) or { panic(err) }
}

fn test_if_global_flag_gets_set_in_subcommand() {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
		global: true
	})
	subcmd := &Command{
		name: 'subcmd'
		execute: flag_is_set_in_subcommand_fn
	}
	cmd.add_command(subcmd)
	cmd.parse(['cmd', '--flag', 'value', 'subcmd']) or { panic(err) }
}

// Helper functions

fn flag_should_be_set_fn(cmd &Command) ? {
	flag := cmd.flags.get_string('flag') ?
	assert flag == 'value'
}

fn flag_should_have_value_of_42_fn(cmd &Command) ? {
	flag := cmd.flags.get_string('flag') ?
	assert flag == 'value'
	value := cmd.flags.get_int('value') ?
	assert value == 42
}

fn flag_is_set_in_subcommand_fn(cmd &Command) ? {
	flag := cmd.flags.get_string('flag') or { panic(err) }
	assert flag == 'value'
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
