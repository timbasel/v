module cli

pub fn no_args(cmd &Command) ? {
	if cmd.args.len > 0 {
		return error('command `$cmd.name` does not take any arguments (got: $cmd.args)')
	}
}

pub fn minimum_number_of_args(n int) CmdFunction {
	$if x64 && !windows {
		return fn [n] (cmd &Command) ? {
			if cmd.args.len < n {
				return error('command `$cmd.name` expects at least ${n_arguments(n)} (got: $cmd.args.len)')
			}
		}
	} $else {
		cli_panic('predefined validators are currently only support on x64 unix-like systems')
	}
}

pub fn maximum_number_of_args(n int) CmdFunction {
	$if x64 && !windows {
		return fn [n] (cmd &Command) ? {
			if cmd.args.len > n {
				return error('command `$cmd.name` expects at most ${n_arguments(n)} (got: $cmd.args.len)')
			}
		}
	} $else {
		cli_panic('predefined validators are currently only support on x64 unix-like systems')
	}
}

pub fn exact_number_of_args(n int) CmdFunction {
	$if x64 && !windows {
		return fn [n] (cmd &Command) ? {
			if cmd.args.len != n {
				return error('command `$cmd.name` expects exactly ${n_arguments(n)} (got: $cmd.args.len)')
			}
		}
	} $else {
		cli_panic('predefined validators are currently only support on x64 unix-like systems')
	}
}

pub fn number_of_args_between(min int, max int) CmdFunction {
	$if x64 && !windows {
		return fn [min, max] (cmd &Command) ? {
			if cmd.args.len < min || cmd.args.len > max {
				return error('command `$cmd.name` expects between $min and $max arguments (got: $cmd.args.len)')
			}
		}
	} $else {
		cli_panic('predefined validators are currently only support on x64 unix-like systems')
	}
}

pub fn only_valid_args(valid_args []string) CmdFunction {
	$if x64 && !windows {
		return fn [valid_args] (cmd &Command) ? {
			for arg in cmd.args {
				if !valid_args.contains(arg) {
					return error('invalid argument `$arg` for Command `$cmd.name` (allowed arguments: `$valid_args`')
				}
			}
		}
	} $else {
		cli_panic('predefined validators are currently only support on x64 unix-like systems')
	}
}

fn n_arguments(n int) string {
	if n == 1 {
		return '$n argument'
	} else {
		return '$n arguments'
	}
}
