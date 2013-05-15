require 'minitest/autorun'
require 'object-template'
require 'eq3'

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
end
