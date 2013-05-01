#!/usr/bin/env ruby

require 'test/unit'
require 'testml'
require 'testml/bridge'
require 'testml/util'

class TestMLBridge < TestML::Bridge
  include TestML::Util

  def compile(livescript)
    str run('livescript --compile --bare', livescript)
  end

  def tokenize(livescript)
    str run('livescript --tokens', livescript)
  end

  def to_ast(livescript)
    str run('livescript --ast', livescript)
  end

  def eval(livescript)
    native run('livescript --print', livescript)
  end

  def run(command, input)
    output = ''
    IO.popen(command, 'r+') { |p|
      p.puts(input.value)
      p.close_write
      output += p.read until p.eof?
    }
    return output
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
