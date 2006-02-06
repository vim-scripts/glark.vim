" glark.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-glark)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     25-Jän-2006.
" @Last Change: 05-Feb-2006.
" @Revision:    0.1.158

if &cp || exists("loaded_glark") "{{{2
    finish
endif
let loaded_glark = 1

if !exists('g:glarkCommand')  | let g:glarkCommand = 'glark'    | endif "{{{2
if !exists('g:glarkArgs')     | let g:glarkArgs = '-q -n -H -U' | endif "{{{2
if !exists('g:glarkHeight')   | let g:glarkHeight = &lines / 2  | endif "{{{2
if !exists('g:glarkMultiWin') | let g:glarkMultiWin = 0         | endif "{{{2

fun! <SID>GetLineNumber() "{{{3
    let li = getline('.')
    let ln = matchstr(li, '^\s\+\zs\d\+')
    if ln == ''
        " echoerr 'Malformed output: No linenumber in: '. li
        let ln = 1
    end
    return ln
endf

fun! <SID>GetColShift() "{{{3
    let li = getline('.')
    let ln = matchend(li, '^\s\+\d\+ \([:+-] \)\?')
    if ln < 0
        " echoerr 'Malformed output: No linenumber in: '. li
        return 1
    else
        if ln < col('.')
            return col('.') - ln
        else
            return 1
        endif
    end
endf

fun! <SID>GetFilename() "{{{3
    let pos = <SID>SavePos()
    try
        let ln = search('^\S', 'bW')
        if ln
            return simplify(b:glarkPWD .'/'. getline(ln))
        elseif line('.') == 1
            let li = getline(1)
            if li =~ '^\S'
                return simplify(b:glarkPWD .'/'. li)
            endif
        endif
        echoerr 'Malformed output: No filename (make sure you have glark >= 1.7.5)'
        return ''
    finally
        call <SID>RestorePos(pos)
    endtry
endf

fun! <SID>SavePos() "{{{3
    return 'norm! '. line('.') .'G'. col('.') .'|'
endf

fun! <SID>RestorePos(saved) "{{{3
    exec a:saved
endf

fun! <SID>Var(var) "{{{3
    return exists('b:'. a:var) ? b:{a:var} : g:{a:var}
endf

fun! <SID>GetGlarkWin(args) "{{{3
    if g:glarkMultiWin
        let wname = '__Glark-'. substitute(a:args, '[^[:alnum]]', '_', 'g') .'__'
    else
        let wname = '__Glark__'
    endif
    let wn = bufwinnr(wname)
    if wn == -1
        split
        exec 'silent edit '. <SID>CmdFname(wname)
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
        setlocal buflisted
        setlocal winfixheight
        set ft=glark
        call GlarkKeys()
    else
        exec wn .'wincmd w'
    endif
    return bufnr('%')
endf

fun! <SID>CmdFname(fname) "{{{3
    return escape(a:fname, ' \%#')
endf

fun! <SID>HowManyWindows() "{{{3
    let i = 1
    while winbufnr(i) > 0
        let i = i + 1
    endwh
    return i - 1
endf

fun! GlarkJump(flags) "{{{3
    let ln = <SID>GetLineNumber()
    if ln != ''
        let co = <SID>GetColShift()
        if co > 0
            let fn = <SID>GetFilename()
            if fn != ''
                let fwn = bufwinnr(fn)
                let fn  = <SID>CmdFname(fn)
                if a:flags == 'p'
                    exec 'pedit +'. ln .' '. fn
                    if &ft != 'glark'
                        set ft=glark
                    endif
                else
                    if a:flags == 'r'
                        exec 'edit '. fn
                    elseif a:flags == 'f'
                        exec 'edit '. fn
                        wincmd o
                    else
                        if fwn != -1
                            exec fwn .'wincmd w'
                        else
                            let wn = winnr()
                            wincmd W
                            if winnr() == wn
                                split
                            endif
                            exec 'edit '. fn
                        endif
                    endif
                    exec 'norm! '. ln .'G'. co .'|'
                endif
                return
            endif
        endif
    endif
endf

if !exists('*GlarkKeys') "{{{2
    fun! GlarkKeys() "{{{3
        noremap  <silent> <buffer> <cr> :call GlarkJump('')<cr>
        inoremap <silent> <buffer> <cr> <c-o>:call GlarkJump('')<cr>
        noremap  <silent> <buffer> o :call GlarkJump('')<cr>
        inoremap <silent> <buffer> o <c-o>:call GlarkJump('')<cr>
        noremap  <silent> <buffer> p :call GlarkJump('p')<cr>
        inoremap <silent> <buffer> p <c-o>:call GlarkJump('p')<cr>
        noremap  <silent> <buffer> r :call GlarkJump('r')<cr>
        inoremap <silent> <buffer> r <c-o>:call GlarkJump('r')<cr>
        noremap  <silent> <buffer> f :call GlarkJump('f')<cr>
        inoremap <silent> <buffer> f <c-o>:call GlarkJump('f')<cr>
        noremap  <silent> <buffer> q :wincmd c<cr>
        inoremap <silent> <buffer> q <c-o>:wincmd c<cr>
        noremap  <silent> <buffer> <esc> :wincmd c<cr>
        inoremap <silent> <buffer> <esc> <c-o>:wincmd c<cr>
    endf
endif

fun! GlarkRun(args) "{{{3
    let bn = <SID>GetGlarkWin(a:args)
    syntax clear GlarkMatch
    let b:glarkPWD = expand("%:p:h")
    setlocal modifiable
    silent exec '%!'. <SID>Var('glarkCommand') .' '. <SID>Var('glarkArgs') .' '. a:args
    setlocal nomodifiable
    let t = @t
    try
        norm! gg"tyG
        let output = @t
    finally
        let @t = t
    endtry
    " if line('$') == 1
    if output == "\<c-j>"
        wincmd c
    else
        if <SID>HowManyWindows() != 1
            exec 'resize '. (winheight(0) > line('$') ? line('$') : g:glarkHeight)
        endif
        let args = substitute(a:args, '\(\S\+\|\\ \)\+\s*$', '', 'g')
        let args = escape(args, '/\')
        let args = substitute(args, '\s\+', '\\|', 'g')
        let args = substitute(args, '\\|$', '', '')
        exec 'syntax match GlarkMatch /\V'. args .'/'
        let @/ = '\V'. args
    endif
endf

command! -nargs=* Glark call GlarkRun(<q-args>)


finish
Change Log:

0.1
- initial release

