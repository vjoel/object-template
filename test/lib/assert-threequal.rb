module AssertThreequal
  def assert_threequal o1, o2, msg = nil
    msg = message(msg) { "Expected #{mu_pp(o1)} to be === #{mu_pp(o2)}" }
    assert o1.__send__(:===, o2), msg
  end
  
  def assert_not_threequal o1, o2, msg = nil
    msg = message(msg) { "Expected #{mu_pp(o1)} to be !== #{mu_pp(o2)}" }
    assert !(o1.__send__(:===, o2)), msg
  end
end
