#!/usr/bin/env ruby

require 'test/unit'
require 'testml'
require 'testml/bridge'
require 'testml/util'

class TestMLBridge < TestML::Bridge
  include TestML::Util
  def compile(livescript)
    javascript = ''
    IO.popen('livescript --compile --bare', 'r+') { |p|
      p.puts(livescript.value)
      p.close_write
      while not p.eof?
        javascript += p.read
      end
    }
    return str javascript
  end
end

class Test::TestML < Test::Unit::TestCase
  files = ARGV.empty? ? Dir.glob('./*.tml') : ARGV.clone

  files.each do |file|
    method_name = 'test_' + file.gsub(/\W/, '_').sub(/_tml$/, '')
    define_method(method_name.to_sym) do
      TestML.new(
        testml: File.read(file),
        bridge: TestMLBridge,
      ).run(self)
    end
  end
end
