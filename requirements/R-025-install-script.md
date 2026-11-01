---
type: behavior
tags: [install]
status: active
---

# The install script

One line from the README installs clacc into `~/.local/bin`, and running it again updates it:

```sh
curl -fsSL https://raw.githubusercontent.com/zauberzeug/clacc/main/install.sh | bash
```

`install.sh` downloads `clacc` from `main`, so whatever lands on `main` reaches users (R-028).

- A failed download, or one whose `--help` does not start with the word `clacc`, such as a web page, an empty file or a file cut off, keeps the installed clacc and leaves no temporary file.
- An installer cut off on its way does nothing, because only its last line starts anything.
- A folder that is not on the `PATH` is named.
