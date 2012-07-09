"Get out of VI's compatible mode..
set nocompatible
 
"Sets how many lines of history VIM has to remember
set history=500
 
"Enable filetype plugin
filetype on
filetype plugin on
filetype indent on
 
"Set to auto read when a file is changed from the outside
set autoread
 
"Font
set guifont=Courier\ 9
 
if has("syntax")
    syntax on
endif
 
"Enable syntax hl
syntax enable
 
"do not backup file
"set nobackup

"Highlight current
"set cursorline
 
"Turn on WiLd menu
"set wildmenu
 
"Always show current position
set ruler
 
"Show line number
set nu
 
"Set backspace
set backspace=eol,start,indent
 
"Bbackspace and cursor keys wrap to
set whichwrap+=<,>,h,l
 
set incsearch
 
"Set magic on
set magic
 
"show matching bracets
set showmatch
 
"How many tenths of a second to blink
set mat=4
 
"Highlight search things
set hlsearch
 
"Text options
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set smarttab
set lbr
 
"Auto indent
set ai
 
"Smart indent
set si
 
"C-style indenting
set cindent
 
"Wrap line
set wrap
 
"Chinese support
set encoding=utf-8
set fencs=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set ambiwidth=double
 
"Show C space errors
let c_space_errors=1
 
"IComplete Setting
autocmd Filetype cpp,c,java set omnifunc=cppcomplete#Complete
autocmd BufWinLeave *.sh :![ -x % ] || chmod +x %
autocmd BufWinLeave *.py :![ -x % ] || chmod +x %
