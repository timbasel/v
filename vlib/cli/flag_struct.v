module cli

pub fn (mut cmd Command) add_flag_struct<T>() {
	default_struct := T{}
	$for field in T.fields {
		if !field.attrs.contains('cli.ignore') {
			mut flag := &Flag{
				kind: .bool
				name: field.name
			}

			$if field.typ is bool {
				flag.kind = .bool
				flag.default = default_struct.$(field.name)
			} $else $if field.typ is int {
				flag.kind = .int
				flag.default = default_struct.$(field.name)
			} $else $if field.typ is f64 {
				flag.kind = .float
				flag.default = default_struct.$(field.name)
			} $else $if field.typ is string {
				flag.kind = .string
				flag.default = default_struct.$(field.name)
			} $else $if field.typ is []int {
				flag.kind = .int_array
				flag.default = default_struct.$(field.name)
			} $else $if field.typ is []f64 {
				flag.kind = .float_array
				flag.default = default_struct.$(field.name)
			} $else $if field.typ is []string {
				flag.kind = .string_array
				flag.default = default_struct.$(field.name)
			}

			for attr in field.attrs {
				value := attr.split(':')[1].trim_space()
				if attr.starts_with('cli.name:') {
					flag.name = value
				} else if attr.starts_with('cli.abbrev:') {
					flag.abbrev = value
				} else if attr.starts_with('cli.aliases:') {
					flag.aliases = value.split(',').map(it.trim_space())
				} else if attr.starts_with('cli.description:') {
					flag.description = value
				} else if attr.starts_with('cli.global:') {
					flag.global = if value.to_lower() == 'true' { true } else { false }
				} else if attr.starts_with('cli.required:') {
					flag.required = if value.to_lower() == 'true' { true } else { false }
				}
			}

			cmd.add_flag(flag)
		}
	}
}

pub fn (flags []&Flag) get_struct<T>() ?T {
	mut res := T{}
	$for field in T.fields {
		if !field.attrs.contains('cli.ignore') {
			name_attrs := field.attrs.filter(it.starts_with('cli.name:'))
			name := if name_attrs.len > 0 {
				name_attrs[0].split(':')[1].trim_space()
			} else {
				field.name
			}

			flag := flags.get(name) ?
			$if field.typ is bool {
				res.$(field.name) = flag.get_bool() ?
			} $else $if field.typ is int {
				res.$(field.name) = flag.get_int() ?
			} $else $if field.typ is f64 {
				res.$(field.name) = flag.get_float() ?
			} $else $if field.typ is string {
				res.$(field.name) = flag.get_string() ?
			} $else $if field.typ is []int {
				res.$(field.name) = flag.get_int_array() ?
			} $else $if field.typ is []f64 {
				res.$(field.name) = flag.get_float_array() ?
			} $else $if field.typ is []string {
				res.$(field.name) = flag.get_string_array() ?
			} $else {
				return cli_error('invalid flag type')
			}
		}
	}
	return res
}
