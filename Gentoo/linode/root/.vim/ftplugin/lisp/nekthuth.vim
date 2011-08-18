""" Author: Frank Duncan (frank@nekthuth.com) Copyright 2008
""" Version: 0.1
""" 
""" License:  GPLv2 (Note that the lisp component is licensed under LLGPL)
"""
""" This program is free software; you can redistribute it and/or
""" modify it under the terms of the GNU General Public
""" License as published by the Free Software Foundation; either
""" version 2 of the License, or (at your option) any later version.
"""
""" This program is distributed in the hope that it will be useful,
""" but WITHOUT ANY WARRANTY; without even the implied warranty of
""" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
""" General Public License for more details.
"""
""" You should have received a copy of the GNU Library General Public
""" License along with this library; if not, write to the
""" Free Software Foundation, Inc., 59 Temple Place - Suite 330,
""" Boston, MA 02111-1307, USA.

if exists("g:nekthuth_disable")
  finish
endif

if exists("g:nekthuth_vsplit") && !g:nekthuth_vsplit
  let g:nekthuth_split = "split"
else
  let g:nekthuth_split = "vsplit"
endif

if !exists("g:nekthuth_remote_port")
  let g:nekthuth_remote_port = 8532
endif

if v:version < 700
  echoerr "Could not initialize nekthuth, need version > 7"
  finish
elseif !has("python") 
  echoerr "Could not initialize nekthuth, not compiled with +python"
  finish
endif

if exists("g:nekthuth_defined")
  finish
endif
let g:nekthuth_defined = 1

if("" == $NEKTHUTH_HOME)
  let g:nekthuth_home = $HOME . "/.nekthuth/"
else
  let g:nekthuth_home = $NEKTHUTH_HOME
endif

" This must match the version on the lisp side
let g:nekthuth_version = "0.3"

set updatetime=500
autocmd BufDelete,BufUnload,BufWipeout Nekthuth.buffer python closeNekthuth()
autocmd VimLeave * python closeNekthuth()
au CursorHold,CursorHoldI * python cursorHoldDump()
au CursorMoved,CursorMovedI * python dumpLispMovement()
au Filetype lisp au BufEnter * python refreshSyntax()
command! -nargs=0 -count=0 NekthuthSexp python sendSexp(<count>)
command! -nargs=0 -count=0 NekthuthMacroExpand python macroExpand(<count>)
command! -nargs=0 NekthuthTopSexp python sendSexp(100)
command! -nargs=0 NekthuthClose python closeNekthuth()
command! -nargs=0 NekthuthOpen python openNekthuth()
command! -nargs=? NekthuthRemote python remoteNekthuth('<args>')
command! -nargs=0 NekthuthInterrupt python sendInterrupt()
command! -nargs=0 NekthuthSourceLocation python openSourceLocation()

function! NekthuthOmni(findstart, base)
  execute "python omnifunc(" . a:findstart . ", \"" . a:base . "\")"
  return l:retn
endfunction

hi link lispAtom Special

set omnifunc=NekthuthOmni

if !exists("g:nekthuth_sbcl")
  let g:nekthuth_sbcl = "/usr/bin/sbcl"
endif

if !exists("g:lisp_debug")
  let g:lisp_debug = "N"
endif

python << EOF
import threading,time,vim,os,sys,locale,re,socket

buffer = None
input = None
output = None
window = None
lock = threading.Lock()
errorMsgs = []
debugMode = (vim.eval("g:lisp_debug") == "Y")

plugins = {}

class Sender(threading.Thread):
  started = False

  def run (self):
    global lock,plugins,errorMsgs,debugMode
    while not output.closed:
      cmdChar = output.read(1)

      if cmdChar == '': 
        print "Lisp closed!"
        print
        output.close()
      elif cmdChar == '\n':
        pass
      elif cmdChar == 'A':
        msg = output.readline()
        if 'GO\n' == msg:
          self.started = True
        elif 'STOP\n' == msg:
          closeNekthuth()
          print >> sys.stderr, "Failed to start up nekthuth.  Either the asdf package is not installed or the incorrect version (expected " + vim.eval("g:nekthuth_version") + ")"
        elif 'THREAD\n' == msg:
          closeNekthuth()
          print >> sys.stderr, "Failed to start up nekthuth.  SBCL not compiled with thread options."
        elif msg.startswith('VERSION'):
          ver = msg.replace('VERSION', '')
          if ver.rstrip() != vim.eval ("g:nekthuth_version"):
            closeNekthuth()
            output.close()
            print >> sys.stderr, ("Failed to start up nekthuth.  Version was incorrect, vim plugin version is " +
                                  vim.eval ("g:nekthuth_version") +
                                  " but lisp package version " + ver)

      elif (self.started and cmdChar in plugins):
        plugin = plugins[cmdChar]
        if ('bell' in plugin and plugin['bell'] and 'waitingForResponse' in plugin and plugin['waitingForResponse']):
          print "Response from lisp waiting"

        incomingSize = locale.atoi (output.read(6))
        lock.acquire()
        plugin['msg'].append(output.read (incomingSize))
        lock.release()
      else:
        if debugMode:
          errorMsgs.append(cmdChar + ')' + output.readline())
        else:
          output.readline()


def lispSend(cmdChar, msg):
  global input
  openNekthuth()
  input.write (cmdChar)
  input.write ("%06d" % len(msg))
  input.write (msg)
  input.flush()

def getBufferNum():
  global buffer
  return vim.eval("bufwinnr('" + buffer.name + "')")

def bufferSend(msg):
  if buffer == None:
    return
  vim.command ("set paste")
  if type('') == type(msg):
    for line in msg.strip("\n").split("\n"):
      buffer.append(line)
  elif type([]) == type(msg):
    for str in msg:
      for line in str.strip("\n").split("\n"):
        buffer.append(line)

  curwinnum = vim.eval("winnr()")
  bufwinnum = getBufferNum()
  vim.command (bufwinnum + "wincmd w")
  window.cursor = (len(buffer), 0);
  vim.command ("redraw")
  vim.command (curwinnum + "wincmd w")
  vim.command ("set nopaste")

def lispSendReceive(cmdChar, msg):
  global plugins,lock
  lock.acquire()
  if not cmdChar in plugins:
    plugins[cmdChar] = {}
  plugins[cmdChar]['msg'] = []
  lock.release()

  lispSend(cmdChar, msg)

  waits = 0
  while (plugins[cmdChar]['msg'] == []):
    time.sleep(0.2)
    waits += 1
    if waits > 50:
      raise Exception, 'Waited more than 10 seconds, and no response, something is wrong'

  lock.acquire()
  retn = plugins[cmdChar]['msg'][0]
  lock.release()
  return retn

# bell is if you want the user to be pinged that lisp has a response ready
def registerReceiver(cmdChar, callback, bell):
  global plugins,lock
  if not cmdChar in plugins:
    lock.acquire()
    plugins[cmdChar] = {'callback':callback, 'bell':bell, 'msg':[]}
    lock.release()

def openNekthuth():
  global buffer,window,input,output
  if buffer == None:
    if not os.path.exists(vim.eval("g:nekthuth_sbcl")):
      print >> sys.stderr, "Could not open the nekthuth: path " + vim.eval("g:nekthuth_sbcl") +\
        " does not exists"
      return
    print "Starting lisp interpreter"
    print
    vim.command (vim.eval ("g:nekthuth_split") + " +e Nekthuth.buffer")
    vim.command ("setlocal buftype=nofile noswapfile filetype=lisp nonumber")
    buffer = vim.current.buffer
    window = vim.current.window
    (input, output) = os.popen4(vim.eval("g:nekthuth_sbcl") + " --noinform", "rw", 1)
    input.write('#-sb-thread (progn (format t "~%ATHREAD~%") (sb-ext:quit))\n')
    input.flush()
    input.write("(ignore-errors (asdf:oos 'asdf:load-op 'nekthuth))\n")
    input.flush()
    input.write("(declaim (optimize (speed 0) (space 0) (debug 3)))\n")
    input.flush()
    input.write('(if (ignore-errors (funcall (symbol-function (find-symbol "EXPECTED-VERSION" \'nekthuth.system)) ' + vim.eval ("g:nekthuth_version") + ')) (progn (format t "~%") (funcall (find-symbol "START-IN-VIM" \'nekthuth))) (progn (format t "~%ASTOP~%") (sb-ext:quit)))\n')
    input.flush()

    Sender().start()
    vim.command ("wincmd w")

def remoteNekthuth(port):
  if port == '':
    port = vim.eval("g:nekthuth_remote_port")

  global buffer,window,input,output
  if buffer == None:
    print "Starting remote connection to lisp"
    print
    try:
      s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
      s.connect(('localhost', locale.atoi(port)))
    except:
      print >> sys.stderr, "Could not connect to lisp!"
      return
    input = s.makefile("w")
    output = s.makefile("r")
    vim.command (vim.eval ("g:nekthuth_split") + " +e Nekthuth.buffer")
    vim.command ("setlocal buftype=nofile noswapfile filetype=lisp nonumber")
    buffer = vim.current.buffer
    window = vim.current.window
    Sender().start()
    vim.command ("wincmd w")

def getCurrentPos():
  col = locale.atoi(vim.eval("virtcol('.')")) - 1
  line = locale.atoi(vim.eval("line('.')")) - 1
  vim.command("normal! H")
  top = locale.atoi(vim.eval("line('.')")) - 1

  vim.command("normal! " + str(line + 1) + "G" + str(col + 1) + "|")

  return {"top": top, "line": line, "col": col}

def gotoPos(pos):
  vim.command("normal! " + str(pos["top"] + 1) + "Gzt" + str(pos["line"] + 1) + "G" + str(pos["col"] + 1) + "|")

def gotoNextNonCommentChar():
  p = re.compile('\s')
  while True:
    prev_line = vim.eval("line('.')")
    cur_char = vim.eval("getline('.')[col('.') - 1]")
    if cur_char == '':
      break
    elif cur_char == ';':
      vim.command("normal j")
    elif cur_char == None or p.match(cur_char) != None:
      vim.command("normal W")
    else:
      break
    if cur_char == vim.eval("getline('.')[col('.') - 1]") and prev_line == vim.eval("line('.')"):
      break

def getColBackwards(pos, line):
  if pos == -1:
    return 0
  elif re.compile("^[\(\) ']$").match(line[pos]):
    return pos + 1
  else:
    return getColBackwards (pos - 1, line)

def getColForwards(pos, line):
  if pos == (len(line)):
    return len(line) - 1
  elif re.compile("^[\(\) ']$").match(line[pos]):
    return pos - 1
  else:
    return getColForwards (pos + 1, line)

def getSexp(count):
  curpos = getCurrentPos()
  if count == 0:
    count = 1
  else:
    count = count - locale.atoi(vim.eval("line('.')")) + 1
  if vim.current.buffer[curpos["line"]][curpos["col"]] == '(':
    count = count - 1
  if count > 0:
    vim.command ("normal! " + str(count) + "[(")

  parenPos = getCurrentPos()
  if vim.current.buffer[parenPos["line"]][parenPos["col"]] == '(':
    vim.command ("silent normal! \"lyab")
  else:
    firstCol = getColBackwards(parenPos["col"], vim.current.buffer[parenPos["line"]])
    lastCol = getColForwards(parenPos["col"], vim.current.buffer[parenPos["line"]]) + 1
    vim.command ("normal! |" + str(firstCol))
    vim.command ("silent normal! \"l" + str(lastCol - firstCol) + "yl")

  gotoPos (curpos)
  retn = vim.eval("@l")

  vim.command ("let @l=@_")
  return retn

def closeNekthuth():
  global input,buffer
  if buffer != None:
    print "Closing Lisp"
    print
    buffer = None
    input.write ("Q000000")
    input.flush()
    vim.command ("bw Nekthuth.buffer")

def dumpLispMovement():
  for plugin in plugins.values():
    plugin['waitingForResponse'] = False
  dumpLisp()

def dumpLisp():
  global lock,plugins,errorMsgs,debugMode
  if (debugMode and errorMsgs != []):
    bufferSend(errorMsgs)
    errorMsgs = []
  for plugin in plugins.values():
    if ('bell' in plugin and plugin['msg'] != []):
      plugin['waitingForResponse'] = False;
    if ('callback' in plugin and plugin['msg'] != []):
      lock.acquire()
      msg = plugin['msg']
      plugin['msg'] = []
      lock.release()
      plugin['callback'](msg)

def cursorHoldDump():
  for plugin in plugins.values():
    plugin['waitingForResponse'] = True
  dumpLisp()

### Synchronous plugins
def macroExpand(count):
  sexp = getSexp(count)
  expanded = lispSendReceive('M', sexp)
  for text in expanded.split("\n"):
    print text
  print >> sys.stderr, ""

def openSourceLocation():
  curword = vim.eval("expand(\"<cword>\")")
  resp = eval(lispSendReceive('L', curword))
  if type('') == type(resp):
    print >> sys.stderr, resp
  else:
    (fileloc, charno) = resp
    if vim.eval("expand(\"%:p\")") != fileloc:
      vim.command ("split " + fileloc)
    vim.command (str(charno + 1) + "go")
    gotoNextNonCommentChar()

### Pure receiving plugins

### If a new buffer happen, we need to make sure to re-import all the syntax additions
### Therefore, we have to keep a master list for all syntax additions that have ever been done
allSyntaxAdditions = []
def addSyntax(msgs):
  global allSyntaxAdditions

  if msgs != []:
    for msg in msgs:
      allSyntaxAdditions.extend(eval(msg))
    refreshSyntax()

registerReceiver('S', addSyntax, False)

def refreshSyntax():
  global allSyntaxAdditions
  vim.command("syn cluster lispAtomCluster add=lispLocalFunc")
  vim.command("syn cluster lispBaseListCluster add=lispLocalFunc")
  vim.command("hi def link lispLocalFunc Function")

  for syntax in allSyntaxAdditions:
    #print >> sys.stderr, syntax
    vim.command("syn keyword lispLocalFunc " + syntax)

def debugger(msgs):
  debugResponse = 0;
  debugText = msgs[0].split("\n")
  numRestarts = locale.atoi(debugText[0])
  while ((debugResponse < 1 or debugResponse > numRestarts) and debugResponse != "error"):
    try:
      vim.command ("redraw!")
      debugResponse = locale.atoi(vim.eval ("inputlist(" + str(debugText[1:]).replace("\\'", "''") + ")"))
    except:
      debugResponse = "error"
  lispSend('D', str(debugResponse))
registerReceiver('D', debugger, True)

def errorFromLisp(msgs):
  vim.eval ("input('" + msgs[0].replace("'", "''") + "')")
registerReceiver('E', errorFromLisp, False)

### Pure sending plugins
def sendInterrupt():
  lispSend('I', '')

### Asynchronous plugins
def sendSexp(count):
  global buffer
  openNekthuth()
  str = getSexp(count)
  if str == "":
    return
  msgs=[]
  for line in str.strip("\n").split("\n"):
    msgs.append("> " + line)
  lispSend('R', str)
  bufferSend(msgs)
  dumpLispMovement()

def replPrinter(msgs):
  msgs.append('')
  bufferSend(msgs)
  print
registerReceiver('R', replPrinter, True)

def omnifunc(findstart, base):
  if findstart == 1:
    curCol = locale.atoi(vim.eval("col('.')"))
    curLine = locale.atoi(vim.eval("line('.')"))
    vim.command ("let l:retn = " + str(getColBackwards(curCol - 2, vim.current.buffer[curLine - 1])))
  else:
    if base != '':
      vim.command ("let l:retn = " + lispSendReceive('C', '"' + base + '"'))
    else:
      vim.command ("let l:retn = []")

EOF

""" Help is a bit more complicated, and so get its own section
let s:tagsfile = findfile('ftplugin/lisp/nekthuth/hyperspecTags', escape(&runtimepath, ' '))

