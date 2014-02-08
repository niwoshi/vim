" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: foldlevel=0

" 初期化設定{{{1
augroup MyAutoCmd
	autocmd!
augroup END
" }}}
" 検索設定{{{1
set ignorecase          " 大文字小文字を区別しない
set smartcase           " 検索文字に大文字がある場合は大文字小文字を区別
set incsearch           " インクリメンタルサーチ
set hlsearch            " 検索マッチテキストをハイライト (2013-07-03 14:30 修正）

" バックスラッシュやクエスチョンを状況に合わせ自動的にエスケープ
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'
" }}}
" 編集設定{{{1
set shiftwidth=4        " タブ幅は4
set tabstop=4           " 画面上でタブ文字が占める幅
set shiftround          " '<'や'>'でインデントする際に'shiftwidth'の倍数に丸める
set infercase           " 補完時に大文字小文字を区別しない
set virtualedit=all     " カーソルを文字が存在しない部分でも動けるようにする
set hidden              " バッファを閉じる代わりに隠す（Undo履歴を残すため）
set switchbuf=useopen   " 新しく開く代わりにすでに開いてあるバッファを開く
set showmatch           " 対応する括弧などをハイライト表示する
set matchtime=3         " 対応括弧のハイライト表示を3秒にする

" 対応括弧に'<'と'>'のペアを追加
set matchpairs& matchpairs+=<:>

" バックスペースでなんでも消せるようにする
set backspace=indent,eol,start

" クリップボードをデフォルトのレジスタとして指定。後にYankRingを使うので
" 'unnamedplus'が存在しているかどうかで設定を分ける必要がある
if has('unnamedplus')
    " set clipboard& clipboard+=unnamedplus " 2013-07-03 14:30 unnamed 追加
    set clipboard& clipboard+=unnamedplus,unnamed 
else
    " set clipboard& clipboard+=unnamed,autoselect 2013-06-24 10:00 autoselect 削除
    set clipboard& clipboard+=unnamed
endif

" Swapファイル？Backupファイル？前時代的すぎ
" なので全て無効化する
set nowritebackup
set nobackup
set noswapfile
" }}}
" 表示設定{{{1
set list                " 不可視文字の可視化
set number              " 行番号の表示
set wrap                " 長いテキストの折り返し
set textwidth=0         " 自動的に改行が入るのを無効化
set colorcolumn=80      " その代わり80文字目にラインを入れる

" 前時代的スクリーンベルを無効化
set t_vb=
set novisualbell

" デフォルト不可視文字は美しくないのでUnicodeで綺麗に
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲
" }}}
" マクロおよびキー設定{{{1
" 入力モード中に素早くjjと入力した場合はESCとみなす
inoremap jj <Esc>

" ESCを二回押すことでハイライトを消す
nmap <silent> <Esc><Esc> :nohlsearch<CR>

" カーソル下の単語を * で検索
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v, '\/'), "\n", '\\n', 'g')<CR><CR>

" 検索後にジャンプした際に検索単語を画面中央に持ってくる
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" j, k による移動を折り返されたテキストでも自然に振る舞うように変更
nnoremap j gj
nnoremap k gk

" vを二回で行末まで選択
vnoremap v $h

" TABにて対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" Ctrl + hjkl でウィンドウ間を移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Shift + 矢印でウィンドウサイズを変更
nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

" T + ? で各種設定をトグル
nnoremap [toggle] <Nop>
nmap T [toggle]
nnoremap <silent> [toggle]s :setl spell!<CR>:setl spell?<CR>
nnoremap <silent> [toggle]l :setl list!<CR>:setl list?<CR>
nnoremap <silent> [toggle]t :setl expandtab!<CR>:setl expandtab?<CR>
nnoremap <silent> [toggle]w :setl wrap!<CR>:setl wrap?<CR>

" make, grep などのコマンド後に自動的にQuickFixを開く
autocmd MyAutoCmd QuickfixCmdPost make,grep,grepadd,vimgrep copen

" QuickFixおよびHelpでは q でバッファを閉じる
autocmd MyAutoCmd FileType help,qf nnoremap <buffer> q <C-w>c

" w !sudo tee > /dev/null % でスーパーユーザーとして保存（sudoが使える環境限定）
cmap w!! w !sudo tee > /dev/null %

" :e などでファイルを開く際にフォルダが存在しない場合は自動作成
function! s:mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
        \ input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction
autocmd MyAutoCmd BufWritePre * call s:mkdir(expand('<afile>:p:h'), v:cmdbang)

