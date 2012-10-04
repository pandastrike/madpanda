module.exports =
  run: -> 
    {Client} = require("irc")
    GitHub = require "github"
    github = new GitHub version: "3.0.0"
    {inspect} = require "util"
    eliza = require "./eliza"

    last_commit = (callback)->
      github.repos.getCommits
        user: "automatthew"
        repo: "patchboard"
        (error,commits) ->
          if error
            callback error.message
          else
            callback commits[0]
      
    ch = (name) -> "##{name}"

    client = new Client "irc.linelinc.com", "MADPANDA"
      password: "enterthedragon"
      debug: true

    say = (message) ->
      client.say (ch "pandastrike"), message

    client.on "connect", -> 
      client.join ch "pandastrike eatmycheese"

    client.on "error", (error) ->
      console.log error
      process.exit(-1)
  
    client.on "message#pandastrike", (from,text) ->
      if text.match /^MADPANDA/
        if text.match /weather/
          say "DO I LOOK LIKE A GODDAMN WEATHERMAN!"
        else if text.match /patchboard/
          last_commit (info) -> 
            if info.commit
              {message} = info.commit
              {login} = info.committer
              say "Last commit: '#{message}' by #{login}"
            else
              say "DUMBASS PROGRAMMER MESSED UP SOMETHING!"
        else
          say eliza.reply text
          #say "HOW DARE YOU WASTE MY TIME WITH SUCH FOOLISHNESS!"