au BufRead HyperSpec.Help set updatetime=50
exe "set tags=" . s:tagsfile
exe "au BufNew HyperSpec.Help set tags=" . s:tagsfile
au CursorHold HyperSpec.Help call BuildHelp()

command! -complete=tag -nargs=1 Clhelp call OpenHelp("<args>")

let g:oldtag = ""
let g:tagname = ""

function! GetHelp(withwhat)
  let g:tagname = a:withwhat
  set updatetime=50
endfunction

function! BuildHelp()
  if (g:tagname != g:oldtag)
    setlocal buftype=nofile
    setlocal ft=help
    setlocal lbr
    silent 1,$d
    python displayHelp()
    set updatetime=500
    let g:oldtag = g:tagname
  endif
endfunction

function! OpenHelp(tagname)
  if ! empty(taglist(a:tagname))
    split ~/.vim/plugin/nekthuth/HyperSpec.Help
    exe "tag " . a:tagname
  else
    echoerr "Could not find help for " . a:tagname
  endif
endfunction

python << EOF
import vim,sys,re

def displayHelp():
  str = '"' + vim.eval("g:tagname") + '"'
  help = lispSendReceive('H', str)

  if re.compile("^Error:").match(help):
    vim.command(":close")
    vim.command(":redraw")
    print >> sys.stderr, help
  else:
    for line in help.strip("\n").split("\n"):
      vim.current.buffer.append(line)
EOF

for f in split(glob(g:nekthuth_home . "/vim/*.vim"), "\n")
  exec 'source' . f
endfor
