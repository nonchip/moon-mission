import Game, Scene from require "moon-mission"

class MySimpleGame extends Game
  initscene: "First"
  scenes: {

    First: class extends Scene
      enter: =>
        @game\out "Welcome to #{@game.name}!"
        @game.data.username=@game\askText "What's your name?"
        @game\out "Maybe you want to 'continue'..."
      c_continue: =>
        @game\to "Second"
      exit: =>
        @game\out "You're leaving the First scene."

    Second: class extends Scene
      enter: =>
        @game\out "You entered the Second scene."
        @game\out "Bye, #{@game.data.username}"
        @game\quit!

  }

MySimpleGame run: true

