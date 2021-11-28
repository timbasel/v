module cli2

[heap]
pub struct Command {
pub mut:
	name        string
	usage       string
	description string
	version     string
	execute     fn (&Command)

	posix_mode      bool = true
	strict_flags    bool = true
	disable_help    bool
	disable_version bool
	disable_flags   bool
	sort_flags      bool
	sort_commands   bool

	commands []&Command
	flags    []&Flag
	args     []string

	parent  &Command = 0
	verbose bool // for debug: prints parsing information for command
}

pub fn (cmd &Command) is_root() bool {
	return isnil(cmd.parent)
}

pub fn (cmd &Command) root() &Command {
	if cmd.is_root() {
		return cmd
	}
	return cmd.parent.root()
}

pub fn (cmd &Command) full_name() string {
	if cmd.is_root() {
		return cmd.name
	}
	return cmd.parent.full_name() + ' $cmd.name'
}

pub fn (mut cmd Command) add_command(subcmd &Command) &Command {
	if cmd.commands.contains(subcmd.name) {
		println('cli error: Subcommand with name `$subcmd.name` already exists on command `$cmd.name`')
		exit(1)
	}
	cmd.commands << subcmd
	return subcmd
}

pub fn (mut cmd Command) add_commands(subcmds []&Command) {
	for subcmd in subcmds {
		cmd.add_command(subcmd)
	}
}

pub fn (mut cmd Command) add_flag(flag &Flag) &Flag {
	if cmd.flags.contains(flag.name) || (flag.abbrev != '' && cmd.flags.contains(flag.abbrev)) {
		println('cli error: Flag with name `$flag.name` already exists on command `$cmd.name`')
		exit(1)
	}
	cmd.flags << flag
	return flag
}

pub fn (mut cmd Command) add_flags(flags []&Flag) {
	for flag in flags {
		cmd.add_flag(flag)
	}
}

pub fn (mut cmd Command) parse(args []string) {
	if cmd.is_root() {
		cmd.setup()
	}

	mut i := 1
	for i < args.len {
		arg := args[i]

		if cmd.commands.contains(arg) {
			if cmd.verbose {
				println('$cmd.name - found command: $arg')
			}

			mut subcmd := cmd.commands.get(args[i]) or {
				println('cli error: Failed to get command `$arg` that should exit.')
				exit(1)
			}
			subcmd.parse(args[i..])
			return
		}

		if arg == '--' { // flag terminator
			if cmd.verbose {
				println('$cmd.name - found terminator')
			}
			cmd.args << args[(i + 1)..]
			break
		} else if !cmd.posix_mode && arg.starts_with('-') {
			if cmd.verbose {
				println('$cmd.name - found non posix flag: $arg')
			}
			i += cmd.parse_single_dash_flag(args[i..])
		} else if arg.starts_with('--') { // long flag
			if cmd.verbose {
				println('$cmd.name - found long flag: $arg')
			}
			i += cmd.parse_long_flag(args[i..])
		} else if arg.starts_with('-') { // short flag
			if cmd.verbose {
				println('$cmd.name - found short flag: $arg')
			}
			i += cmd.parse_short_flag(args[i..])
		} else {
			if cmd.verbose {
				println('$cmd.name - found arg: $arg')
			}
			cmd.args << arg
		}

		i++ // advance index to next arg
	}

	cmd.check_default_flags()
	cmd.check_required_flags()

	// no further arguments to parse, execute current command
	if !isnil(cmd.execute) {
		cmd.execute(cmd)
	}
}

fn (mut cmd Command) parse_single_dash_flag(args []string) int {
	mut name := args[0][1..] // remove leading `-`
	split := name.split_nth('=', 2)
	name = split[0]
	mut flag := cmd.flags.get(name) or {
		cmd.flags.get_abbrev(name) or {
			// given flag name not defined on command
			if cmd.strict_flags {
				println('cli error: No flag `--$name` defined on command `$cmd.name`')
				exit(1)
			}
			return 0 // flag name got consumed, but ignored
		}
	}

	flag.found = true

	if split.len == 2 {
		// -flag=value
		flag.parse([split[1]])
	} else if flag.kind == .bool {
		// -flag
		flag.parse(['true'])
	} else if args.len >= 2 {
		// -flag args ...
		return flag.parse(args[1..])
	} else {
		println('cli error: Flag `-$flag.name` requires an argument value')
		exit(1)
	}
	return 0
}

