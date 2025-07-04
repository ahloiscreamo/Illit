" Set compatibility to Vim only.
set nocompatible
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'rose-pine/vim'
Plugin 'tpope/vim-sensible'
call vundle#end()            " required
filetype plugin indent on    " required

" Map <leader>mp to open quickmd for the current file
" (assuming your leader key is '\' - you can check with :echo mapleader)
nnoremap <leader>mp :silent !quickmd % > /dev/null 2>&1 &<CR>

" Optional: A command to manually start quickmd for the current file
" You can run this by typing :MarkdownQuickPreview in Vim
command! MarkdownQuickPreview silent !quickmd % > /dev/null 2>&1 &

" RosePine
set background=dark
colorscheme rosepine_moon
let g:disable_bg = 1

" indentLine
let g:indentLine_color_term = 1

" Disable folding (vim-markdown)
let g:vim_markdown_folding_disabled = 1

"Always show current position
set ruler

" Turn on syntax highlighting.
syntax on

" Turn off modelines
set modelines=0

" Uncomment below to set the max textwidth. Use a value corresponding to the width of your screen.
" set textwidth=80
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5
" Fixes common backspace problems
set backspace=indent,eol,start

" Display options
set showmode
set showcmd
set cmdheight=1

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Display different types of white spaces.
"set list
"set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Show line numbers
set number
highlight LineNr ctermfg=60

" Set status line display
set laststatus=2
hi StatusLine ctermfg=16 ctermbg=green cterm=NONE
hi StatusLineNC ctermfg=16 ctermbg=green cterm=NONE
hi User1 ctermfg=16 ctermbg=magenta
hi User2 ctermfg=NONE ctermbg=NONE
hi User3 ctermfg=16 ctermbg=red
hi User4 ctermfg=16 ctermbg=red
set statusline=\                    " Padding
set statusline+=%f                  " Path to the file
set statusline+=\ %1*\              " Padding & switch colour
set statusline+=%y                  " File type
set statusline+=\ %2*\              " Padding & switch colour
set statusline+=%=                  " Switch to right-side
set statusline+=\ %3*\              " Padding & switch colour
set statusline+=line                " of Text
set statusline+=\                   " Padding
set statusline+=%l                  " Current line
set statusline+=\ %4*\              " Padding & switch colour
set statusline+=of                  " of Text
set statusline+=\                   " Padding
set statusline+=%L                  " Total line
set statusline+=\                   " Padding

" Encoding
set encoding=utf-8

" Highlight matching search patterns
set hlsearch

" Enable incremental search
set incsearch

" Include matching uppercase words with lowercase search term
set ignorecase

" Include only uppercase words with uppercase search term
set smartcase

" Store info from no more than 100 files at a time, 9999 lines of text
" 100kb of data. Useful for copying large amounts of data between files.
set viminfo='100,<9999,s100

" Set Backup copy
set backupcopy=yes
