module cli

import os

pub fn new() &Command {
	return &Command{
		name: os.file_name(os.args[0])
	}
}

// Command is a structured representation of a single command
// or chain of commands.
[heap]
pub struct Command {
pub mut:
	name        string              [required]
	aliases     []string
	usage       string
	description string
	version     string
	validate    fn (cmd &Command) ?
	execute     fn (cmd &Command) ?

	strict_flags    bool = true
	disable_help    bool
	disable_version bool
	disable_flags   bool
	sort_flags      bool
	sort_commands   bool

	required_args int

	commands []&Command
	flags    []&Flag
	args     []string

	parent  &Command = 0
	verbose bool // for debug only: prints parsing information for command
}

// is_root returns `true` if this `Command` has no parents.
pub fn (cmd &Command) is_root() bool {
	return isnil(cmd.parent)
}

// root returns the root `Command` of the command chain.
pub fn (cmd &Command) root() &Command {
	if cmd.is_root() {
		return cmd
	}
	return cmd.parent.root()
}

// full_name returns the full `string` representation of all commands int the chain.
pub fn (cmd &Command) full_name() string {
	if cmd.is_root() {
		return cmd.name
	}
	return cmd.parent.full_name() + ' $cmd.name'
}

// add_command adds a subcommand to the commands; returns reference of the provided subcommand
pub fn (mut cmd Command) add_command(subcmd &Command) &Command {
	if cmd.name == '' {
		panic("cli error: command name can't be empty")
	} else if cmd.name.contains(' ') {
		panic('cli error: comand name must be a single word')
	} else if cmd.commands.contains(subcmd.name) {
		panic('cli error: Command with the name `$subcmd.name` already exists')
	}
	for alias in subcmd.aliases {
		if cmd.commands.contains(alias) {
			panic('cli error: Command with the name `$alias` already exists')
		}
	}
	cmd.commands << subcmd
	return subcmd
}

// add_commands adds the `commands` array of `command`s as subcommands.
pub fn (mut cmd Command) add_commands(subcmds []&Command) {
	for subcmd in subcmds {
		cmd.add_command(subcmd)
	}
}

// add_flag adds a flag to the command; returns reference of the provided flag
pub fn (mut cmd Command) add_flag(flag &Flag) &Flag {
	if cmd.flags.contains(flag.name) || cmd.flags.contains_abbrev(flag.abbrev) {
		panic('Flag with the name `$flag.name` already exists')
	}
	for alias in flag.aliases {
		if cmd.flags.contains(alias) || cmd.flags.contains_abbrev(alias) {
			panic('Flag with the name `$flag.name` already exists')
		}
	}
	cmd.flags << flag
	return flag
}

// add_flags adds the array `flags` to this `Command`.
pub fn (mut cmd Command) add_flags(flags []&Flag) {
	for flag in flags {
		cmd.add_flag(flag)
	}
}

pub fn (mut cmd Command) parse(args []string) ? {
	if cmd.is_root() {
		cmd.setup() ?
	}

	mut i := 1 // skip program name
	for i < args.len {
		mut arg := args[i]

		if cmd.commands.contains(arg) { // command
			if cmd.verbose {
				println('$cmd.name - found command: $arg')
			}
			mut subcmd := cmd.commands.get(arg) or {
				panic('cli error: failed to get command `$arg` that should exist')
			}
			return subcmd.parse(args[i..])
		} else if arg == '--' { // flag terminator
			if cmd.verbose {
				println('$cmd.name - found terminator')
			}
			cmd.args << args[(i + 1)..]
			break
		} else if arg.starts_with('-') {
			if cmd.verbose {
				println('$cmd.name - found flag: $arg')
			}
			i += cmd.flags.parse(args[i..], cmd.strict_flags) ?
		} else {
			if cmd.verbose {
				println('$cmd.name - found argument: $arg')
			}
			cmd.args << arg
		}

		i++ // advance to next argument
	}

	cmd.check_default_flags() ?
	cmd.check_required_flags() ?

	if !isnil(cmd.validate) {
		cmd.validate(cmd) ?
	}

	if !isnil(cmd.execute) {
		cmd.execute(cmd) ?
	} else if cmd.commands.len > 0 {
		cmd.execute_help() ?
	}
}

fn (mut cmd Command) setup() ? {
	if !cmd.disable_flags {
		cmd.add_default_flags()
	}
	cmd.add_default_commands()

	for mut flag in cmd.flags {
		flag.setup() ?
	}

	if cmd.sort_flags {
		cmd.flags.sort(a.name < b.name)
	}
	if cmd.sort_commands {
		cmd.commands.sort(a.name < b.name)
	}

	for mut subcmd in cmd.commands {
		subcmd.parent = cmd
		subcmd.verbose = cmd.verbose

		for global_flag in cmd.flags.filter(it.global) {
			subcmd.add_flag(global_flag)
		}

		subcmd.setup() ?
	}
}

fn (mut cmd Command) add_default_flags() {
	if !cmd.disable_help && !cmd.flags.contains('help') {
		use_help_abbrev := !cmd.flags.contains('h')
		cmd.add_flag(help_flag(use_help_abbrev))
	}
	if !cmd.disable_version && cmd.version != '' && !cmd.flags.contains('version') {
		use_version_abbrev := !cmd.flags.contains('v')
		cmd.add_flag(version_flag(use_version_abbrev))
	}
}

fn (mut cmd Command) add_default_commands() {
	if !cmd.disable_help && !cmd.commands.contains('help') && cmd.is_root() && cmd.commands.len > 0 {
		cmd.add_command(help_cmd())
	}
	if !cmd.disable_version && cmd.version != '' && !cmd.commands.contains('version')
		&& cmd.commands.len > 0 {
		cmd.add_command(version_cmd())
	}
}

fn (cmd &Command) check_default_flags() ? {
	if !cmd.disable_help && cmd.flags.contains('help') {
		help_flag := cmd.flags.get_bool('help') ?
		if help_flag {
			cmd.execute_help() ?
			exit(0)
		}
	} else if !cmd.disable_version && cmd.version != '' && cmd.flags.contains('version') {
		version_flag := cmd.flags.get_bool('version') ?
		if version_flag {
			version_cmd := cmd.commands.get('version') ?
			version_cmd.execute(version_cmd) ?
			exit(0)
		}
	}
}

fn (cmd &Command) check_required_flags() ? {
	for flag in cmd.flags {
		if flag.required && !flag.found {
			return error('cli error: flag `$flag.name` is required by `$cmd.full_name()`')
		}
	}
}

pub fn (cmd &Command) execute_help() ? {
	if cmd.commands.contains('help') {
		help_cmd := cmd.commands.get('help') ?
		help_cmd.execute(help_cmd) ?
	} else {
		print(cmd.help_message())
	}
}

fn (cmds []&Command) get(name string) ?&Command {
	for cmd in cmds {
		if cmd.name == name {
			return cmd
		} else if cmd.aliases.contains(name) {
			return cmd
		}
	}
	return error('cli error: no command `$name` found')
}

fn (cmds []&Command) contains(name string) bool {
	cmds.get(name) or { return false }
	return true
}
