import cli { Command, Flag }

fn test_if_command_parses_empty_args() {
	mut cmd := &Command{
		name: 'command'
		execute: empty_func
	}
	cmd.parse(['command'])
	assert cmd.name == 'command' && compare_arrays(cmd.args, [])
}

fn test_if_command_parses_args() {
	mut cmd := &Command{
		name: 'command'
		execute: empty_func
	}
	cmd.parse(['command', 'arg0', 'arg1'])
	assert cmd.name == 'command' && compare_arrays(cmd.args, ['arg0', 'arg1'])
}

fn test_if_subcommands_parse_args() {
	mut cmd := &Command{
		name: 'command'
	}
	mut subcmd := &Command{
		name: 'subcommand'
		execute: if_subcommands_parse_args_func
	}
	cmd.add_command(mut subcmd)
	cmd.parse(['command', 'subcommand', 'arg0', 'arg1'])
}

fn if_subcommands_parse_args_func(cmd &Command) {
	assert cmd.name == 'subcommand' && compare_arrays(cmd.args, ['arg0', 'arg1'])
}

fn test_if_command_has_default_help_subcommand() {
	mut cmd := &Command{
		name: 'command'
	}
	cmd.parse(['command'])
	assert has_command(cmd, 'help')
}

fn test_if_command_has_default_version_subcommand_if_version_is_set() {
	mut cmd := &Command{
		name: 'command'
		version: '1.0.0'
	}
	cmd.parse(['command'])
	assert has_command(cmd, 'version')
}

fn flag_should_be_set(cmd &Command) {
	flag := cmd.flags.get_string('flag') or { panic(err) }
	assert flag == 'value'
}

fn test_if_flag_gets_set() {
	mut cmd := &Command{
		name: 'command'
		execute: flag_should_be_set
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.parse(['command', '-flag', 'value'])
}

fn test_if_flag_gets_set_with_abbrev() {
	mut cmd := &Command{
		name: 'command'
		execute: flag_should_be_set
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
		abbrev: 'f'
	})
	cmd.parse(['command', '-f', 'value'])
}

fn test_if_flag_gets_set_with_long_arg() {
	mut cmd := &Command{
		name: 'command'
		execute: flag_should_be_set
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
		abbrev: 'f'
	})
	cmd.parse(['command', '--flag', 'value'])
}

fn flag_should_have_value_of_42(cmd &Command) {
	flag := cmd.flags.get_string('flag') or { panic(err) }
	assert flag == 'value'
	value := cmd.flags.get_int('value') or { panic(err) }
	assert value == 42
}

fn test_if_multiple_flags_get_set() {
	mut cmd := &Command{
		name: 'command'
		execute: flag_should_have_value_of_42
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.add_flag(&Flag{
		kind: .int
		name: 'value'
	})
	cmd.parse(['command', '-flag', 'value', '-value', '42'])
}

fn test_if_required_flags_get_set() {
	mut cmd := &Command{
		name: 'command'
		execute: flag_should_have_value_of_42
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
	cmd.parse(['command', '-flag', 'value', '-value', '42'])
}

fn flag_is_set_in_subcommand(cmd &Command) {
	flag := cmd.flags.get_string('flag') or { panic(err) }
	assert flag == 'value'
}

fn test_if_flag_gets_set_in_subcommand() {
	mut cmd := &Command{
		name: 'command'
		execute: empty_func
	}
	mut subcmd := &Command{
		name: 'subcommand'
		execute: flag_is_set_in_subcommand
	}
	subcmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.add_command(mut subcmd)
	cmd.parse(['command', 'subcommand', '-flag', 'value'])
}

fn test_if_global_flag_gets_set_in_subcommand() {
	mut cmd := &Command{
		name: 'command'
		execute: empty_func
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
		global: true
	})
	mut subcmd := &Command{
		name: 'subcommand'
		execute: flag_is_set_in_subcommand
	}
	cmd.add_command(mut subcmd)
	cmd.parse(['command', '-flag', 'value', 'subcommand'])
}

fn test_command_setup() {
	mut cmd := &Command{
		name: 'root'
		commands: [
			&Command{
				name: 'child'
				commands: [
					&Command{
						name: 'child-child'
					},
				]
			},
		]
	}
	assert isnil(cmd.commands[0].parent)
	assert isnil(cmd.commands[0].commands[0].parent)
	cmd.parse([''])
	assert cmd.commands[0].parent.name == 'root'
	assert cmd.commands[0].commands[0].parent.name == 'child'
}

// helper functions
fn empty_func(cmd &Command) {
}

fn has_command(cmd &Command, name string) bool {
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
