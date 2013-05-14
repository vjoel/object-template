require 'minitest/autorun'
require 'object-template'

class TestMatch < Minitest::Test
  attr_reader :spec, :template
  
  def assert_threequal o1, o2, msg = nil
    msg = message(msg) { "Expected #{mu_pp(o1)} to be === #{mu_pp(o2)}" }
    assert o1.__send__(:===, o2), msg
  end
  
  def assert_not_threequal o1, o2, msg = nil
    msg = message(msg) { "Expected #{mu_pp(o1)} to be !== #{mu_pp(o2)}" }
    assert !(o1.__send__(:===, o2)), msg
  end
  
  def setup
    @spec =
      [ {value: "foo"},
        nil,
        {set: ["red", "green"]},
        {type: "number"} ]
    @template = ObjectTemplate.new spec
  end

  def test_match
    [
      [ "foo", [1,2,"three"], "green", 5.02 ],
      [ "foo", {}, "red", -99 ]
    ].each do |obj|
      assert_threequal template, obj
    end
  end
  
  def test_not_match
    [
      [ "bar", {}, "red", -99 ],
      [ "foo", {}, "blue", -99 ],
      [ "foo", {}, "red", "99" ],
      [ "foo" ],
      [ "foo", {}, "red", -99, "extra" ],
      [ ],
    ].each do |obj|
      assert_not_threequal template, obj
    end
  end
end
