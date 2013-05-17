$LOAD_PATH.unshift File.join(__dir__, "lib")

require 'minitest/autorun'
require 'object-template'
require 'eq3'

class TestErrors < Minitest::Test
  POT = PortableObjectTemplate
  ROT = RubyObjectTemplate
  
  def test_bad_type
    assert_raises ArgumentError do
      POT.new [ {type: "float"} ]
    end
  end

  def test_bad_entry
    assert_raises ArgumentError do
      POT.new [ "number" ]
    end
  end

  def test_bad_match_specifier
    assert_raises ArgumentError do
      POT.new [ {foo: 1} ]
    end
  end
end
