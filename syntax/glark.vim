" glark.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-glark)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     25-Jän-2006.
" @Last Change: 25-Jan-2006.
" @Revision:    0.18

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax match GlarkFilename /^\S.*$/
syntax match GlarkMatchingLine /^\s\+\d\+ \(: \)\?/
syntax match GlarkContextLine /^\s\+\d\+ [+-] /

if version >= 508 || !exists("did_glark_syntax_inits")
  if version < 508
    let did_glark_syntax_inits = 1
    command! -nargs=+ HiLink hi link <args>
  else
    command! -nargs=+ HiLink hi def link <args>
  endif
 
  HiLink GlarkFilename Title
  HiLink GlarkMatchingLine DiffChange
  HiLink GlarkContextLine LineNr
  HiLink GlarkMatch Search

  delcommand HiLink
endif

let b:current_syntax = 'glark'

