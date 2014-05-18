module U; module Log
  # Very simple k="v" log format used by default by the Logger.
  #
  # Should be compatible for logfmt parsing. See
  # http://godoc.org/github.com/kr/logfmt
  module Fmt; extend self
    def dump(obj)
      obj.map do |(k, v)|
        "#{k}=#{dump_v v}"
      end.join(' ')
    end

    def dump_v(obj)
      obj = obj.to_s
      obj.index(/['"\s]/) ? obj.inspect : obj
    rescue
      $!.to_s
    end
  end

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

module U
  # Default global
  @logger = Log::Logger.new($stderr, Log::Fmt,
    at:  ->{ Time.now.utc },
    pid: ->{ Process.pid },
  )

  class << self
    # Default logger that outputs to stderr with the Logfmt format
    attr_accessor :logger

    # shortcut for U.logger.log
    def log(*args); logger.log(*args); end
    # shotcut for U.logger.context
    def log_context(data={}); logger.context(data); end
  end
end
