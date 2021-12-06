module cli

pub fn (mut cmd Command) add_flag_struct<T>() {
	default_struct := T{}
	$for field in T.fields {
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
		} $else {
			panic('cli error: invalid flag type')
		}

		for attr in field.attrs {
			value := attr.split(':')[1].trim_space()
			if attr.starts_with('cli_abbrev:') {
				flag.abbrev = value
			} else if attr.starts_with('cli_description:') {
				flag.description = value
			} else if attr.starts_with('cli_global:') {
				flag.global = if value.to_lower() == 'true' { true } else { false }
			} else if attr.starts_with('cli_required:') {
				flag.required = if value.to_lower() == 'true' { true } else { false }
			}
		}

		cmd.add_flag(flag)
	}
}

pub fn (flags []&Flag) get_struct<T>() ?T {
	mut res := T{}
	$for field in T.fields {
		flag := flags.get(field.name) ?
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
			return error('cli error: invalid flag type')
		}
	}
	return res
}
