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

function! code_notes#convert_file_to_path() abort
    let l:git_repo_path = finddir(".git/..", expand("%:p:h") . ";")
    let l:current_path = expand("%:p") " TODO: May want to pass this.

    let l:git_repo_name = fnamemodify(l:git_repo_path, ":t")
    let l:repo_relative_path = substitute(l:current_path, l:git_repo_path, "", "")

    " TODO: This may make sense to make into a user function.
    "       Would let the file structure of the notes be user defined.
    let l:formatted_name = substitute(l:repo_relative_path, "/", "_", "g")

    return l:git_repo_name . l:formatted_name
endfunction

function! code_notes#open_file() abort

    if g:code_notes#notes_root == ""
        call s:warn_message("g:code_notes#notes_root is not set!")
        return
    endif

    let l:note_path = code_notes#convert_file_to_path()
    let l:full_path = simplify(g:code_notes#notes_root . "/" . l:note_path)
    let l:note_folder = expand(fnamemodify(l:full_path, ":h"))

    if !isdirectory(l:note_folder)
        call mkdir(l:note_folder, "p", 0755) " TODO: Config?
    endif

    execute "keepalt split" . l:full_path
endfunction

command! -nargs=0 OpenNotesForFile call code_notes#open_file()
