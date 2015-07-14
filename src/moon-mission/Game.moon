msgpack=require "MessagePack"
utils=require "moon-mission.utils"
dedent=utils.string.dedent
gsplit=utils.string.gsplit
wrap=utils.string.wrap

class Game
  new: (@options={})=>
    @data or={}
    @name or= @__class.__name
    @scene_instances={k,v @ for k,v in pairs @scenes}
    if @options.load
      l=msgpack.unpack @options.load
      for k,v in pairs l.data
        @data[k]=v
      @to l.cs
    else
      @to @initscene
    if @options.run
      @run!
  run: =>
    @running=true
    while @running
      inp=io.read "*l"
      words=[w for w in inp\gmatch("%w+")]
      if @currentscene["c_"..words[1]]
        @currentscene["c_"..words[1]] @currentscene, words
      elseif @["c_"..words[1]]
        @["c_"..words[1]] @, words
      else
        @whatDoYouMean words
  out: (str,strip=true,more=10,wrapl=60)=>
    if strip
      str=dedent str
    if wrapl>0
      str=wrap str,wrapl, "  ",""
    if more>0
      i=0
      for l in gsplit str,"\n"
        i+=1
        print l
        if i>more
          i=0
          @more!
    else
      print str
  more: =>
    io.write "[More...] "
    io.flush!
    io.read "*l"
  whatDoYouMean: (words)=>
    @out "I don't understand that."
  askText: (...)=>
    @out ...
    io.read "*l"
  quit: =>
    @running=false
  to: (s)=>
    old=@currentscene
    @currentscene=@scene_instances[s]
    @currentscene_name=s
    if old ~= @currentscene
      old\exit! if old
      @currentscene\enter! if @currentscene
  save: =>
    msgpack.pack({cs:@currentscene_name,data:@data})