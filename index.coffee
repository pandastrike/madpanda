twss = require "twss"
twss.threshold = 0.9

module.exports =
  
  # Everything is in this run function, which is called from bin/madpanda ...
  # could this be a bit more modular? Yes!  
  run: -> 
  
    # Package Modules
    
    # IRC is the star of our show, obviously ...
    {Client} = require("irc")

    # GitHub gives us access to repos 
    GitHub = require "github"
    github = new GitHub version: "3.0.0"


    # Local Modules
    
    # Include Eliza just for fun. She has one method: #reply.
    eliza = require "./eliza"

    # Load the configuration ...
    config = require "./config"
    {host,password,nick} = config.server
    {channel} = config
    
    # Helper Functions

    # A simple function to get the last commit from 
    # the patchboard repository. This is more as a demonstration of what's
    # possible.
    last_commit = (callback)->
      github.repos.getCommits
        user: "automatthew"
        repo: "patchboard"
        (error,commits) ->
          if error
            callback error.message
          else
            callback commits[0]
      
    # A function that prepends a # to a string, basically. Mostly here because
    # TextMate keeps trying to be helpful and turns the # into #{}.
    ch = (name) -> "##{name}"

    # The Main Event
    
    # Connect to the server - this is async, so nothing happens until we get the
    # 'connect' event.    
    client = new Client host, nick, password: password, debug: true
    
    # A helper function for chatting ... needs the client variable here for the
    # closure which is why it's defined here.    
    say = (message) ->
      client.say (ch channel.name), message

    # Some event handlers - first, the 'connect' handler. Basically, once we're
    # connected to the server, we join the channel we want to chat on.    
    client.on "connect", -> 
      client.join ch "#{channel.name} #{channel.password}"

    # An error handler in case something's gone wrong.
    client.on "error", (error) ->
      console.log error
      process.exit(-1)
  
    # Here's where the fun begins. We get message events and handle them. There's
    # actually a third parameter to the callback, which has the JSONized message
    # in full, but we don't really need that.        
    client.on "message##{channel.name}", (from,text) ->
      
      # You talkin' to me? (This triple slash business allows you to do
      # interpolation in regexps in CoffeeScript.)      
      if twss.is(text)
        say "That's what she said"
      else if text.match ///^#{nick}///
        
        # MADPANDA doesn't like small talk!
        if text.match /weather/
          say "DO I LOOK LIKE A GODDAMN WEATHERMAN!"
        # But he's always eager to tell you about patchboard ...
        else if text.match /patchboard/
          last_commit (info) -> 
            if info.commit
              {message} = info.commit
              {login} = info.committer
              say "Last commit: '#{message}' by #{login}"
            else
              say "DUMBASS PROGRAMMER MESSED UP SOMETHING!"
        # Or to help you work through your issues ...
        else
          say eliza.reply text
