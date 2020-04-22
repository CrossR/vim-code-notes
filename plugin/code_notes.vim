" A simple code notes plugin for Vim
"
" Maintainer: Ryan Cross
" Email:      r.cross@lancaster.ac.uk
" License:    MIT license
"

let g:code_notes#notes_root = get(g:, "code_notes#notes_root", "")
let g:code_notes#note_ext = get(g:, "code_notes#note_ext", ".md")
let g:code_notes#note_name_format = get(g:, "code_notes#note_name_format", "code_notes#format_note_path")
let g:code_notes#note_template = get(g:, "code_notes#note_template", "code_notes#get_file_template")
let g:code_notes#format_selection = get(g:, "code_notes#format_selection", "code_notes#format_lines")

command! -nargs=0 CodeNote call code_notes#open_file([])
command! -nargs=0 -range CodeNoteVisual call code_notes#open_file_with_selection()

" <leader>cn -> Code-Note
nnoremap <silent><buffer> <Plug>OpenNotesForFile :
            \<C-U>call code_notes#open_file([])<CR>
if !hasmapto('<Plug>OpenNotesForFile')
    nmap <silent><buffer> <leader>cn <Plug>OpenNotesForFile
endif

" <leader>cn -> Code-Note
vnoremap <silent><buffer> <Plug>OpenNotesForFileVisual :
            \<C-U>call code_notes#open_file_with_selection()<CR>
if !hasmapto('<Plug>OpenNotesForFileVisual')
    vmap <silent><buffer> <leader>cn <Plug>OpenNotesForFileVisual
endif
