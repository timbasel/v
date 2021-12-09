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
				description: 'a string flag'
			},
			&Flag{
				kind: .bool
				name: 'bool'
				description: 'a bool flag'
				abbrev: 'b'
			},
			&Flag{
				kind: .string
				name: 'required'
				abbrev: 'r'
				description: 'a required flag'
				required: true
			},
			&Flag{
				kind: .string
				name: '-custom'
				description: 'a custom flag'
			},
			&Flag{
				kind: .string
				name: '--custom-abbrev'
				abbrev: 'c'
				description: 'another custom flag'
			},
		]
	}
	assert cmd.help_message() == r'Usage: cmd [flags] [commands]

description

Flags:
      --str              a string flag
  -b  --bool             a bool flag
  -r  --required         a required flag (required)
      -custom            a custom flag
  -c  --custom-abbrev    another custom flag

Commands:
  subcmd1                subcommand
  subcmd2                another subcommand
'
}