" vim 起動時のみカレントディレクトリを開いたファイルの親ディレクトリに指定
autocmd MyAutoCmd VimEnter * call s:ChangeCurrentDir('', '')
function! s:ChangeCurrentDir(directory, bang)
  if a:directory == ''
      lcd %:p:h
  else
      execute 'lcd' . a:directory
  endif

  if a:bang == ''
      pwd
  endif
endfunction

" ~/.vimrc.localが存在する場合のみ設定を読み込む
let s:local_vimrc = expand('~/.vimrc.local')
if filereadable(s:local_vimrc)
    execute 'source ' . s:local_vimrc
endif
" }}}
" NeoBundle{{{1
" NeoBundle基本設定{{{2
set nocompatible
filetype off

let s:noplugin = 0
let s:bundle_root = expand('~/.vim/bundle')
let s:neobundle_root = s:bundle_root . '/neobundle.vim'
if !isdirectory(s:neobundle_root) || v:version < 702
    " NeoBundleが存在しない、もしくはVimのバージョンが古い場合はプラグインを一切
    " 読み込まない
    let s:noplugin = 1
else
    " NeoBundleを'runtimepath'に追加し初期化を行う
    if has('vim_starting')
        execute "set runtimepath+=" . s:neobundle_root
    endif
    call neobundle#rc(s:bundle_root)

    " NeoBundle自身をNeoBundleで管理させる
    NeoBundleFetch 'Shougo/neobundle.vim'

    " 非同期通信を可能にする
    " 'build'が指定されているのでインストール時に自動的に
    " 指定されたコマンドが実行され vimproc がコンパイルされる
    NeoBundle "Shougo/vimproc", {
        \ "build": {
        \   "windows"   : "make -f make_mingw32.mak",
        \   "cygwin"    : "make -f make_cygwin.mak",
        \   "mac"       : "make -f make_mac.mak",
        \   "unix"      : "make -f make_unix.mak",
        \ }}
    " }}}
    " 基本セット{{{2
    " originalrepos on github
    NeoBundle 'Shougo/neobundle.vim'
    NeoBundle 'VimClojure'
    NeoBundle 'Shougo/vimshell'
    "NeoBundle 'Shougo/unite.vim'
    NeoBundle 'Shougo/neocomplcache'
    NeoBundle 'Shougo/neocomplete.vim'
    NeoBundle 'Shougo/neosnippet'
    NeoBundle "Shougo/neosnippet-snippets"
    NeoBundle 'jpalardy/vim-slime'
    "NeoBundle 'scrooloose/syntastic'
    NeoBundle 'tpope/vim-surround'
    NeoBundle 'vim-scripts/Align'
    NeoBundle 'vim-scripts/YankRing.vim'
    " javascript用
    NeoBundle 'mattn/emmet-vim'
    NeoBundle 'open-browser.vim'
    NeoBundle 'mattn/webapi-vim'
    NeoBundle 'tell-k/vim-browsereload-mac'
    NeoBundle 'hail2u/vim-css3-syntax'
    NeoBundle 'taichouchou2/html5.vim'
    "NeoBundle 'taichouchou2/vim-javascript'
    NeoBundle 'jelera/vim-javascript-syntax'
    ""NeoBundle 'https://bitbucket.org/kovisoft/slimv'
    " }}}
    "" hooks.on_sourceの設定{{{2
    "" 次に説明するがInsertモードに入るまではneocompleteはロードされない
    "NeoBundleLazy 'Shougo/neocomplete.vim', {
    "    \ "autoload": {"insert": 1}}
    "" neocompleteのhooksを取得
    "let s:hooks = neobundle#get_hooks("neocomplete.vim")
    "" neocomplete用の設定関数を定義。下記関数はneocompleteロード時に実行される
    "function! s:hooks.on_source(bundle)
    "    let g:acp_enableAtStartup = 0
    "    let g:neocomplete#enable_smart_case = 1
    "    " NeoCompleteを有効化
    "    NeoCompleteEnable
    "endfunction
    "" }}}
    "" NeoBundleLazy{{{2
    "" Insertモードに入るまでロードしない
    "NeoBundleLazy 'Shougo/neosnippet.vim', {
    "    \ "autoload": {"insert": 1}}
    "" 'GundoToggle'が呼ばれるまでロードしない
    "NeoBundleLazy 'sjl/gundo.vim', {
    "    \ "autoload": {"commands": ["GundoToggle"]}}
    "" '<Plug>TaskList'というマッピングが呼ばれるまでロードしない
    "NeoBundleLazy 'vim-scripts/TaskList.vim', {
    "    \ "autoload": {"mappings": ['<Plug>TaskList']}}
    "" HTMLが開かれるまでロードしない
    "NeoBundleLazy 'mattn/zencoding-vim', {
    "    \ "autoload": {"filetypes": ['html']}}
    "" }}}
    " vim-template{{{2
    NeoBundle "thinca/vim-template"
    " テンプレート中に含まれる特定文字列を置き換える
    autocmd MyAutoCmd User plugin-template-loaded call s:template_keywords()
    function! s:template_keywords()
        silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
        silent! %s/<+FILENAME+>/\=expand('%:r')/g
    endfunction
    " テンプレート中に含まれる'<+CURSOR+>'にカーソルを移動
    "autocmd MyAutoCmd User plugin-template-loaded
    "    \   if search('<+CURSOR+>')
    "    \ |   silent! execute 'normal! "_da>'
    "    \ | endif
    " }}}
    " unite.vim{{{2
    NeoBundleLazy "Shougo/unite.vim", {
          \ "autoload": {
          \   "commands": ["Unite", "UniteWithBufferDir"]
          \ }}
    NeoBundleLazy 'h1mesuke/unite-outline', {
          \ "autoload": {
          \   "unite_sources": ["outline"],
          \ }}
    nnoremap [unite] <Nop>
    nmap U [unite]
    nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
    nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
    nnoremap <silent> [unite]r :<C-u>Unite register<CR>
    nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
    nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
    nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
    nnoremap <silent> [unite]t :<C-u>Unite tab<CR>
    nnoremap <silent> [unite]w :<C-u>Unite window<CR>
    let s:hooks = neobundle#get_hooks("unite.vim")
    function! s:hooks.on_source(bundle)
      " start unite in insert mode
      let g:unite_enable_start_insert = 1
      " use vimfiler to open directory
      call unite#custom_default_action("source/bookmark/directory", "vimfiler")
      call unite#custom_default_action("directory", "vimfiler")
      call unite#custom_default_action("directory_mru", "vimfiler")
      autocmd MyAutoCmd FileType unite call s:unite_settings()
      function! s:unite_settings()
        imap <buffer> <Esc><Esc> <Plug>(unite_exit)
        nmap <buffer> <Esc> <Plug>(unite_exit)
        nmap <buffer> <C-n> <Plug>(unite_select_next_line)
        nmap <buffer> <C-p> <Plug>(unite_select_previous_line)
      endfunction
    endfunction
    " }}}
    " Vimfiler{{{2
    NeoBundleLazy "Shougo/vimfiler", {
          \ "depends": ["Shougo/unite.vim"],
          \ "autoload": {
          \   "commands": ["VimFilerTab", "VimFiler", "VimFilerExplorer"],
          \   "mappings": ['<Plug>(vimfiler_switch)'],
          \   "explorer": 1,
          \ }}
    nnoremap <Leader>e :VimFilerExplorer<CR>
    " close vimfiler automatically when there are only vimfiler open
    autocmd MyAutoCmd BufEnter * if (winnr('$') == 1 && &filetype ==# 'vimfiler') | q | endif
    let s:hooks = neobundle#get_hooks("vimfiler")
    function! s:hooks.on_source(bundle)
      let g:vimfiler_as_default_explorer = 1
      let g:vimfiler_enable_auto_cd = 1

      " .から始まるファイルおよび.pycで終わるファイルを不可視パターンに
      " 2013-08-14 追記
      let g:vimfiler_ignore_pattern = "\%(^\..*\|\.pyc$\)"

      " vimfiler specific key mappings
      autocmd MyAutoCmd FileType vimfiler call s:vimfiler_settings()
      function! s:vimfiler_settings()
        " ^^ to go up
        nmap <buffer> ^^ <Plug>(vimfiler_switch_to_parent_directory)
        " use R to refresh
        nmap <buffer> R <Plug>(vimfiler_redraw_screen)
        " overwrite C-l
        nmap <buffer> <C-l> <C-w>l
      endfunction
    endfunction
    " }}}
    " neocomplete{{{2
    " if has('lua') && v:version > 703 && has('patch825') 2013-07-03 14:30 > から >= に修正
    " if has('lua') && v:version >= 703 && has('patch825') 2013-07-08 10:00 必要バージョンが885にアップデートされていました
    if has('lua') && v:version >= 703 && has('patch885')
	NeoBundleLazy "Shougo/neocomplete.vim", {
	    \ "autoload": {
	    \   "insert": 1,
	    \ }}
        " 2013-07-03 14:30 NeoComplCacheに合わせた
	let g:neocomplete#enable_at_startup = 1
	let s:hooks = neobundle#get_hooks("neocomplete.vim")
	function! s:hooks.on_source(bundle)
	    let g:acp_enableAtStartup = 0
	    let g:neocomplet#enable_smart_case = 1
	    " NeoCompleteを有効化
	    " NeoCompleteEnable
	endfunction
    else
	NeoBundleLazy "Shougo/neocomplcache.vim", {
            \ "autoload": {
            \   "insert": 1,
            \ }}
	" 2013-07-03 14:30 原因不明だがNeoComplCacheEnableコマンドが見つからないので変更
	let g:neocomplcache_enable_at_startup = 1
	let s:hooks = neobundle#get_hooks("neocomplcache.vim")
	function! s:hooks.on_source(bundle)
	    let g:acp_enableAtStartup = 0
	    let g:neocomplcache_enable_smart_case = 1
	    " NeoComplCacheを有効化
	    " NeoComplCacheEnable 
	endfunction
    endif
    " }}}
    " neosnippet{{{2
    NeoBundleLazy "Shougo/neosnippet.vim", {
          \ "depends": ["honza/vim-snippets"],
          \ "autoload": {
          \   "insert": 1,
          \ }}
    let s:hooks = neobundle#get_hooks("neosnippet.vim")
    function! s:hooks.on_source(bundle)
      " Plugin key-mappings.
      imap <C-k>     <Plug>(neosnippet_expand_or_jump)
      smap <C-k>     <Plug>(neosnippet_expand_or_jump)
      xmap <C-k>     <Plug>(neosnippet_expand_target)
      " SuperTab like snippets behavior.
      imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: pumvisible() ? "\<C-n>" : "\<TAB>"
      smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: "\<TAB>"
      " For snippet_complete marker.
      if has('conceal')
        set conceallevel=2 concealcursor=i
      endif
      " Enable snipMate compatibility feature.
      let g:neosnippet#enable_snipmate_compatibility = 1
      " Tell Neosnippet about the other snippets
      let g:neosnippet#snippets_directory=s:bundle_root . '/vim-snippets/snippets'
    endfunction
    " }}}
    " vim-indent-guides{{{2
    NeoBundle "nathanaelkane/vim-indent-guides"
    colorscheme jellybeans
    " let g:indent_guides_enable_on_vim_startup = 1 2013-06-24 10:00 削除
    let s:hooks = neobundle#get_hooks("vim-indent-guides")
    function! s:hooks.on_source(bundle)
      let g:indent_guides_guide_size = 1
      IndentGuidesEnable " 2013-06-24 10:00 追記
    endfunction
    " }}}
    " Gundo.vim {{{2
    NeoBundleLazy "sjl/gundo.vim", {
        \ "autoload": {
        \   "commands": ['GundoToggle'],
        \}}
    nnoremap <Leader>g :GundoToggle<CR>
    " }}}
    " TaskList.vim{{{2
    NeoBundleLazy "vim-scripts/TaskList.vim", {
        \ "autoload": {
        \   "mappings": ['<Plug>TaskList'],
        \}}
    nmap <Leader>T <plug>TaskList
    " }}}
    " quickrun{{{2
    NeoBundleLazy "thinca/vim-quickrun", {
        \ "autoload": {
        \   "mappings": [['nxo', '<Plug>(quickrun)']]
        \ }}
    nmap <Leader>r <Plug>(quickrun)
    let s:hooks = neobundle#get_hooks("vim-quickrun")
    function! s:hooks.on_source(bundle)
      let g:quickrun_config = {
          \ "*": {"runner": "remote/vimproc"},
          \ }
    endfunction
    " }}}
    " Tagbar{{{2
    NeoBundleLazy 'majutsushi/tagbar', {
          \ "autload": {
          \   "commands": ["TagbarToggle"],
          \ },
          \ "build": {
          \   "mac": "brew install ctags",
          \ }}
    nmap <Leader>t :TagbarToggle<CR>
    " }}}
    " sytastic error{{{2
    NeoBundle "scrooloose/syntastic", {
          \ "build": {
          \   "mac": ["pip install flake8", "npm -g install coffeelint"],
          \   "unix": ["pip install flake8", "npm -g install coffeelint"],
          \ }}
    " }}}
    " open-browser.vim{{{2
    nmap <Leader>o <Plug>(openbrowser-open)
    vmap <Leader>o <Plug>(openbrowser-open)
    " }}}
    " インストールされていないプラグインのチェックおよびダウンロード
    NeoBundleCheck
endif

" ファイルタイププラグインおよびインデントを有効化
" これはNeoBundleによる処理が終了したあとに呼ばなければならない
filetype plugin indent on     " required!
filetype indent on
syntax on
" }}}

" モードラインを有効にする
set modeline
" 3行目までをモードラインとして検索する
set modelines=3


