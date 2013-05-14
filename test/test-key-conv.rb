require 'minitest/autorun'
require 'object-template'
require 'assert-threequal'

class TestHash < Minitest::Test
  include AssertThreequal

  def test_match_converted_key
    assert_threequal(
      ObjectTemplate.new(
        {foo: {value: 1}},
          proc {|x| Symbol === x ? x.to_s : x}),
        {"foo" => 1}
    )
  end

  def test_not_match_unconverted_key
    assert_not_threequal(
      ObjectTemplate.new(
        {foo: {value: 1}},
          proc {|x| x}),
        {"foo" => 1}
    )
  end
end
