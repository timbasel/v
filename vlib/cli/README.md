Usage example:

```v
module main

import os
import cli { Command }

fn main() {
	mut app := &Command{
		name: 'example-app'
		description: 'example-app'
		execute: fn (cmd &Command) ? {
			println('hello app')
			return
		}
		commands: [
			&Command{
				name: 'sub'
				execute: fn (cmd &Command) ? {
					println('hello subcommand')
					return
				}
			},
		]
	}
	app.parse(os.args)
}
```
