Usage example:

```v
module main

import os
import cli { Command, Flag }

fn main() {
	mut cmd := &Command{
		name: 'hello'
		execute: greet_func
	}

	cmd.add_flag(&Flag{ flag: .int, name: 'count', abbrev: 'c', value: ['1'] })
	cmd.add_flag(&Flag{ flag: .string, name: 'name', required: true })

	cmd.parse(os.args)
}

fn greet_func(cmd &Command) ? {
	count := cmd.flags.get_int('count') or { panic('Failed to get `count` flag: $err') }
	name := cmd.flags.get_string('name') or { panic('Failed to get `name` flag: $err') }

	for _ in 0 .. count {
		println('Hello $name')
	}
}
```
