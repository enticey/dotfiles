set showmatch                       " Show matching brackets
set ignorecase                      " Ignore case sensitivity
set number relativenumber           " Line numbers
set background=dark                 " Tell vim what the background color looks like
set autochdir                       " Set current working directory to the open buffer?

" Make sure all our indentation is setup nicely
set tabstop=4
set shiftwidth=4                   
set expandtab
set autoindent
set smarttab
set smartindent

set noswapfile
set textwidth=80

" Setting updatetime too low used to cause issues, tbfo.
set updatetime=100

" Change our plugin directory to something that makes more sense.
" See: https://github.com/junegunn/vim-plug for plugin manager docs.
call plug#begin('~/.config/nvim/plugged')

" LSP IDE features
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Emmet autocomplete
Plug 'mattn/emmet-vim', { 'for': 'html' }

" Shusia variant somewhat color-matched
Plug 'sainnhe/sonokai'

" Pretty status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Show added, modified and removed lines
Plug 'airblade/vim-gitgutter'

" Show git branch and add :Git command
Plug 'tpope/vim-fugitive'

" Autopairs
Plug 'jiangmiao/auto-pairs'

" HTML close tag
Plug 'alvan/vim-closetag', { 'for': 'html' }

" CSS coloring
Plug 'ap/vim-css-color', { 'for': ['css', 'sass', 'scss', 'less'] }

" See: https://github.com/rust-lang/rust.vim
Plug 'rust-lang/rust.vim'

" Fuzzy finder
" See: https://github.com/nvim-telescope/telescope.nvim#usage
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

syntax enable                       " Enables syntax highlighting
filetype plugin indent on           " More control over indentation, etc
let g:rustfmt_autosave = 1          " Format our rust code upon buffer save

if has('termguicolors')
  set termguicolors
endif

" This needs to be before the 'colorscheme'
let g:sonokai_style = 'shusia'

colorscheme sonokai

" Blinking cursor
set guicursor+=n-v-c-i:blinkon5

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Avoid showing extra messages when using completion
set shortmess+=c

lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it. 
    }, {
      { name = 'buffer' },
    })
  })


  -- Note: Using buffer source for `/` causes issues with / function for searching, tbfo.
  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = { 'pyright', 'rust_analyzer'}
  for _, lsp in pairs(servers) do
    require('lspconfig')[lsp].setup {
      on_attach = on_attach,
      flags = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150,
      }
  }
end
EOF

" Airline setup
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_powerline_fonts = 1
let g:airline_symbols.colnr = ''
let g:airline_symbols.maxlinenr = ''
let g:airline_section_c = airline#section#create(['', '%<', 'path', g:airline_symbols.space, 'readonly', 'lsp_progress'])
let g:airline_section_x = airline#section#create(['filetype', ' 🐈'])
let g:airline_section_y = ''
let g:airline_section_z = airline#section#create(['linenr', 'maxlinenr', 'colnr'])

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '[%s] '
let g:airline_symbols.linenr = ''

function! AirlineInit()
    highlight airline_tabsel gui=none
endfunction
autocmd User AirlineAfterInit call AirlineInit()

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ' '
let g:airline#extensions#tabline#right_sep = ' '
let g:airline#extensions#tabline#right_alt_sep = ' '
let g:airline_highlighting_cache = 0

" Do not draw separators for empty sections
let g:airline_skip_empty_sections = 0

let g:airline_theme='sonokai'

" Indent width on web dev languages
autocmd FileType html setlocal shiftwidth=2 tabstop=2 textwidth=120
autocmd FileType css setlocal shiftwidth=2 tabstop=2
autocmd FileType sass setlocal shiftwidth=2 tabstop=2
autocmd FileType scss setlocal shiftwidth=2 tabstop=2
autocmd FileType less setlocal shiftwidth=2 tabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType typescript setlocal shiftwidth=2 tabstop=2
autocmd FileType json setlocal shiftwidth=2 tabstop=2
autocmd FileType markdown setlocal shiftwidth=2 tabstop=2
autocmd FileType jsx setlocal shiftwidth=2 tabstop=2
autocmd FileType tsx setlocal shiftwidth=2 tabstop=2
autocmd FileType vue setlocal shiftwidth=2 tabstop=2
autocmd FileType angular setlocal shiftwidth=2 tabstop=2
