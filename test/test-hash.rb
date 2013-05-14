require 'minitest/autorun'
require 'object-template'
require 'assert-threequal'

class TestHash < Minitest::Test
  include AssertThreequal

  def test_match_empty_template
    assert_threequal(
      ObjectTemplate.new(
        {}),
        {}
    )
  end

  def test_match_nil_template
    assert_threequal(
      ObjectTemplate.new(
        {foo: nil}),
        {foo: "anything"}
    )
  end

  def test_not_match_missing_fields
    assert_not_threequal(
      ObjectTemplate.new(
        {foo: nil}),
        {}
    )
  end

  def test_not_match_extra_fields
    assert_not_threequal(
      ObjectTemplate.new(
        {foo: nil}),
        {foo: "anything", bar: 0}
    )
  end
end
