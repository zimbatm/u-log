$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../../lines-ruby/lib', __FILE__)

require 'benchmark/ips'
require 'u-log'
require 'time'

$message = {
  at: Time.now.utc.iso8601,
  pid: Process.pid,
  app: File.basename($0),
  pri: :info,
  msg: "This is my message",
  elapsed: [344, 'ms'],
}

Array.new(10 ** 7).to_s

formatters = [
  ['u-log', "U::Log::Fmt.dump($message)"],
  ['lines', "Lines.dump($message)"],

  ['json', "$message.to_json"],
  ['oj', "Oj.dump($message)"],
  ['yajl', "Yajl.dump($message)"],
  
  ['msgpack', "MessagePack.dump($message)"],
  ['bson', "$message.to_bson"],
  ['tnetstring', "TNetstring.dump($message)"],
]

Benchmark.ips do |x|
  x.compare!
  formatters.each do |(feature, action)|
    begin
      require feature

      data = eval action
      puts "%-12s %-5d %s" % [feature, data.size, data]

      x.report feature, action
    rescue LoadError
      puts "could not load #{feature}"
    end
  end
end
