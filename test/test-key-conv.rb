$LOAD_PATH.unshift File.join(__dir__, "lib")

require 'minitest/autorun'
require 'object-template'
require 'assert-threequal'

begin
  require 'msgpack'
rescue LoadError
  $stderr.puts "skipping TestKeyConv: msgpack lib not available"
else

  class TestKeyConv < Minitest::Test
    include AssertThreequal

    POT = PortableObjectTemplate
    ROT = RubyObjectTemplate

    CK_STR = proc {|x|
      MessagePack.load(
        MessagePack.dump(x))}
    CK_SYM = proc {|x|
      MessagePack.load(
        MessagePack.dump(x), symbolize_keys: true)}

    def test_match_converted_key
      assert_threequal(
        POT.new(
          {foo: {value: {bar: 1}}}, CK_STR),
          {"foo" => {"bar" => 1}}
      )

      assert_threequal(
        POT.new(
          {foo: {value: {"bar" => 1}}}, CK_STR),
          {"foo" => {"bar" => 1}}
      )

      assert_threequal(
        ROT.new(
          {foo: {bar: 1}}, CK_STR),
          {"foo" => {"bar" => 1}}
      )

      assert_threequal(
        ROT.new(
          {"foo" => {"bar" => 1}}, CK_STR),
          {"foo" => {"bar" => 1}}
      )

      assert_threequal(
        POT.new(
          {foo: {value: {bar: 1}}}, CK_SYM),
          {foo: {bar: 1}}
      )

      assert_threequal(
        POT.new(
          {foo: {value: {"bar" => 1}}}, CK_SYM),
          {foo: {bar: 1}}
      )

      assert_threequal(
        ROT.new(
          {foo: {bar: 1}}, CK_SYM),
          {foo: {bar: 1}}
      )

      assert_threequal(
        ROT.new(
          {"foo" => {"bar" => 1}}, CK_SYM),
          {foo: {bar: 1}}
      )
    end

    def test_not_match_unconverted_key
      assert_not_threequal(
        POT.new(
          {foo: {value: 1}},
            proc {|x| x}),
          {"foo" => 1}
      )

      assert_not_threequal(
        ROT.new(
          {foo: 1},
            proc {|x| x}),
          {"foo" => 1}
      )
    end
  end

end
