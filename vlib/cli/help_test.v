module cli

fn test_help_message() {
	mut cmd := &Command{
		name: 'cmd'
		description: 'description'
		commands: [
			&Command{
				name: 'subcmd1'
				description: 'subcommand'
			},
			&Command{
				name: 'subcmd2'
				description: 'another subcommand'
			},
		]
		flags: [
			&Flag{
				kind: .string
				name: 'str'
				description: 'string flag'
			},
			&Flag{
				kind: .bool
				name: 'bool'
				description: 'bool flag'
				abbrev: 'b'
			},
			&Flag{
				kind: .string
				name: 'required'
				abbrev: 'r'
				required: true
			},
		]
	}
	assert cmd.help_message() == r'Usage: cmd [flags] [commands]

description

Flags:
      --str           string flag
  -b  --bool          bool flag
  -r  --required      (required)

Commands:
  subcmd1             subcommand
  subcmd2             another subcommand
'

	cmd.posix_mode = false
	assert cmd.help_message() == r'Usage: cmd [flags] [commands]

description

Flags:
      -str            string flag
  -b  -bool           bool flag
  -r  -required       (required)

Commands:
  subcmd1             subcommand
  subcmd2             another subcommand
'
}
