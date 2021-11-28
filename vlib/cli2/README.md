# CLI

`cli` is a module for creating modern command line interfaces.

```v
module main 

import cli
import os

fn main() {
  cmd := cli.new()

  flag := cmd.add_flag(&Flag{
    name: '-prod'
    abbrev: 'p'
  })

  cmd.parse(os.args)
}
```