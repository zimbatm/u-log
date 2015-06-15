# See U::Log
module U; end
# U::Log is an opinionated logging library.
#
# The main take is that logs are structured.
# Too much time is spend formatting logs, they should look nice by default.
# That's why U::Log uses the lines format by default.
#
# Log everything in development AND production.
# Logs should be easy to read, grep and parse.
# Logging something should never fail.
# Let the system handle the storage. Write to syslog or STDERR.
# No log levels necessary. Just log whatever you want.
#
# Example:
#
#     U.log("Oops !", foo: {}, g: [])
#     #outputs:
#     # at=2013-03-07T09:21:39Z pid=3242 app=some-process msg="Oops !" foo={} g=[]
#
# Usage:
#
#     U.log(foo: 3, msg: "This")
#
#     ctx = U.log_context(encoding_id: Log.id)
#     ctx.log({})
#
module U::Log
  # A very simple logger and log context
  #
  class Logger
    NL = "\n".freeze

    # +out+ is the log destination. Has a #<< method that takes a string.
    # +format+ is what transforms the data into a string using the #dump method
    # +context+ is context data for the logger. Responds to #to_h.
    def initialize(output: $stderr, format: Lines, context: {})
      @output = output
      @format = format
      @context = context.to_h
    end

    # Outputs the given arguments merged with the context.
    #
    # If +key+ is given the whole kwargs is stored under that key
    #
    def log(key=nil, **kwargs)
      @output << format(args_to_hash(key, kwargs)) + NL
      nil
    end

    attr_reader :context
    alias_method :to_h, :context

    # Creates a derivative context so that `context(a: 1).context(b: 2)`
    # is equivalent to `contect(a: 1, b: 2)`
    def context(**data)
      return self if data.empty?
      self.class.new(
        output: @output,
        format: @format,
        context: @context.merge(data)
      )
    end
    alias_method :merge, :context

    # Formats the current context + given data with the formatter
    def format(data = {})
      @format.dump evaluate_procs(@context).merge(data)
    end
    alias to_s format

    # Returns a ::Logger-compatible object.
    #
    # Make sure to require 'u-log/compat' before invoking this method.
    def compat
      ::U::Log::Compat.new(self)
    end

    protected

    def evaluate_procs(obj)
      obj.each_with_object({}) do |(k, v), merged|
        merged[k] = v.respond_to?(:call) ? (v.call rescue $!) : v
      end
    end

    def args_to_hash(key, **kwargs)
      # Allow the first argument to be a message
      return {key => kwargs} if key
      kwargs
    end
  end
end

require 'lines'
require 'forwardable'

module U
  # Utility extensions to the global U namespace
  class << self
    extend Forwardable
    # Default logger that outputs to stderr with the Lines format
    attr_accessor :logger

    U.logger = Log::Logger.new.context(
      at:  -> { Time.now.utc },
      pid: -> { Process.pid },
    )

    # U.log shortcut for U.logger.log
    def_delegator :@logger, :log

    # U.log_context shotcut for U.logger.context
    def_delegator :@logger, :context, :log_context
  end
end
