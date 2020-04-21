# vim-code-notes

A simple way to take notes on code in (neo)vim.

Usage idea:

 - Install plugin, set a "notes folder".
 - When in a file, running a command will generate a notes file for that file.
    - That is, for `oni2/src/Core/Filter.re` it would make
        `notes/oni2/src/Core/Filter.re.md`. (Perhaps have a function option to set the
        way that path is generated).
 - The paths should be relative to the git repo root. This makes it portable across
     machines.
 - Highlighting lines imports them to be commented on.

Follow ups, assuming its useful:

 - Move command, for when `repo/a/b/c.cpp` moves to `repo/d/e/c.cpp`, relocate or link
     files.
 - Sign column/lightline etc support (i.e. anyway of saying "A notes file exists for
     this").
     - Could be useful to include specific versions of this...
 - Templates for notes files.
 - Parsing of certain sections for certain things. I.e. a `# TODO` section.
    -  That could be parsed out to be apart of the lightline support.
 - Index file, to contain the full contents of the notes.
