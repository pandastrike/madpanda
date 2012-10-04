This is a simple IRC bot, which will hopefully become increasingly useful and entertaining. Presently, the features include:

* The ability to report on the last commit to the [patchboard][] project if you ask about it.
* The ability to act as a therapist, ala [Eliza][].
* A tendency to get ornery when asked about the weather.

[patchboard]: https://github.com/automatthew/patchboard
[Eliza]: http://en.wikipedia.org/wiki/ELIZA

To install and run:

  git clone git@github.com:dyoder/madpanda.git
  cd madpanda
  npm install
  bin/madpanda
  
All the interesting source is in `index.coffee`. The Eliza code is adapted from [aeter/eliza-coffee][].

[aeter/eliza-coffee]: https://github.com/aeter/eliza-coffee