// parses long flag arguments, returns the number of additional arguments consumed
fn (mut cmd Command) parse_long_flag(args []string) int {
	mut name := args[0][2..] // remove leading `--`
	if name.len == 0 || name[0] == `-` || name[0] == `=` {
		println('cli error: Invalid flag syntax on command `$cmd.name`: $name')
		exit(1)
	}

	split := name.split_nth('=', 2)
	name = split[0]
	mut flag := cmd.flags.get(name) or {
		// given flag name not defined on command
		if cmd.strict_flags {
			println('cli error: No flag `--$name` defined on command `$cmd.name`')
			exit(1)
		}
		return 0 // flag name got consumed, but ignored
	}

	flag.found = true

	if split.len == 2 {
		// --flag=value
		flag.parse([split[1]])
	} else if flag.kind == .bool {
		// --flag
		flag.parse(['true'])
	} else if args.len >= 2 {
		// --flag args ...
		return flag.parse(args[1..])
	} else {
		println('cli error: Flag `--$flag.name` requires an argument value')
		exit(1)
	}
	return 0
}

// parses short flag arguments, returns the number of additional arguments consumed
fn (mut cmd Command) parse_short_flag(args []string) int {
	mut arg := args[0][1..] // remove leading `-`

	for arg.len > 0 {
		abbrev := arg[0..1]
		mut flag := cmd.flags.get_abbrev(abbrev) or {
			// given flag abbrev not defined on command
			if cmd.strict_flags {
				println('cli error: No abbreviated flag `-$abbrev` defined on command `$cmd.name`')
				exit(1)
			}

			arg = arg[1..] // consume abbrev that was not found
			continue
		}

		flag.found = true

		if arg.len > 2 && arg[1] == `=` {
			// -f=arg
			flag.parse([arg[2..]])
			return 0
		} else if flag.kind == .bool {
			// -f
			flag.parse(['true'])
			arg = arg[1..] // consume first abbrev flag
		} else if arg.len > 1 {
			// -farg
			flag.parse([arg[1..]])
			return 0
		} else if args.len >= 2 {
			// -f arg
			return flag.parse(args[1..])
		} else {
			println('cli error: Flag `$flag.name` (abbrev: `$flag.abbrev`) requires an argument value')
			exit(1)
		}
	}

	return 0
}

fn (mut cmd Command) setup() {
	if !cmd.disable_flags {
		cmd.add_default_flags()
	}
	cmd.add_default_commands()

	for mut flag in cmd.flags {
		flag.set_default()
	}

	if cmd.sort_flags {
		cmd.flags.sort(a.name < b.name)
	}
	if cmd.sort_commands {
		cmd.commands.sort(a.name < b.name)
	}

	for mut subcmd in cmd.commands {
		subcmd.parent = cmd
		subcmd.posix_mode = cmd.posix_mode

		for global_flag in cmd.flags.filter(it.global) {
			subcmd.add_flag(global_flag)
		}

		subcmd.setup()
	}
}

fn (mut cmd Command) add_default_flags() {
	if !cmd.disable_help && !cmd.flags.contains('help') {
		use_abbrev := !cmd.flags.contains_abbrev('h')
		cmd.add_flag(help_flag(use_abbrev))
	}
	if !cmd.disable_version && cmd.version != '' && !cmd.flags.contains('version') {
		use_abbrev := !cmd.flags.contains_abbrev('v')
		cmd.add_flag(version_flag(use_abbrev))
	}
}

fn (mut cmd Command) add_default_commands() {
	if !cmd.disable_help && !cmd.commands.contains('help') && cmd.is_root() {
		cmd.add_command(help_cmd())
	}
	if !cmd.disable_version && cmd.version != '' && !cmd.commands.contains('version') {
		cmd.add_command(version_cmd())
	}
}

fn (cmd &Command) check_default_flags() {
	if !cmd.disable_help && cmd.flags.contains('help') {
		help_flag := cmd.flags.get_bool('help')
		if help_flag {
			cmd.execute_help()
			exit(0)
		}
	} else if !cmd.disable_version && cmd.version != '' && cmd.flags.contains('version') {
		version_flag := cmd.flags.get_bool('version')
		if version_flag {
			version_cmd := cmd.commands.get('version') or { return } // ignore error and handle command normally
			version_cmd.execute(version_cmd)
			exit(0)
		}
	}
}

fn (cmd &Command) check_required_flags() {
	for flag in cmd.flags {
		if flag.required && !flag.found {
			full_name := cmd.full_name()
			println('Flag `$flag.name` is required by `$full_name`')
			exit(1)
		}
	}
}

pub fn (cmd Command) execute_help() {
	if cmd.commands.contains('help') {
		help_cmd := cmd.commands.get('help') or { return } // ignore error and handle command normally
		help_cmd.execute(help_cmd)
	} else {
		print(cmd.help_message())
	}
}

fn (cmds []&Command) get(name string) ?&Command {
	for cmd in cmds {
		if cmd.name == name {
			return cmd
		}
	}
	return error('Command `$name` not found.')
}

fn (cmds []&Command) contains(name string) bool {
	for cmd in cmds {
		if cmd.name == name {
			return true
		}
	}
	return false
}
