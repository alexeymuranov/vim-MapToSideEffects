" autoload/mapToSideEffects.vim
"
" Plugin Name:  Map To Side Effects
" Version:      0.1.0
" Last Change:  2016-04-07
" Author:       Alexey Muranov <alexeymuranov@users.noreply.github.com>
"
" This plugin helps to fool Vim into mapping key sequences in Normal,
" Visual/Select, and Operator-pending modes to function side effects.
"
"     ``All problems in computer science can be solved by another level
"     of indirection.''
"
"         -- a quote believed by Diomidis Spinellis to be attributed to
"         Butler Lampson, who attributes it to David Wheeler,
"         [according to Internet][1].
"
" [1]:
"   http://www.dmst.aueb.gr/dds/pubs/inbook/beautiful_code/html/Spi07g.html
"
" =========================================================================
" # User interface (API)                                    [documentation]
" =========================================================================
"
" This plugin supports 4 *kinds* of *actions*:
"
" * `Idempotent` -- actions that take no arguments and cannot be
"   meaningfully repeated more than once,
" * `Repeatable` -- actions that take no arguments but can be
"   meaningfully repeated a number of times,
" * `WithCount`  -- actions that take a `count`-type argument,
" * `WithCount1` -- actions that take a `count1`-type argument.
"
" *Action* here means a *VimL* function called for its side effects.
"
" #.# Registering actions and creating mappings
" -------------------------------------------------------------------------
"
" The following functions create mappings of a key sequence of the form
" `<Plug>(<name>)` to the side effects of the given action in requested
" modes.
"
" * `mapToSideEffects#SetUpIdempotent(action[, options])`
"   -- set up a mapping of a key sequence of the form `<Plug>(<name>)` to
"   the side effects of a user provided `Idempotent` action, return the
"   generated ID number,
"
" * `mapToSideEffects#SetUpRepeatable(action[, options])`
"   -- set up a mapping of a key sequence of the form `<Plug>(<name>)` to
"   the side effects of a user provided `Repeatable` action, return the
"   generated ID number,
"
" * `mapToSideEffects#SetUpWithCount(action[, options])`
"   -- set up a mapping of a key sequence of the form `<Plug>(<name>)` to
"   the side effects of a user provided `WithCount` action, return the
"   generated ID number,
"
" * `mapToSideEffects#SetUpWithCount1(action[, options])`
"   -- set up a mapping of a key sequence of the form `<Plug>(<name>)` to
"   the side effects of a user provided `WithCount1` action, return the
"   generated ID number,
"
" The optional `options` argument of these functions must be a
" dictionary which can contain two keys: `'modes'` and `'name'`.
"
" The `modes` option, if provided, has to be a string containing only
" letters `n`, `v`, `x`, `s`, `o`.  If it is omitted, it is assumed to be
" `'nvo'`.
"
" The `name` option, if provided, has to be a string matching the regex
" `'^[-_.:[:alnum:]]\{1,45}$'` and not beginning with `MapToSideEffects-`
" in any character case, and the user must ensure that the key sequence
" `<Plug>(<name>)` has not yet been used as a mapping source.  If the
" `name` option is omitted, the `name` is taken to be
" `'MapToSideEffects-<id>'`, where `<id>` is the generated numerical ID.
"
" Name collisions may be avoided as follows, for example:
"
" (a) start names with "`<PluginName>-`" in plugins and with a dash "`-`"
"   in user scripts, or
"
" (b) do not provide custom names, use automatic names of the form
"   "`MapToSideEffects-<id>`."
"
" NOTE: the reason for not allowing the hypothetical user to provide an
"   arbitrary key sequence to be mapped to the action's side effects is the
"   complexity, if not impossibility, of assuming the responsibility for
"   deciding how and whether to "sanitize" the provided key sequence (which
"   would make part of a string fed to `execute` command), how and whether
"   to escape special characters, how and whether to allow the user to
"   supply extra options to `map` commands (such as `<special>`,
"   `<silent>`, etc.), as well as the apparent impossibility to properly
"   address the possibility of the user's using `<SID>` as a part of
"   his/her/theirs keys sequence.
"
" #.# Unregistering actions and removing mappings
" -------------------------------------------------------------------------
"
" The following functions unregister one or several previously registered
" actions and clear the corresponding mappings.
"
" * `mapToSideEffects#ClearOne(id)`
"   -- remove the mapping and the data associated with the given ID number,
"
" * `mapToSideEffects#ClearOneByName(name)`
"   -- remove the mapping and the data associated with the given name,
"
" * `mapToSideEffects#ClearMultiple(ids)`
"   -- remove the mappings and the data associated with the given ID
"   numbers,
"
" * `mapToSideEffects#ClearMultipleByNames(names)`
"   -- remove the mappings and the data associated with the given names,
"
" The following function removes all the plugin's data and clears the
" corresponding mappings.
"
" * `mapToSideEffects#Reset()`
"   -- remove all mappings and all data.
"
" =========================================================================
" # Usage                                                   [documentation]
" =========================================================================
"
" Suppose one wishes to use the key sequence `<leader>ekf` in *Normal*,
" *Visual*, and *Operator-pending* modes to perform the motion to the
" nearest "end of a keyword," as defined by the pattern `'\>'` in *Vim*, in
" the forward direction and taking into account the `[count]` prefix.
" Using this plugin, this can be achieved as follows, for example.
"
" 1. Define a function `s:ToEndOfKeywordForward` with desired side effects
"   that takes a positive integer argument `count1`:
"
"       function s:ToEndOfKeywordForward(count1)
"         let l:count1 = a:count1
"         while l:count1 > 0
"           call search('\>', 'W')
"           let l:count1 -= 1
"         endwhile
"       endfunction
"
" 2. Create a mapping of `<Plug>(-GoToEndOfKeywordForward)` to the side
"   effects of `s:ToEndOfKeywordForward` function in *Normal*, *Visual*,
"   and *Operator-pending* modes:
"
"       call mapToSideEffects#SetUpWithCount1(
"             \   function('s:ToEndOfKeywordForward'),
"             \   {'name' : '-GoToEndOfKeywordForward', 'modes' : 'nxo'} )
"
" 3. Create desired custom mappings to `<Plug>(-GoToEndOfKeywordForward)`:
"
"       nmap <leader>ekf <Plug>(-GoToEndOfKeywordForward)
"       xmap <leader>ekf <Plug>(-GoToEndOfKeywordForward)
"       omap <leader>ekf <Plug>(-GoToEndOfKeywordForward)
"
" =========================================================================
" # Compatibility check                                              [code]
" =========================================================================
"
if v:version < 704
  echoerr "MapToSideEffects: i need you to have Vim version at least 7.4"
  finish
