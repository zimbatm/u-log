$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'stringio'

require 'u-log'

class U_LoggerTest < MiniTest::Spec
  include U::Log
  NL = "\n"

  def setup
    @out = StringIO.new
    @ctx = Logger.new(output: @out)
  end

  describe 'context' do
    it 'does stuff' do
      @ctx.log('hello', foo: 3)
      assert_equal 'hello={foo=3}' + NL, @out.string
    end
  end
end
