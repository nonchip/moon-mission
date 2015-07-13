msgpack=require "MessagePack"

class Game
  new: (@options={})=>
    @data={}
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
  out: (str)=>
    print str
  whatDoYouMean: (words)=>
    @out "I don't understand that."
  askText: (question)=>
    print question
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