$LOAD_PATH.unshift File.join(__dir__, "lib")

require 'minitest/autorun'
require 'object-template'
require 'set'
require 'eq3'

Member = ObjectTemplate::MemberMatchingSet

class TestMatch < Minitest::Test
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
  43, 2.4507, "zap",
  [1,2,3], {a: 1, b: 2},
  ["a", "b"], {x: "y"}
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

  def test_range
#=========================================================
#=            LITERAL |             ROT |            POT
#=========================================================
#= 4. every test that can be expressed in terms of a range in the
#=    template
#=
eq3                [0],          [0..2], [{range: [0,2]}]
eq3                [2],          [0..2], [{range: [0,2]}]
eq3                [1],         [0...2], [{range: [0,2, true]}]
#=========================================================
ne3               [-1],          [0..2], [{range: [0,2]}]
ne3                [3],          [0..2], [{range: [0,2]}]
ne3                [2],         [0...2], [{range: [0,2, true]}]
#=========================================================
  end

  def test_regex
#=========================================================
#=            LITERAL |             ROT |            POT
#=========================================================
#= 5. every test that can be expressed in terms of a regex in the
#=    template
#=
eq3            ["foo"],          [/oo/], [{regex: "oo"}]
eq3            ["foo"],     [/[f]\w\w/], [{regex: "[f]\\w\\w"}]
#=========================================================
ne3            ["foo"],          [/zz/], [{regex: "zz"}]
ne3            ["foo"],       [/o{3,}/], [{regex: "o{3,}"}]
#=========================================================
  end

  def test_type
#=========================================================
#=            LITERAL |             ROT |            POT
#=========================================================
#= 6. every test that can be expressed in terms of a type in the
#=    template
#=
eq3               [42],       [Numeric], [{type: "number"}]
eq3            ["foo"],        [String], [{type: "string"}]
eq3          [[1,2,3]],         [Array], [{type: "list"}]
eq3       [{a:1, b:2}],         [Hash],  [{type: "map"}]
#=========================================================
ne3             ["42"],       [Numeric], [{type: "number"}]
ne3              [123],        [String], [{type: "string"}]
ne3       [{a:1, b:2}],         [Array], [{type: "list"}]
ne3          [[1,2,3]],         [Hash],  [{type: "map"}]
#=========================================================
  end

  def test_conjunction
    ## note that ROT doesn't support conjunctions, though it would be easy
    ## to implement.
    eq3 ["abc"], [nil], [{type: "string", regex: "b", set: ["abc", "def"]}]
    ne3 ["abc"],   [0], [{type: "list",   regex: "b", set: ["abc", "def"]}]
    ne3 ["abc"],   [0], [{type: "string", regex: "d", set: ["abc", "def"]}]
    ne3 ["abc"],   [0], [{type: "string", regex: "b", set: ["xyz", "def"]}]
  end

  # test that a mismatch in one entry makes the template match fail
  def test_all_entries
    eq3 [                5,           1.23,            "bar",         "baz",          [1,2],          {a: 1} ],
        [          Numeric,           1..3,           String,          /az/,          Array,          {a: 1} ],
        [ {type: "number"}, {range: [1,3]}, {type: "string"}, {regex: "az"}, {type: "list"}, {value: {a: 1}} ]

    ne3 [            "foo",           1.23,            "bar",         "baz",          [1,2],          {a: 1} ],
        [          Numeric,           1..3,           String,          /az/,          Array,          {a: 1} ],
        [ {type: "number"}, {range: [1,3]}, {type: "string"}, {regex: "az"}, {type: "list"}, {value: {a: 1}} ]

    ne3 [                5,           4.23,            "bar",         "baz",          [1,2],          {a: 1} ],
        [          Numeric,           1..3,           String,          /az/,          Array,          {a: 1} ],
        [ {type: "number"}, {range: [1,3]}, {type: "string"}, {regex: "az"}, {type: "list"}, {value: {a: 1}} ]

    ne3 [                5,           1.23,          ["bar"],         "baz",          [1,2],          {a: 1} ],
        [          Numeric,           1..3,           String,          /az/,          Array,          {a: 1} ],
        [ {type: "number"}, {range: [1,3]}, {type: "string"}, {regex: "az"}, {type: "list"}, {value: {a: 1}} ]

    ne3 [                5,           1.23,            "bar",         "bAz",          [1,2],          {a: 1} ],
        [          Numeric,           1..3,           String,          /az/,          Array,          {a: 1} ],
        [ {type: "number"}, {range: [1,3]}, {type: "string"}, {regex: "az"}, {type: "list"}, {value: {a: 1}} ]

    ne3 [                5,           1.23,            "bar",         "baz",          {a:2},          {a: 1} ],
        [          Numeric,           1..3,           String,          /az/,          Array,          {a: 1} ],
        [ {type: "number"}, {range: [1,3]}, {type: "string"}, {regex: "az"}, {type: "list"}, {value: {a: 1}} ]

    ne3 [                5,           1.23,            "bar",         "baz",          [1,2],          {a: 2} ],
        [          Numeric,           1..3,           String,          /az/,          Array,          {a: 1} ],
        [ {type: "number"}, {range: [1,3]}, {type: "string"}, {regex: "az"}, {type: "list"}, {value: {a: 1}} ]

  end
end
