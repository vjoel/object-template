require 'minitest/autorun'
require 'object-template'
require 'assert-threequal'

class TestMatch < Minitest::Test
  include AssertThreequal
  
  attr_reader :spec, :template
  
  def setup
    @spec =
      [ {value: "foo"},
        nil,
        {set: ["red", "green"]},
        {type: "number"},
        {type: "number", range: [1,100]} ]
    @template = ObjectTemplate.new spec
  end

  def test_match
    [
      [ "foo", [1,2,"three"], "green", 5.02, 42 ],
      [ "foo", {}, "red", -99, 99 ]
    ].each do |obj|
      assert_threequal template, obj
    end
  end
  
  def test_not_match
    [
      [ "bar", {}, "red",  -99, 1 ],
      [ "foo", {}, "blue", -99, 1 ],
      [ "foo", {}, "red", "99", 1 ],
      [ "foo", {}, "red",  -99, 0 ],
      [ "foo" ],
      [ "foo", {}, "red",  -99, 1, "extra" ],
      [ ],
    ].each do |obj|
      assert_not_threequal template, obj
    end
  end
  
  def test_match_types
    assert_threequal(
      ObjectTemplate.new([{type: "string"}]),
      [ "some string" ]
    )
    assert_threequal(
      ObjectTemplate.new([{type: "number"}]),
      [ 42 ]
    )
    assert_threequal(
      ObjectTemplate.new([{type: "list"}]),
      [ [1,2,3] ]
    )
    assert_threequal(
      ObjectTemplate.new([{type: "map"}]),
      [ {a: 1} ]
    )
    
    assert_not_threequal(
      ObjectTemplate.new([{type: "string"}]),
      [ 12 ]
    )
    assert_not_threequal(
      ObjectTemplate.new([{type: "number"}]),
      [ "42" ]
    )
    assert_not_threequal(
      ObjectTemplate.new([{type: "list"}]),
      [ {a: 1} ]
    )
    assert_not_threequal(
      ObjectTemplate.new([{type: "map"}]),
      [ [1,2,3] ]
    )
  end
  
  def test_regex
    assert_threequal(
      ObjectTemplate.new([{type: "string", regex: "^f...r$"}]),
      [ "fubar" ]
    )
    assert_not_threequal(
      ObjectTemplate.new([{type: "string", regex: "^f...r$"}]),
      [ "zfubarz" ]
    )
  end
end
