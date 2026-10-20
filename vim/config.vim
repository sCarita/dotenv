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