elseif &compatible
  echoerr "MapToSideEffects: i need you to have 'nocompatible' set"
  finish
endif

" =========================================================================
" # User interface (API)                                             [code]
" =========================================================================
"
" #.# Registering actions and creating mappings
" -------------------------------------------------------------------------
"
function mapToSideEffects#SetUpIdempotent(action, ...)
  return s:SetUpActionWithMapping(
        \   'Idempotent', a:action, (a:0 ? a:1 : {}) )
endfunction

function mapToSideEffects#SetUpRepeatable(action, ...)
  return s:SetUpActionWithMapping(
        \   'Repeatable', a:action, (a:0 ? a:1 : {}) )
endfunction

function mapToSideEffects#SetUpWithCount(action, ...)
  return s:SetUpActionWithMapping(
        \   'WithCount', a:action, (a:0 ? a:1 : {}) )
endfunction

function mapToSideEffects#SetUpWithCount1(action, ...)
  return s:SetUpActionWithMapping(
        \   'WithCount1', a:action, (a:0 ? a:1 : {}) )
endfunction

" #.# Unregistering actions and removing mappings
" -------------------------------------------------------------------------
"
function mapToSideEffects#ClearOne(id)
  call s:ClearOne(a:id)
endfunction

function mapToSideEffects#ClearOneByName(name)
  call s:ClearOne(s:ActionIdFromName(a:name))
endfunction

function mapToSideEffects#ClearMultiple(ids)
  call s:ClearMultiple(a:ids)
endfunction

function mapToSideEffects#ClearMultipleByNames(names)
  for l:n in a:names
    call s:ClearOne(s:ActionIdFromName(l:n))
  endfor
endfunction

" Uncomment this if you need it:
" function mapToSideEffects#ClearSeveral(...)
"   call s:ClearMultiple(a:000)
" endfunction

" Uncomment this if you need it:
" function mapToSideEffects#Clear(...)
"   for l:k in a:000
"     if type(l:k) == type([])
"       call s:ClearMultiple(l:k)
"     else
"       call s:ClearOne(l:k)
"     endif
"   endfor
" endfunction

