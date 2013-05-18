require 'assert-threequal'

module Eq3
  include AssertThreequal
  
  ROT = RubyObjectTemplate
  POT = PortableObjectTemplate
  
  KEY_CONV = proc {|x| Symbol === x ? x.to_s : x}
  
  FIELD_NAMES = ["zero", "one", "two", "three", "four", "five", "six"]

  def mkhash ary
    Hash[ FIELD_NAMES[0...ary.size].zip(ary) ]
  end

  def pot_for(pot)
    POT.new(pot, KEY_CONV).optimize!
  end

  def rot_for(rot)
    ROT.new(rot, KEY_CONV).optimize!
  end

  def eq3 literal, rot, pot
    assert_threequal(rot_for(rot), literal)
    assert_threequal(pot_for(pot), literal)

    if literal.kind_of? Array
      hlit = mkhash(literal)
      hrot = mkhash(rot)
      hpot = mkhash(pot)
      eq3 hlit, hrot, hpot
    end
  end

  def ne3 literal, rot, pot
    assert_not_threequal(rot_for(rot), literal)
    assert_not_threequal(pot_for(pot), literal)

    if literal.kind_of? Array
      hlit = mkhash(literal)
      hrot = mkhash(rot)
      hpot = mkhash(pot)
      ne3 hlit, hrot, hpot
    end
  end
end
