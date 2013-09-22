## Xerox is a toolkit for bootstrapping and developing WordPress themes.

[Xerox website](https://github.com/jasonwebster/xerox)

Xerox makes building WordPress themes managable for people used to working
with Sass, CoffeeScript and a Sprockets based asset pipeline.

Props to the Theme Foundry guys for writing
[forge](http://forge.thethemefoundry.com/), on which Xerox was initially based.

-----

Current Version: **0.1.0**

Install Xerox (requires [Ruby](http://www.ruby-lang.org/),
[RubyGems](http://rubygems.org/), and [Bundler](http://bundler.io/)):

    $ gem install xerox

Create your new project:

    $ xerox create your_theme

Change to your new project directory:

    $ cd your_theme

Link to your WordPress theme folder:

    $ xerox link /path/to/wordpress/wp-content/themes/your_theme

Watch for changes and start developing!

    $ xerox watch

Press Ctrl + C to exit watch mode.

Build your theme for packaging or deployment:

    $ xerox build

Get a little help with the Xerox commands:

    $ xerox help
