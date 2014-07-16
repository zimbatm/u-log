module U; module Log
  # Backward-compatible with the stdlib Logger
  # http://ruby-doc.org/stdlib-2.0/libdoc/logger/rdoc/Logger.html
  class Compat
    LEVELS = {
      0 => :debug,
      1 => :info,
      2 => :warn,
      3 => :error,
      4 => :fatal,
      5 => :unknown,
    }

    attr_reader :ulogger

    def initialize(ulogger)
      @ulogger = ulogger
    end

    def log(severity, message = nil, progname = nil, &block)
      pri = LEVELS[severity] || severity
      if block_given?
        progname = message
        message = yield rescue $!
      end

      data = { pri: pri }
      data[:app] = progname if progname
      data[:msg] = message if message

      @ulogger.log(data)
    end

    LEVELS.values.each do |level|
      eval "def #{level}(msg=nil, &block); log(:#{level}, msg, &block); end"
    end

    alias << info
    alias unknown info

    def noop(*); true end
    %w[add
      clone
      datetime_format
      datetime_format=
      debug?
      info?
      error?
      fatal?
      warn?
      level
      level=
      progname
      progname=
      sev_threshold
      sev_threshold=
    ].each do |op|
      alias_method(op, :noop)
    end
  end
end end
