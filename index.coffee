system = require "node-system"

module.exports =

  # Everything is in this run function, which is called from bin/madpanda ...
  # could this be a bit more modular? Yes!
  run: ->

    # Package Modules

    # IRC is the star of our show, obviously ...
    {Client} = require("irc")

    # Load the configuration ...
    config = require "./config"
    {host,password,nick} = config.server
    {channel} = config

    # Helper Functions

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

    commands =
      whois: (domain) ->
        whois = system("whois #{domain}")
        if whois.match /No match/
          say "No match for #{domain}"
        else
          say "#{domain} is taken"

      archer: ->
        scraper = require 'scraper'
        options =
           uri: 'http://en.wikiquote.org/wiki/Archer_(TV_series)',
           headers:
             'User-Agent': 'User-Agent: Archerbot for MadPanda'

        scraper options, (err, jQuery) ->
          throw err  if err
          quotes = jQuery("dl").toArray()
          dialog = ''
          quote = quotes[Math.floor(Math.random()*quotes.length)]
          dialog += jQuery(quote).text().trim() + "\n"
          say dialog

      gif: (terms...) ->
        http = (require "scoped-http-client").create
        random = (array) -> array[Math.floor(Math.random() * array.length)]
        client_id = 'Client-ID ' + "2421109ee0e8d3d"
        http('https://api.imgur.com/3/gallery/search')
          .headers(Authorization: client_id)
          .query(q: escape(terms.join(" ")))
          .get() (err, res, body) ->
            images = JSON.parse(body).data
            if images.length > 0
              image = random images
              console.log image
              say image.link
            else
              say "I had something for this..."

      all: (terms...)->
        users = client.chans[ch channel.name].users
        console.log users
        users = ("#{user}: " for user, _ of users when user != nick)
        say users.join("") + terms.join(" ")

    # Some event handlers - first, the 'connect' handler. Basically, once we're
    # connected to the server, we join the channel we want to chat on.
    client.on "connect", ->
      client.join ch "#{channel.name} #{channel.password}"

    # An error handler in case something's gone wrong.
    client.on "error", (error) ->
      console.log error
      process.exit(-1)

    # Here's where the fun begins. We get message events and handle them.
    # There's actually a third parameter to the callback, which has the
    # JSONized message in full, but we don't really need that.

    client.on "message##{channel.name}", (from, text) ->
      [who, command, args...] = text.split(" ")
      return unless who is "#{nick}:"
      commands[command]?(args...)
