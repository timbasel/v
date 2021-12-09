import cli { Command }

struct Flags {
	ignore  bool   [cli.ignore]
	flag    string = 'Alice'
	number  int    = 42
	float   f64    [cli.abbrev: 'f']
	boolean bool   [cli.name: '-bool']
	alias   string [cli.aliases: 'foo, bar']
}

fn test_if_struct_flags_get_parsed() {
	mut cmd := &Command{
		name: 'cmd'
	}
	cmd.add_flag_struct<Flags>()
	cmd.parse(['cmd', '--flag', 'Bob', '-bool', '-f', '3.14159', '--foo', 'baz']) or { panic(err) }

	assert cmd.flags.any(it.name == 'ignore') == false

	flags := cmd.flags.get_struct<Flags>() or { panic(err) }

	assert flags.ignore == false
	assert flags.flag == 'Bob'
	assert flags.number == 42
	assert flags.boolean == true
	assert flags.float == 3.14159
	assert flags.alias == 'baz'
}
