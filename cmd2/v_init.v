module main

import cli { Command }
import os

fn init_cmd() Command {
	return Command {
		name: 'init',
		usage: '[directory]'
		description: 'Initializes a new V project in provided directory (default: \'.\').'
		execute: init_fn,
	}
}
		
fn init_fn(cmd Command) {
	mut directory := ""
	if cmd.args.len < 1 { 
		input := os.input('Create new V project in current directory? [Y/n]: ')
		if input != '' && input.to_lower() != 'y' {
			println('exit')
			exit(0)
		}
		directory = "."
	} else {
		directory = cmd.args[0]
	}

	mut path := os.join_path(os.getwd(), directory)
	if path.ends_with('/.') {
		path = path[0..path.len-2]
	} else {
		os.mkdir(os.file_name(path))
	}

	if os.exists(os.join_path(path, 'v.mod')) {
		println('Error: a V module already exists.')
		exit(3)
	}
	name := os.file_name(path)

	init_vmod(name, path)
	init_main(name, path)
	init_git_repo(name, path)
}

fn init_vmod(name string, path string) {
	if os.exists(os.join_path(path, 'v.mod')) {
		return
	}

	mut vmod := os.create(os.join_path(path, 'v.mod'))or {
		println(err)
		exit(1)
	}
	vmod.write_str(vmod_content(name, ''))
	vmod.close()
}

fn init_main(name string, path string) {
	if os.exists(os.join_path(path, '${name}.v')) || os.exists(os.join_path(path, 'src', '${name}.v')) {
		return
	}

	mut main := os.create(os.join_path(path, '${name}.v')) or {
		println(err)
		exit(2)
	}
	main.write_str(main_content())
	main.close()
}

fn init_git_repo(name string, path string) {
	if os.is_dir(os.join_path(path, '.git')) {
		return
	}
	os.exec('git init ${path}') or {
		println('Error: Failed to create git repository')
		exit(4)
	}

	if os.exists("${path}/.gitignore") {
		return
	}
	mut gitignore := os.create(os.join_path(path, '.gitignore')) or {
		// .gitignore is not required, just nice-to-have
		return
	}
	gitignore.write_str(gitignore_content(name))
	gitignore.close()
}

fn vmod_content(name string, description string) string {
	return 'Module {
	name: \'${name}\'
	description: \'${description}\'
	version: \'0.0.1\'
	dependencies: [],
}
'
}

fn main_content() string {
	return 'module main

fn main() {
	println(\'Hello World\')
}
'
}

fn gitignore_content(name string) string {
	return '# Binaries for programs and plugins
main
${name}
*.exe
*.exe~
*.so
*.dylib
*.dll
'
}
