require 'benchmark/ips'
require 'stringio'

data = 100.times.map{ 'sadfljkasfjlk' }

Benchmark.ips do |x|
  x.report "join" do |n|
    n.times do
      data.join
    end
  end
  x.report "StringIO" do |n|
    n.times do
      s = StringIO.new('wb')
      data.each do |y|
        s.write y
      end
      s.string
    end
  end
  x.report "inject+" do |n|
    n.times do
      data.inject(&:+)
    end
  end
end
