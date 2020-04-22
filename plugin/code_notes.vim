" A simple code notes plugin for Vim
"
" Maintainer: Ryan Cross
" Email:      r.cross@lancaster.ac.uk
" License:    MIT license
"

let g:code_notes#notes_root = get(g:, "code_notes#notes_root", "")

function! s:warn_message(msg) abort
    echohl ErrorMsg
    echomsg a:msg
    echohl NONE
endfunction

function! s:get_file_template(file_name) abort
    return ["# " . a:file_name, ""]
endfunction

function! s:get_repo_relative_path(git_repo_path) abort
    let l:current_path = expand("%:p") " TODO: May want to pass this.

    let l:git_repo_name = fnamemodify(a:git_repo_path, ":t")
    let l:repo_relative_path = substitute(l:current_path, a:git_repo_path, "", "")

    return l:repo_relative_path[1:]
endfunction

function! code_notes#open_file() abort

    " Can't do anything without a notes folder.
    if g:code_notes#notes_root == ""
        call s:warn_message("g:code_notes#notes_root is not set!")
        return
    endif

    " The full repo path, and its name:
    "  /home/ryan/git/vim-code-notes -> git_repo_path
    "  vim-code-notes -> git_repo_name
    let l:git_repo_path = finddir(".git/..", expand("%:p:h") . ";")
    let l:git_repo_name = fnamemodify(l:git_repo_path, ":t")

    " The repository relative path:
    "  ~/git/vim-code-notes/plugin/code_notes.vim -> plugin/code_notes.vim
    let l:repo_relative_path = s:get_repo_relative_path(l:git_repo_path)

    " The formatted name for the note.
    "  plugin/code_notes.vim -> plugin_code_notes.vim
    "  TODO: Config option, to allow the folder formatting to be set.
    let l:note_file = substitute(l:repo_relative_path, "/", "_", "g")

    " The final path of where the note will live, relative to the
    " notes root.
    " TODO: Config option for extension.
    let l:note_path = l:git_repo_name . "/" . l:note_file . ".md"
    call s:warn_message(l:note_path)

    " Final bit of tidying to add on the notes_root, and check its
    " full formed.
    let l:relative_full_path = g:code_notes#notes_root . "/" . l:note_path
    let l:full_path = expand(simplify(l:relative_full_path))
    let l:note_folder = fnamemodify(l:full_path, ":h")

    " Make a folder to store the current note file in if needed.
    if !isdirectory(l:note_folder)
        call mkdir(l:note_folder, "p", 0755) " TODO: Config?
    endif

    call s:warn_message(l:full_path)
    " Make a file for the current note file, with a template.
    if !filereadable(l:full_path)
        call s:warn_message("Writing to file...")
        let l:file_template = s:get_file_template(l:repo_relative_path)
        call writefile(l:file_template, l:full_path)
    endif

    exec "80vsplit" l:full_path
endfunction

command! -nargs=0 OpenNotesForFile call code_notes#open_file()
