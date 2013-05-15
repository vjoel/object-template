require 'minitest/autorun'
require 'object-template'
require 'eq3'
require 'set'

class Member < Set ## ?
  def === other
    member? other
  end
end

class TestMatchTD < Minitest::Test
  include Eq3
  
  def test_cardinality
#=========================================================
#=            LITERAL |             ROT |            POT
#=========================================================
#= 1. every test that can be expressed in terms of presence of column/field
#=    or cardinality of columns/fields, without matching values
#=
eq3                 [],              [],              []
eq3       ["anything"],           [nil],           [nil]
eq3   ["any", "thing"],      [nil, nil],      [nil, nil]
#=========================================================
ne3       ["anything"],              [],              []
ne3                 [],           [nil],           [nil] # cardinality mismatch
ne3   ["any", "thing"],           [nil],           [nil] # ditto
ne3       ["anything"],      [nil, nil],      [nil, nil]
#=========================================================
#= 1a. specific to hashes
ne3( {foo: "anything"},      {bar: nil},      {bar: nil} ) # name mismatch
#=========================================================
  end

  def test_literal
#=========================================================
#=            LITERAL |             ROT |            POT
#=========================================================
#= 2. every test that can be expressed in terms of a literal value in the
#=    template
#=
literals = [
  true, false,
  42, -1.2e13, "baz",
  [1,2,3], {a: 1, b: 2}
]
literals.each do |x1|
  literals.each do |x2|
    if x1 == x2
      eq3         [x1],            [x1],   [{value: x1}]
    else
      ne3         [x1],            [x2],   [{value: x2}]
    end
    eq3       [x1, x2],        [x1, x2],   [{value: x1}, {value: x2}]
  end
end
#=========================================================
  end

  def test_set
#=========================================================
#=            LITERAL |             ROT |            POT
#=========================================================
#= 3. every test that can be expressed in terms of a set of values in the
#=    template
#=
eq3                [1], [Member[0,1,2]], [{set: [0,1,2]}]
#=========================================================
ne3                [4], [Member[0,1,2]], [{set: [0,1,2]}]
#=========================================================
  end
end
