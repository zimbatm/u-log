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
#     
#     U.log(foo: 3, msg: "This")
#
#     ctx = U.log_context(encoding_id: Log.id)
#     ctx.log({})
#
module U; module Log
  # A very simple logger and log context
  #
  class Logger
    NL = "\n".freeze

    # +out+ is the log destination. Has a #<< method that takes a string.
    # +format+ is what transforms the data into a string using the #dump method
    # +data+ is context data for the logger. Responds to #to_h.
    def initialize(out, format, data)
      @out = out
      @format = format
      @data = data.to_h
    end

    # Outputs the given arguments merged with the context.
    def log(*args)
      @out << with_data(args_to_hash args).to_s + NL
    end

    # Creates a derivative context so that `context(a: 1).context(b: 2)`
    # is equivalent to `contect(a: 1, b: 2)`
    def context(data = {})
      return self unless data.to_h.any?
      with_data @data.merge(data.to_h)
    end

    alias merge context

    def to_s
      @format.dump(evaluate_procs @data)
    end

    def to_h; @data; end

    # Returns a ::Logger-compatible object.
    #
    # Make sure to require 'u-log/compat' before invoking this method.
    #
    def compat; Compat.new(self) end

    protected

    def with_data(data)
      self.class.new @out, @format, data
    end

    def evaluate_procs(obj)
      obj.each_with_object({}) do |(k,v), merged|
        merged[k] = v.respond_to?(:call) ? (v.call rescue $!) : v
      end
    end

    def args_to_hash(args)
      return {} if args.empty?
      data = @data.dup
      # Allow the first argument to be a message
      if !args.first.respond_to? :to_h
        data.merge!(msg: args.shift)
      end
      args.inject(data) do |h, obj|
        h.merge! obj.to_h
      end
      data
    end
  end
end end

require 'lines'
require 'forwardable'

module U
  class << self
    extend Forwardable
    # Default logger that outputs to stderr with the Lines format
    attr_accessor :logger

    U.logger = Log::Logger.new($stderr, Lines,
      at:  ->{ Time.now.utc },
      pid: ->{ Process.pid },
    )

    # U.log shortcut for U.logger.log
    def_delegator :@logger, :log

    # U.log_context shotcut for U.logger.context
    def_delegator :@logger, :log, :log_context
  end
end