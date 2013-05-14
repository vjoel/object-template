require 'minitest/autorun'
require 'object-template'
require 'assert-threequal'

class TestKeyConv < Minitest::Test
  include AssertThreequal

  POT = PortableObjectTemplate

  def test_match_converted_key
    assert_threequal(
      PortableObjectTemplate.new(
        {foo: {value: 1}},
          proc {|x| Symbol === x ? x.to_s : x}),
        {"foo" => 1}
    )
  end

  def test_not_match_unconverted_key
    assert_not_threequal(
      PortableObjectTemplate.new(
        {foo: {value: 1}},
          proc {|x| x}),
        {"foo" => 1}
    )
  end
end
