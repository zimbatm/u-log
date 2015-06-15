U::Log - a different take on logging
====================================

[![Build Status](https://travis-ci.org/zimbatm/u-log.svg?branch=master)](https://travis-ci.org/zimbatm/u-log)

An oppinionated logging library.

* Log everything in development AND production.
* Logs should be easy to read, grep and parse.
* Logging something should never fail.
* Let the system handle the storage. Write to syslog or STDERR.
* No log levels necessary. Just log whatever you want.

STATUS: ALPHA
=============

Doc is still scarce so it's quite hard to get started. I think reading the
lib/u-log.rb should give a good idea of the capabilities.

It would be nice to expose a method that resolves a context into a hash. It's
useful to share the context with other tools like an error reporter. Btw,
Sentry/Raven is great.

Quick intro
-----------

```ruby
require 'u-log'

# Setups the outputs. IO and Syslog are supported.
l = U::Log.new($stderr, Lines,
  at:  ->{ Time.now.utc },
  pid: ->{ Process.pid },
)

# First example
l.log(foo: 'bar') # logs: at=2013-07-14T14:19:28Z foo=bar

# If not a hash, the argument is transformed. A second argument is accepted as
# a hash
l.log("Hey", count: 3) # logs: at=2013-07-14T14:19:28Z msg=Hey count=3

# You can also keep a context
class MyClass < ActiveRecord::Base
  attr_reader :logger

  def initialize(logger)
    @logger = logger.context(my_class_id: self.id)
  end

  def do_something
    logger.log("Something happened")
    # logs: at=2013-07-14T14:19:28Z msg='Something happeend' my_class_id: 2324
  end
end
```

Features
--------

* Simple to use
* Thread safe (if IO#write is)
* Designed to not raise exceptions (unless it's an IO issue)
* A backward-compatible Logger is provided in case you want to retrofit
* require "u-log/active_record" for sane ActiveRecord logs
* "u-log/rack_logger" is a logging middleware for Rack

Known issues
------------

Syslog seems to truncate lines longer than 2056 chars and Lines makes if very
easy to put too much data.

Lines logging speed is reasonable but it could be faster. It writes at around
5000 lines per second to Syslog on my machine.

Protocols
---------

`U::Log` is governed by a couple of protocols that help keep the library
composable.

TODO: describe these:

Formatter#dump

Outputter#<<

Data#to_h


Conventions
-----------

While underscore (`_`) is commonly used to separate `CamelCase` modules to
`camel_case.rb` file-names, no convention exists when a while library is
prefixed by a global namespace. That's why I am taking the dash (`-`)
character for it so that `U::Log` maps to `u-log.rb`.

The `U` namespace is my prefix for very small and composable modules.

Inspired by
-----------

 * Scrolls : https://github.com/asenchi/scrolls
 * Lograge : https://github.com/roidrage/lograge

TODO
----

* Don't automatically install the logger when requiring u-log/active_record
* Provide logging for all of rails
* Integrate with Error reporting
* Integrate with metrics collection
* include U::Log to add a #log method in an object
