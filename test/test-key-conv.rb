require 'minitest/autorun'
require 'object-template'
require 'assert-threequal'

class TestKeyConv < Minitest::Test
  include AssertThreequal

  POT = PortableObjectTemplate
  ROT = RubyObjectTemplate

  def test_match_converted_key
    assert_threequal(
      POT.new(
        {foo: {value: 1}},
          proc {|x| Symbol === x ? x.to_s : x}),
        {"foo" => 1}
    )

    assert_threequal(
      ROT.new(
        {foo: 1},
          proc {|x| Symbol === x ? x.to_s : x}),
        {"foo" => 1}
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
