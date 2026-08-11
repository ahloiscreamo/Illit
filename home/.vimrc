" Set compatibility to Vim only.
set nocompatible
filetype off                 " required

" Set copy paste to browser.
set clipboard=unnamedplus

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'rose-pine/vim'
Plugin 'tpope/vim-sensible'
call vundle#end()            " required
filetype plugin indent on    " required

" Map <leader>mp to open current Markdown file in Chawan in a vertical split on the right
" Automatically closes the split when you press 'q' in Chawan
nnoremap <leader>mp :vertical rightbelow terminal ++close cha %<CR>

" Reload vimrc
nnoremap <leader>r :source ~/.vimrc<CR>

" Enable True Color for hex codes
if has('termguicolors')
  set termguicolors
endif

" RosePine
set background=dark
colorscheme rosepine_moon
if !has('gui_running')
  let g:disable_bg = 1
endif

" indentLine
let g:indentLine_color_term = 1

" Always show current position
set ruler

" Turn on syntax highlighting.
syntax on

" Turn off modelines
set modelines=0

" Formatting options
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

" Highlight matching pairs of brackets.
set matchpairs+=<:>

" Show line numbers
set number
highlight LineNr ctermfg=60

" Set status line display
set laststatus=2
source ~/.vim/themes/statusline-moon.vim
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

" Store info from no more than 100 files at a time, 9999 lines of text
set viminfo='100,<9999,s100

" Set Backup copy
set backupcopy=yes
