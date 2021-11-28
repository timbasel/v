import cli2 { Command, Flag }

fn test_if_command_parses_empty_args() {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.parse(['cmd'])

	assert cmd.name == 'cmd'
	assert compare_arrays(cmd.args, [])
}

fn test_if_command_execute_fn_is_called() {
	mut called := false
	mut called_ref := &called

	mut cmd := &Command{
		name: 'cmd'
		execute: fn [mut called_ref] (cmd &Command) {
			unsafe {
				*called_ref = true
			}
		}
	}
	cmd.parse(['cmd'])

	assert called == true
}

fn test_if_command_parses_args() {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.parse(['cmd', 'arg0', 'arg1'])

	assert cmd.name == 'cmd'
	assert compare_arrays(cmd.args, ['arg0', 'arg1'])
}

fn test_if_subcommand_execute_fn_is_called() {
	mut called := false
	mut called_ref := &called

	mut cmd := &Command{
		name: 'cmd'
	}
	subcmd := &Command{
		name: 'subcmd'
		execute: fn [mut called_ref] (cmd &Command) {
			unsafe {
				*called_ref = true
			}
		}
	}
	cmd.add_command(subcmd)
	cmd.parse(['cmd', 'subcmd'])

	assert called == true
}

fn test_if_correct_subcommand_is_executed() {
	mut subcmd1_called := false
	mut subcmd1_called_ref := &subcmd1_called
	mut subcmd2_called := false
	mut subcmd2_called_ref := &subcmd2_called

	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_command(&Command{
		name: 'subcmd1'
		execute: fn [mut subcmd1_called_ref] (cmd &Command) {
			unsafe {
				*subcmd1_called_ref = true
			}
		}
	})
	cmd.add_command(&Command{
		name: 'subcmd2'
		execute: fn [mut subcmd2_called_ref] (cmd &Command) {
			unsafe {
				*subcmd2_called_ref = true
			}
		}
	})

	cmd.parse(['cmd'])
	assert subcmd1_called == false
	assert subcmd2_called == false

	cmd.parse(['cmd', 'subcmd1'])
	assert subcmd1_called == true
	assert subcmd2_called == false

	cmd.parse(['cmd', 'subcmd2'])
	assert subcmd1_called == true
	assert subcmd2_called == true
}

fn test_if_subcommand_parses_args() {
	mut cmd := &Command{
		name: 'cmd'
	}
	mut subcmd := &Command{
		name: 'subcmd'
		execute: fn (cmd &Command) {
			assert cmd.name == 'subcmd'
			assert compare_arrays(cmd.args, ['arg0', 'arg1'])
		}
	}
	cmd.add_command(subcmd)
	cmd.parse(['cmd', 'subcmd', 'arg0', 'arg1'])
}

fn test_if_command_sets_parent_on_subcmd() {
	mut cmd := &Command{
		name: 'cmd'
		commands: [
			&Command{
				name: 'subcmd'
				commands: [
					&Command{
						name: 'subsubcmd'
					},
				]
			},
		]
	}

	assert isnil(cmd.commands[0].parent)
	assert isnil(cmd.commands[0].commands[0].parent)
	cmd.parse([])
	assert cmd.commands[0].parent.name == 'cmd'
	assert cmd.commands[0].commands[0].parent.name == 'subcmd'
}

fn test_if_command_sets_flag() {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) {
			flag := cmd.flags.get_string('flag')
			assert flag == 'value'
		}
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
	})
	cmd.parse(['cmd', '--flag', 'value'])
}

fn test_if_command_sets_abbrev_flag() {
	mut cmd := &Command{
		name: 'cmd'
		execute: fn (cmd &Command) {
			flag := cmd.flags.get_string('flag')
			assert flag == 'value'
		}
	}
	cmd.add_flag(&Flag{
		kind: .string
		name: 'flag'
		abbrev: 'f'
	})
	cmd.parse(['cmd', '-f', 'value'])
}

/*
Helper functions
*/

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
