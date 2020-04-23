" A simple code notes plugin for Vim
"
" Maintainer: Ryan Cross
" Email:      r.cross@lancaster.ac.uk
" License:    MIT license
"

" Warning message to the user, non-blocking.
function! s:warn_message(msg) abort
    echohl ErrorMsg
    echomsg a:msg
    echohl NONE
endfunction

" Get the path of the current file, relative to the project root.
" For a file like '~/git/vim-code-notes/plugin/code_notes.vim'
" The result given is 'plugin/code_notes.vim'
function! s:get_repo_relative_path(git_repo_path) abort
    let l:current_path = expand("%:p")

    let l:git_repo_name = fnamemodify(a:git_repo_path, ":t")
    let l:repo_relative_path = substitute(l:current_path, a:git_repo_path, "", "")

    return l:repo_relative_path[1:]
endfunction

" Get the currently visually selected lines.
" Taken from
" https://stackoverflow.com/questions/1533565/
function! s:get_visual_selection() abort
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return lines
endfunction

" Get the repository path for the current file.
function! s:get_repo_path() abort
    let l:potential_repo = ""
    for root_dir in g:code_notes#root_dirs
        let l:potential_repo = finddir(root_dir . "/..", expand("%:p:h") . ";")

        if l:potential_repo != ""
            let l:git_repo_path = l:potential_repo
            break
        endif
    endfor

    return l:potential_repo
endfunction

" Get the full note path, and the repo relative path for the current file.
"
" That is, for a root of ~/git/code_notes
" and a file of ~/git/vim-code-notes/plugin/code_notes.vim
"
" Return ~/git/code_notes/vim-code_notes/plugin_code_notes.vim.md
" (With user formatting and extension)
function! s:get_note_paths() abort
    " Get the full repo path, and its name, i.e.:
    "  /home/ryan/git/vim-code-notes -> git_repo_path
    "  vim-code-notes -> git_repo_name
    let l:git_repo_path = s:get_repo_path()
    let l:git_repo_name = fnamemodify(l:git_repo_path, ":t")

    " The repository relative path:
    "  ~/git/vim-code-notes/plugin/code_notes.vim -> plugin/code_notes.vim
    let l:repo_relative_path = s:get_repo_relative_path(l:git_repo_path)

    " The formatted name for the note.
    "  plugin/code_notes.vim -> plugin_code_notes.vim
    let l:note_file = call(g:code_notes#note_name_format, [l:repo_relative_path])

    " The final path of where the note will live, relative to the notes root.
    let l:note_path = l:git_repo_name . "/" . l:note_file . g:code_notes#note_ext

    " Final bit of tidying to add on the notes_root, and check its full
    " formed.
    let l:relative_full_path = g:code_notes#notes_root . "/" . l:note_path
    let l:full_path = expand(simplify(l:relative_full_path))

    return [l:full_path, l:repo_relative_path]
endfunction

" Default file template.
" List of strings, with each item a line in the new file.
" file_name argument is a repository relative path.
function! code_notes#get_file_template(file_name) abort
    return ["# " . a:file_name, ""]
endfunction

" Default function for formatting lines from visual selection.
" List of strings, with each item a line of the visual selection.
function! code_notes#format_lines(lines) abort
    let l:langage = &ft
    return ["", "```" . l:langage] + a:lines + ["```", ""]
endfunction

" Format the given file path in whatever way.
" For a file like '~/git/vim-code-notes/plugin/code_notes.vim'
" The argument given is 'plugin/code_notes.vim'
" Any remaining '/' left in the path will be treated as folders,
" and created.
function! code_notes#format_note_path(repo_relative_path) abort
    return substitute(a:repo_relative_path, "/", "_", "g")
endfunction

" Function that will return 1 if a note is available for the current file.
function! code_notes#check_for_note() abort
    let l:note_paths = s:get_note_paths()
    let l:full_path = l:note_paths[0]

    " If there is a file, then return True.
    if filereadable(l:full_path)
        return 1
    endif

    " If there is no file, but a buffer, return True.
    if buflisted(bufname(l:full_path))
        return 1
    endif

    " Otherwise, there is no note.
    return 0
endfunction

" Open a notes file in a vertical split for the given file.
function! code_notes#open_file(lines) abort

    " Can't do anything without a notes folder.
    if g:code_notes#notes_root == ""
        call s:warn_message("g:code_notes#notes_root is not set!")
        return
    endif

    let l:note_paths = s:get_note_paths()
    let l:full_path = l:note_paths[0]
    let l:repo_relative_path = l:note_paths[1]
    let l:note_folder = fnamemodify(l:full_path, ":h")

    " Make a folder to store the current note file in if needed.
    if !isdirectory(l:note_folder)
        call mkdir(l:note_folder, "p", 0755)
    endif

    " Open the file in a vertical split.
    if buflisted(bufname(l:full_path))
        let l:bufmap = map(
                    \ range(1, winnr('$')),
                    \ '[bufname(winbufnr(v:val)), v:val]'
                    \ )
        let l:thewindow = filter(
                    \ bufmap,
                    \ 'v:val[0] =~ bufname(l:full_path)'
                    \ )[0][1]
        execute l:thewindow 'wincmd w'
    else
        exec "80vsplit" l:full_path
    endif

    " Append the needed lines to the top of the file if its a new file.
    "
    " append was used over writefile to maintain the undo tree, and
    " not always make the file.
    if line('$') == 1 && getline(1) == ''
        let l:file_template = call(g:code_notes#note_template, [l:repo_relative_path])
        let l:write_failed = append(0, l:file_template)
        if l:write_failed
            call s:warn_message("Failed to append template to file...")
        endif
    endif

    " Append the visual selection lines to the bottom of the file.
    if a:lines != []
        let l:write_failed = append(line('$'), a:lines)
        if l:write_failed
            call s:warn_message("Failed to append lines to file...")
        endif
    endif
endfunction

" Wrapper of open_file, that passes over the currently selected lines.
function! code_notes#open_file_with_selection() abort
    let l:visual_lines = s:get_visual_selection()
    let l:formatted_lines = call(g:code_notes#format_selection, [l:visual_lines])
    call code_notes#open_file(l:formatted_lines)
endfunction
