# V CLI Refactor

## Changes

- build flag: `-g` -> `-d`, `--debug`

## Improvements

- Make tools path configurable in `v.mod`
- Option to force enable/disable rebuild in `v.mod`
- Add array type to flag parsing

## Design

### Required for Production
- [x] `init`: initializes new v project
- [x] `exec`: execute a tool defined in the project
- [] `run`: execute v file/module
- [] `build`: build v file/module
- [] `bin2v`: embed arbitrary file into v executable
- [] `test`: test v file/module
- [] `bench`: benchmark v file/module
- [] `fmt`: formats v file/module
- [] `vet` reporst likely mistakes in package
- [] `doc`: generates documentation for v file/module
- [] `repl`: launch v repl
- [] `clean`: remove temporary and cached files

- [] `search`: search for vpm module
- [] `install`: install vpm module
- [] `remove`: removes vpm module
- [] `update`: updates a vpm module
    - `--all`: updates all outdated modules
- [] `list`: lists vpm module
    - `--outdated`: lists outdated modules

### Required for V Development
- [x] `up`: run V self-updater
- [x] `self`: run V self-compiler
- [] `symlink`: create symbolic link for V
- [] `tracev`: produce a tracing version of the compiler
- [] `doctor`: display useful information about your system
- [] `doc-vlib`: Generate vlib module documentation
