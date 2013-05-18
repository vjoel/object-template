require 'set'

class ObjectTemplate
  class MemberMatchingSet < Set
    def === other
      member? other
    end
  end

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
  end

  # Reorders the list of matchers so that easy ones come first.
  # For example: nil, then single values (==), then patterns (===).
  def optimize!
    @matchers.sort_by! do |k, v|
      case v
      when nil;     0
      when Range;   2
      when Module;  3
      when Regexp;  4
      when MemberMatchingSet;
        if v.size < 10
          3
        elsif v.size < 100
          4
        else
          5
        end
      when Proc;    5
      else          1 # must be a value
      end
    end
    self
  end

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

# Template specified by array or hash of ruby objects. The #== and #===
# methods of entry values are used in matching. Entry values may include
# classes, regexes, ranges, and so on, in addition to single values.
class RubyObjectTemplate < ObjectTemplate
  def fill_matchers k, v
    @matchers << [k, v]
  end
end

# Template specified by array or hash in a portable format composed of
# strings, numbers, booleans, arrays, and hashes. Special entry values
# correspond to wildcards and matchers of several kinds. See the unit
# tests for examples.
class PortableObjectTemplate < ObjectTemplate
  def fill_matchers k, v
    case v
    when nil
      @matchers << [k, nil]
        # This must be there to ensure the key exists in the hash case.
    when Hash
      v.each do |kk, vv|
        case kk
        when :value, "value"
          @matchers << [k, vv]
        when :set, "set"
          @matchers << [k, MemberMatchingSet.new(vv)]
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

  CLASS_FOR.default_proc = proc do |h,k|
    raise ArgumentError, "no known class for matching type #{k.inspect}"
  end
end
