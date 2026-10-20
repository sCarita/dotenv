" Native Vim themes support Apple Terminal's indexed colors without plugins.
syntax enable
set background=dark

" Set g:dotenv_vim_colorscheme before sourcing this file to choose another theme.
let s:theme = get(g:, 'dotenv_vim_colorscheme', 'habamax')
try
  execute 'colorscheme ' . fnameescape(s:theme)
catch /^Vim\%((\a\+)\)\=:E185/
  " Older Vim releases may lack Habamax; Desert is a longstanding fallback.
  colorscheme desert
endtry
unlet s:theme

" Built-in file tree: Enter opens files in the editor beside the sidebar.
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
let g:netrw_browse_split = 4
let g:netrw_keepdir = 1
nnoremap <silent> <leader>e :Lexplore<CR>

function! s:OpenDirectorySidebar() abort
  if argc() == 1 && isdirectory(argv(0)) && winnr('$') == 1
    let l:directory = fnamemodify(argv(0), ':p')
    " Replace the initial directory buffer with an empty editing pane first.
    enew
    execute 'Lexplore ' . fnameescape(l:directory)
    wincmd p
  endif
endfunction

augroup dotenv_vim_sidebar
  autocmd!
  autocmd VimEnter * call <SID>OpenDirectorySidebar()
augroup END