" #.# Resetting
" -------------------------------------------------------------------------
"
function mapToSideEffects#Reset()
  call s:Reset()
endfunction

" #.# Name validation
" -------------------------------------------------------------------------
"
function mapToSideEffects#NameFormatValid(name)
  return s:NameFormatValid(a:name)
endfunction

function mapToSideEffects#NameAvailable(name)
  return s:NameAvailable(a:name)
endfunction

" =========================================================================
" # Private                                                          [code]
" =========================================================================
"
" #.# Registering actions and creating mappings
" -------------------------------------------------------------------------
"
" This function stores the given action, sets up mappings in requested
" modes of a key sequence of the form `<Plug>(<name>)` to run this action
" for its side effects, taking into account its kind, and returns the
" numerical id under which it has been stored.
function s:SetUpActionWithMapping(action_kind, action, options)
  if has_key(a:options, 'name')
    let l:name = a:options['name']
    call s:ValidateName(l:name)
  else
    let l:name = ''
  endif

  let l:id = s:RegisterAction(a:action)
  if l:name == ''
    let l:name = s:MakeActionName(l:id)
  endif
  call s:StoreActionName(l:id, l:name)

  for l:mode in split(get(a:options, 'modes', 'nvo'), '\zs')
    call s:DefineMapping(l:name, l:mode, a:action_kind, l:id)
  endfor

  return l:id
endfunction

" #.# Unregistering actions and removing mappings
" -------------------------------------------------------------------------
"
function s:ClearOne(id)
  call s:ClearMapping(s:ActionName(a:id))
  call s:RemoveActionName(a:id)
  call s:ForgetAction(a:id)
endfunction

function s:ClearMultiple(ids)
  for l:id in a:ids
    call s:ClearOne(l:id)
  endfor
endfunction

" #.# Resetting
" -------------------------------------------------------------------------
"
function s:Reset()
  call s:ClearMappings(s:AllActionNames())
  call s:RemoveAllActionNames()
  call s:ForgetAllActions()
endfunction

" #.# Keeping actions
" -------------------------------------------------------------------------
"
let s:actions = {}
let s:actionCount = 0

" Save action reference in a dictionary and return the key/id
function s:RegisterAction(action)
  let s:actionCount += 1
  let s:actions[s:actionCount] = a:action
  return s:actionCount
endfunction

function s:ForgetAction(id)
  unlet s:action[a:id]
endfunction

function s:ForgetAllActions()
  let s:actions = {}
endfunction

" #.# Keeping names
" -------------------------------------------------------------------------
"
let s:actionNames = {}
let s:actionIdsByNames = {}

function s:StoreActionName(id, name)
  let s:actionNames[a:id] = a:name
  let s:actionIdsByNames[a:name] = a:id
endfunction

function s:RemoveActionName(id)
  unlet s:actionIdsByNames[s:actionNames[a:id]]
  unlet s:actionNames[a:id]
endfunction

function s:RemoveAllActionNames()
  let s:actionIdsByNames = {}
  let s:actionNames = {}
endfunction

function s:ActionName(id)
  return s:actionNames[a:id]
endfunction

function s:AllActionNames()
  return keys(s:actionIdsByNames)
endfunction

function s:ActionIdFromName(name)
  return s:actionIdsByNames[a:name]
endfunction

" XXX: the behavior of this function affects the API, hence cannot be
"   changed without modifying the documentation
function s:MakeActionName(id)
  return 'MapToSideEffects-' . a:id
endfunction

" #.# Name validation
" -------------------------------------------------------------------------
"
function s:NameFormatValid(name)
  return type(a:name) == type('') &&
        \ match(a:name, '^[-_.:[:alnum:]]\{1,45}$') >= 0 &&
        \ match(a:name, '\c^MapToSideEffects-') == -1
endfunction

function s:NameAvailable(name)
  return !has_key(s:actionIdsByNames, a:name)
endfunction

function s:ValidateName(name)
  if !s:NameFormatValid(a:name)
    echoerr "MapToSideEffects: the custom name must be a non-empty" .
          \ " string of length at most 45 matching the regex" .
          \ " '^[-_.:[:alnum:]]\{1,45}$' and not starting with" .
          \ " 'MapToSideEffects-' in any character case."
    throw 'MapToSideEffects:InvalidNameFormat'
  endif
  if !s:NameAvailable(a:name)
    echoerr "MapToSideEffects: the given custom name '" .
          \ a:name .
          \ "' is already taken." .
          \ "  Are you trying to set up the same action twice?" .
          \ "  (A rhetorical question.)"
    throw 'MapToSideEffects:NameNotAvailable'
  endif
