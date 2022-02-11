# CLI

The `cli` module provides a declarative API for building modern commandline applications.

`cli` provides:

- Nested Subcommands 
- POSIX-compliant short and long flags by default
- Support for single-dash long flags
- Global and required flags
- Custom Validators
- Predefined Validators (on x64 Unix-based architectures)
- Automatic help generation
<!-- Future Goals: -->
<!-- - Automatic man page generation -->
<!-- - Automatic shell autocomplete generation for bash, zsh, fish and powershell -->
<!-- - Intelligent error suggestions -->
<!-- - Integration with a e.g. `config` module that mimicks the synergy between the `spf13/cobra` and `spf13/viper` go packages -->

## Usage

1. Create a root command (`cli.new()` creates a default command with the program name)
2. Add all flags and subcommands
	- available flag types: `bool`, `int`, `float`, `string`, `int_array`, `float_array`, `string_array`
3. Call `parse` on the root command with `os.args`
	- matching commands `execute` function is called
4. Get flag value by calling `cmd.flags.get_$type($name)` or `$flag.get_$type()`

## Examples

Basic Flags:

```v
module main

import cli { Command, Flag }
import os

fn main() {
	mut cmd := &Command{
		name: 'cmd'
	}
	host_flag := cmd.add_flag(&Flag{ kind: .string, name: 'host', description: 'Host of server', required: true })
	port_flag := cmd.add_flag(&Flag{ kind: .int, name: 'port', abbrev: 'p', description: 'Port of server', default: 8080 })
	verbose_flag := cmd.add_flag(&Flag{ kind: .bool, name: 'verbose', abbrev: 'v', description: 'Prints server information' })

	cmd.parse(os.args) or {
		println(err)
		exit(1)
	}

	host := host_flag.get_string() or { panic(err) }
	port := port_flag.get_int() or { panic(err) }
	verbose := verbose_flag.get_bool() or { panic(err) }

	if verbose {
		println('Starting server at $host:${port}...')
	} else {
		println('Starting server...')
	}
}
```

```
$ cmd --host localhost -v
Starting server at localhost:8080...
```

Struct Flags: 

```v
module main

import cli { Command }
import os

struct Flags {
	host    string [cli.description: 'Host of server'; cli.required: true]
	port    int    [cli.abbrev: 'p'; cli.description: 'Port of server'] = 8080
	verbose bool   [cli.abbrev: 'v'; cli.description: 'Prints server information']
}

fn main() {
	mut cmd := &Command{
		name: 'cmd'
	}

	cmd.add_flag_struct<Flags>()

	cmd.parse(os.args) or {
		println(err)
		exit(1)
	}

	flags := cmd.flags.get_struct<Flags>() or { panic(err) }

	if flags.verbose {
		println('Starting server at $flags.host:${flags.port}...')
	} else {
		println('Starting server...')
	}
}
```

```
$ cmd --host localhost -v
Starting server at localhost:8080...
```

Subcommands:

```v
module main

import cli { Command, Flag }
import os

fn main() {
	mut cmd := &Command{
		name: 'cmd'
	}

	cmd.add_command(&Command {
		name: 'start',
		description: 'Starts the server',
		execute: fn (cmd &Command) ? {
			println('Starting server...')
		}
	})
	cmd.add_command(stop_cmd())

	cmd.parse(os.args) or {
		println(err)
		exit(1)
	}
}

fn stop_cmd() &Command {
	return &Command{
		name: 'stop'
		description: 'Stops the server'
		execute: fn (cmd &Command) ? {
			println('Stopping server...')
		}
	}
}
```

```
$ cmd start
Starting server...
$ cmd stop
Stopping server...
```

Validators:

```v
module main

import cli { Command, Flag }
import os
import time

fn main() {
	mut cmd := &Command{
		name: 'cmd'
		usage: '<path>'
		validate: fn (cmd &Command) ? {
			if cmd.args.len != 1 {
				return error('Command `$cmd.name` expects exactly 1 argument (got: $cmd.args)')
			}
			if !os.exists(cmd.args[0]) {
				return error('No file found at `${cmd.args[0]}`')
			}
		}
		execute: cmd_fn
	}
	cmd.add_flag(&Flag{
		kind: .int
		name: 'year'
		abbrev: 'y'
		required: true
		validate: fn (flag &Flag) ? {
			year := flag.get_int() ?
			if year > time.now().year {
				return error('Flag `$flag.name` can\'t be in the future (got: $year)')
			}
		}
	})

	cmd.parse(os.args) or {
		println(err)
		exit(1)
	}
}

fn cmd_fn(cmd &Command) ? {
	year := cmd.flags.get_int('year') ?
	content := os.read_file(cmd.args[0]) ?
	println('Content: $content')
	println('Year: $year')
}
```

```
$ cmd --year 2018 ./non_existant_file.txt
No file found at `./non_existant_file.txt`

$ cmd --year 2042 ./existing_file.txt
Flag `year` can't be in the future (got: 2042)

$ cmd --year 2021 ./existing_file.text
Content: Test
Year: 2020
```