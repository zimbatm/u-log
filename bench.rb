$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../../lines-ruby/lib', __FILE__)


require 'benchmark/ips'
require 'u-log'

message = {
  at: Time.now.utc,
  pid: Process.pid,
  app: File.basename($0),
  pri: :info,
  msg: "This is my message",
  elapsed: [344, 'ms'],
}

formatters = [
  ['u-log', 'U::Log::Fmt'],
  ['u-log', 'U::Log::Fmt2'],
  ['u-log', 'U::Log::Fmt3'],
  ['u-log', 'U::Log::Fmt4'],
  ['u-log', 'U::Log::Fmt5'],
  ['json', 'JSON'],
  ['lines', 'Lines'],
  ['msgpack', 'MessagePack'],
]

Benchmark.ips do |x|
  formatters.each do |(feature, mod_name)|
    begin
      require feature

      mod = eval(mod_name)

      unless mod.respond_to?(:dump)
        puts "mod #{mod} doesn't respond to #dump"
        next
      end

      p [feature, mod, mod.dump(message)]

      x.report mod_name do |n|
        n.times do
          U::Log::Fmt.dump(message)
        end
      end
    rescue LoadError
      puts "could not load #{feature}"
    end
  end
end
