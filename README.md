# vim-code-notes

A simple way to take notes on code in (neo)vim.

### Usage

Once installed, set the `g:code_notes#notes_root` variable first (see below).
This pairs best with a wiki plugin, like `lervag/wiki.vim`. I run this with my
`notes_root`, set to a subdirectory of my main wiki.

`:CodeNote` or `<leader>cn` without a visual selection will open a new file for the
current file. This will open a vertical split for notes on the current file.

`:CodeNoteVisual` or `<leader>cn` with a visual selection, will take the current visual
selection and produce a note file with that selection (or append it to the existing
file).

By default, we assume Markdown, so new files are created with markdown headers, and
visual selections are added to code fences. This can be changed, as outlined below.

Mappings can be changed, as outlined below.

### Installation

Can be installed with `vim-plug` or any other similar package manager with:

```vim
Plug 'CrossR/vim-code-notes'
```

### Config Options

```vim
" Where notes should be stored.
"
" Defaults to empty and MUST be set.
let g:code_notes#notes_root = "~/git/wiki/docs/code"

" Extension to be used for each note file.
" Effectively lets the filetype be picked.
"
" Defaults to ".md"
let g:code_notes#note_ext = ".md"

" Function to be called that will transform a file path
" into a path to be used for the note.
"
" Should be a function that takes one argument, the repo relative path.
" For a file like '~/git/vim-code-notes/plugin/code_notes.vim'
" The argument given is 'plugin/code_notes.vim'
" Any remaining '/' left in the path will be treated as folders,
" and created.
" Returns a string, for the notes path.
"
" Defaults to swapping all '/' -> '_'.
function! CodeNotePathFormat(repo_relative_path) abort
    return substitute(a:repo_relative_path, "/", "_", "g")
endfunction

let g:code_notes#note_name_format = "CodeNotePathFormat"

" Function to be called on file creation.
"
" Should be a function that takes one argument, the repo relative
" path. Returns a list of strings for each line to be added to the new
" file.
"
" Defaults to `# repo/relative_path.cpp` and a new line.
function! CodeNoteTemplate(file_name) abort
    return ["# " . a:file_name, ""]
endfunction

let g:code_notes#note_template = "CodeNoteTemplate"

" Function to be called that will format a visual selection.
"
" Should be a function that takes one argument, the list of visual selected lines.
" Returns a list of strings, for each of the lines to be inserted.
"
" Defaults to making a code fenced block of markdown, with the language included,
" based on the `filetype`.
function! CodeNoteVisualSelection(lines) abort
    let l:langage = &ft
    return ["", "```" . l:langage] + a:lines + ["```", ""]
endfunction

let g:code_notes#format_selection = "CodeNoteVisualSelection"
```

### Custom Binds

```vim
" Remap the follow function with the following.
" Replace <leader>cn to swap the bind.
" cn -> Code note
nmap <silent><buffer> <leader>cn <Plug>OpenNotesForFile
vmap <silent><buffer> <leader>cn <Plug>OpenNotesForFileVisual
```

### TODO

Follow ups, assuming its useful:

 - Sort out writing to file. It would be nicer to set the lines so the undo tree is
     correctly set. Ideally, we wouldn't save the file either, allowing backing out
     of making a note.
 - User config for root files, not just `.git`.
 - Index file, to contain the full table of contents of the notes.
 - Move command, for when `repo/a/b/c.cpp` moves to `repo/d/e/c.cpp`, relocate or link
     files.
 - Sign column/lightline etc support (i.e. anyway of saying "A notes file exists for
     this").
     - Could be useful to include specific versions of this...
 - More complex templates for notes files.
 - Parsing of certain sections for certain things. I.e. a `# TODO` section.
    -  That could be parsed out to be apart of the lightline support.
