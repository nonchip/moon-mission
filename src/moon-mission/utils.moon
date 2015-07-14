bit=require "bit"
ffi=require "ffi"
string=require "string"

_string={}

_string.wrap=(s)->
  return extend copy(s),_string

_string.starts=(String,Start)->
  return string.sub(String,1,string.len(Start))==Start

_string.ends=(String,End)->
  return End=='' or string.sub(String,-string.len(End))==End

_string.trim=(s)->
  return s\match'^()%s*$' and '' or s\match'^%s*(.*%S)'

_string.gsplit=(s, sep, plain)->
  start = 1
  done = false
  pass=(i, j, ...)->
    if i
      seg = s\sub(start, i - 1)
      start = j + 1
      return seg, ...
    else
      done = true
      return s\sub(start)
  return ->
    return if done
    if sep == ''
      done = true
      return s
    return pass s\find sep, start, plain

_string.dedent=(s)->
  return _string.trim table.concat [_string.trim l for l in _string.gsplit s, "\n"], "\n"

_string.wrap_simple=(str, limit, indent, indent1)->
  indent or= ""
  indent1 or= indent
  limit or= 72
  here = 1-#indent1
  return indent1..str\gsub "(%s+)()(%S+)()", (sp, st, word, fi)->
    if fi-here > limit
      here = st - #indent
      return "\n"..indent..word

_string.wrap=(str,limit,indent,indent1)->
  table.concat [_string.wrap_simple l,limit,indent,indent1 for l in _string.gsplit str,"\n"], "\n"






_io={}


socket=require 'socket'
-- i'm so terribly sorry for this one, but using ffi and syscalls for select() is even more hacky.
keyboard = socket.tcp!
keyboard\close!
keyboard\setfd 0

_io.select=(timeout=0)->
  r,w,e=socket.select({keyboard}, nil , timeout)
  return r[1]==keyboard and e!="timeout"

{string:_string, io:_io}
