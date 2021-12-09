import cli { Command }

struct Flags {
	boolean bool   [cli.name: '-bool']
	float   f64    [cli.abbrev: 'f']
	name    string = 'Alice'
	age     int    = 42
}

fn test_if_struct_flags_get_parsed() {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_flag_struct<Flags>()
	cmd.parse(['cmd', '-bool', '-f', '3.14159', '--name', 'Bob']) or { panic(err) }
	flags := cmd.flags.get_struct<Flags>() or { panic(err) }

	assert flags.boolean == true
	assert flags.float == 3.14159
	assert flags.name == 'Bob'
	assert flags.age == 42
}
