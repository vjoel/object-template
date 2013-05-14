class ObjectTemplate
  # The key_converter is for matching objects that, for example, have had symbol
  # keys serialized to strings. Using a converter that round-trips through the
  # same serialializer, symbols in keys will match strings. However, symbols in
  # values will not.
  def initialize spec, key_converter = nil
    unless spec.respond_to? :size and spec.respond_to? :each
      raise ArgumentError, "cannot be used as a template: #{spec.inspect}"
    end

    @spec = spec
    @size = spec.size
    @matchers = []
    
    if spec.respond_to? :to_hash # assume hash-like
      @shibboleth = :to_hash
      spec.each do |k, v|
        kc = key_converter ? key_converter[k]: k
          # Note: cannot use key_converter[v] because v may have class, regex,
          # or other non-serializable object.
        fill_matchers kc, v
      end

    else # assume array-like
      @shibboleth = :to_ary
      spec.each_with_index do |v, i|
        fill_matchers i, v unless v.nil?
      end
    end

    ## optimization: reorder @matchers so that easy ones come first
    ##   for example: nil, then single values (==), then patterns (===)
  end

  def fill_matchers k, v
    case v
    when nil
      @matchers << [k, nil]
        # This must be there to ensure the key exists
    when Hash
      v.each do |kk, vv|
        case kk
        when :value, "value"
          @matchers << [k, vv]
        when :set, "set"
          @matchers << [k, vv.method(:member?).to_proc]
        when :type, "type"
          @matchers << [k, CLASS_FOR[vv]]
        when :range, "range"
          @matchers << [k, Range.new(*vv)]
        when :regex, "regex"
          @matchers << [k, Regexp.new(vv)]
        else
          raise ArgumentError,
            "unrecognized match specifier: #{kk.inspect}"
        end
      end
    else
      raise ArgumentError,
        "expected nil or Hash in template, found #{v.inspect}"
    end
  end
  
  CLASS_FOR = {
    "number" => Numeric,
    "string" => String,
    "list"   => Array,
    "map"    => Hash
  }
  
  def === obj # adapted from rinda/rinda.rb
    return false unless obj.respond_to?(@shibboleth)
    return false unless @size == obj.size
    @matchers.each do |k, v|
      begin
        it = obj.fetch(k)
      rescue
        return false
      end
      next if v.nil?
      next if v == it
      next if v === it
      return false
    end
    return true
  end

  def inspect
    "<#{self.class}: #{@spec}>"
  end
end