endfunction

" #.# Managing mappings
" -------------------------------------------------------------------------
"
function s:DefineMapping(name, mode, action_kind, action_id)
  execute s:mapToActionCommandMakers[a:action_kind][a:mode].make(
        \   s:MappableKeySeqFromName(a:name), a:action_id )
endfunction

function s:ClearMapping(name)
  execute 'unmap' s:MappableKeySeqFromName(a:name)
endfunction

function s:ClearMappings(names)
  for l:name in a:names
    call s:ClearMapping(l:name)
  endfor
endfunction

" XXX: the behavior of this function affects the API and is not expected to
"   be ever changed
function s:MappableKeySeqFromName(name)
  return '<Plug>(' . a:name . ')'
endfunction

" #.# Composing mapping commands
" -------------------------------------------------------------------------
"
" The dictionary `s:mapToActionCommandMakers` contains nested dictionaries
" that contain functions that generate commands for mapping key sequences
" of the form `<Plug>(<name>)` to "side effects" of running the action
" stored under the given numerical id.
"
" *Examples.*
"
" 1. The command
"
"       execute s:mapToActionCommandMakers.WithCount1.n.make('foo', 42)
"
"   creates the same mapping as the command
"
"       nnoremap <unique> <special> <silent> <Plug>(foo)
"             \ :<C-u>call <SID>RunFromCallCmdWithCount1(42)<CR>
"
" 2. The command
"
"       execute s:mapToActionCommandMakers.WithCount1.v.make('foo', 42)
"
"   creates the same mapping as the command
"
"       vnoremap <unique> <special> <silent> <expr> <Plug>(foo)
"             \ "@_@=<SID>RunFromExprRegWithAnArgument(42," .
"             \ v:count1 . ")<CR>"
"
" 3. The command
"
"       execute s:mapToActionCommandMakers.WithCount1.o.make('foo', 42)
"
"   creates the same mapping as the command
"
"       onoremap <unique> <special> <silent> <Plug>(foo)
"             \ :call <SID>RunFromCallCmdWithCount1(42)<CR>
"
function s:MakeMapToActionCommandMakers()
  let l:modes = ['n', 'v', 'x', 's', 'o']
  let l:actionKinds = ['Idempotent', 'Repeatable', 'WithCount', 'WithCount1']

  let l:mapToActionCommandMakers = {}

  for l:action_kind in l:actionKinds
    let l:mapCommandMakersByMode = {}
    let l:mapToActionCommandMakers[l:action_kind] =
          \ l:mapCommandMakersByMode
    for l:mode in l:modes
      let l:mapCommandMaker = {}
      let l:mapCommandMakersByMode[l:mode] = l:mapCommandMaker
      let l:mapCommandMaker.map_mode_letter = l:mode
      " NOTE:  It is a coincidence that modes in this script are denoted
      "   by the same letters as used in "`map`" commands.  One could use
      "   a dictionary lookup here instead of the direct assignment
      "   `= l:mode`.
    endfor
  endfor

  let l:dict = {}

  function l:dict.func1(key_seq, id)
    return s:MapCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromExprRegOnceKeySeq(
          \     'RunFromExprRegWithNoArguments', a:id ) )
  endfunction
  for l:mode in ['n', 'v', 'x', 's']
    let l:mapToActionCommandMakers.Idempotent[l:mode].make = l:dict.func1
  endfor

  function l:mapToActionCommandMakers.Idempotent.o.make(key_seq, id)
    return s:MapCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromCallCmdKeySeq(
          \     'RunFromCallCmdWithNoArguments', a:id,
          \     self.map_mode_letter ==# 'n' ) )
  endfunction

  function l:dict.func3(key_seq, id)
    return s:MapCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromExprRegKeySeq(
          \     'RunFromExprRegWithNoArguments', a:id ) )
  endfunction
  for l:mode in ['n', 'v', 'x', 's']
    let l:mapToActionCommandMakers.Repeatable[l:mode].make = l:dict.func3
  endfor

  function l:mapToActionCommandMakers.Repeatable.o.make(key_seq, id)
    return s:MapCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromCallCmdKeySeq(
          \     'RunFromCallCmdCount1Times', a:id,
          \     self.map_mode_letter ==# 'n' ) )
  endfunction

  function l:dict.func5(key_seq, id)
    return s:MapCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromCallCmdKeySeq(
          \     'RunFromCallCmdWithCount', a:id,
          \     self.map_mode_letter ==# 'n' ) )
  endfunction
  for l:mode in ['n', 'o']
    let l:mapToActionCommandMakers.WithCount[l:mode].make = l:dict.func5
  endfor

  function l:dict.func6(key_seq, id)
    return s:MapExprCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromExprRegOnceWithAVimVarKeySeqExpr(
          \     'RunFromExprRegWithAnArgument', a:id, 'count') )
  endfunction
  for l:mode in ['v', 'x', 's']
    let l:mapToActionCommandMakers.WithCount[l:mode].make = l:dict.func6
  endfor

  function l:dict.func7(key_seq, id)
    return s:MapCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromCallCmdKeySeq(
          \     'RunFromCallCmdWithCount1', a:id,
          \     self.map_mode_letter ==# 'n' ) )
  endfunction
  for l:mode in ['n', 'o']
    let l:mapToActionCommandMakers.WithCount1[l:mode].make = l:dict.func7
  endfor

  function l:dict.func8(key_seq, id)
    return s:MapExprCommand( self.map_mode_letter, a:key_seq,
          \   s:RunFromExprRegOnceWithAVimVarKeySeqExpr(
          \     'RunFromExprRegWithAnArgument', a:id, 'count1') )
  endfunction
  for l:mode in ['v', 'x', 's']
    let l:mapToActionCommandMakers.WithCount1[l:mode].make = l:dict.func8
  endfor

  return l:mapToActionCommandMakers
endfunction
let s:mapToActionCommandMakers = s:MakeMapToActionCommandMakers()
delfunction s:MakeMapToActionCommandMakers

" #.#.# Composing general mapping commands
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function s:MapCommand(mode, source, target)
  return join([ a:mode . 'noremap <unique> <special> <silent>',
        \       a:source, a:target ])
endfunction

function s:MapExprCommand(mode, source, target)
  return join([ a:mode . 'noremap <unique> <special> <silent> <expr>',
        \       a:source, a:target ])
endfunction

" #.#.# Composing mapping targets
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function s:RunFromExprRegKeySeq(fun_name, arg_val)
  return '@=<SID>' . a:fun_name . '(' . a:arg_val . ')<CR>'
endfunction

function s:RunFromExprRegOnceKeySeq(fun_name, arg_val)
  return '@_@=<SID>' . a:fun_name . '(' . a:arg_val . ')<CR>'
endfunction

function s:RunFromExprRegOnceWithAVimVarKeySeqExpr( fun_name,
      \                                             arg_val, var_name )
  return '"@_@=<SID>' . a:fun_name . '(' . a:arg_val .
        \ ',".v:' . a:var_name . '.")<CR>"'
endfunction

function s:RunFromCallCmdKeySeq(fun_name, arg_val, cancel_range)
  return ':' . (a:cancel_range ? '<C-u>' : '') .
        \ 'call <SID>' . a:fun_name . '(' . a:arg_val . ')<CR>'
endfunction

" #.# Accessing actions from mappings
" -------------------------------------------------------------------------
"
" XXX: these functions should be optimised for speed, as they are called
"   each time the mappings are executed
"
" NOTE: "functional" entries of non-global dictionaries cannot be called
"   from a mapping, `<SID>` does not help, see
"   [how to reference a script local dictionary in a vim mapping](
"     http://unix.stackexchange.com/questions/58605/)
function s:RunFromExprRegWithNoArguments(id)
  call s:actions[a:id]()
  return ''
endfunction

function s:RunFromExprRegWithAnArgument(id, cnt)
  call s:actions[a:id](a:cnt)
  return ''
endfunction

function s:RunFromCallCmdWithNoArguments(id)
  call s:actions[a:id]()
endfunction

function s:RunFromCallCmdCount1Times(id)
  let l:Action = s:actions[a:id]
  let l:count1 = v:count1
  while l:count1 > 0
    call l:Action()
    let l:count1 -= 1
  endwhile
endfunction

function s:RunFromCallCmdWithCount(id)
  call s:actions[a:id](v:count)
endfunction

function s:RunFromCallCmdWithCount1(id)
  call s:actions[a:id](v:count1)
endfunction
