require 'set'

# Base class for classes of templates used to match somewhat arbitrary objects.
class ObjectTemplate
  VERSION = "0.6"

  attr_reader :spec

  # A set implementation that treats the matching operator (===) as membership.
  # Used internally by PortableObjectTemplate, but can also be used in
  # RubyObjectTemplate or in case statements.
  class MemberMatchingSet < Set
    alias === member?
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
  # Returns self.
  def optimize!
    @matchers.sort_by! do |k, v|
      case v
      when nil;               0
      when Range;             2
      when Module;            3
      when Regexp;            4
      when MemberMatchingSet; 4
      when Proc;              5
      else                    1 # assume it is a value
      end
    end
    self
  end

  # True if the template matches the given object.
  # Adapted from rinda/rinda.rb.
  def === obj
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
  def fill_matchers k, v  # :nodoc:
    @matchers << [k, v]
  end
end

# Template specified by array or hash in a portable format composed of
# strings, numbers, booleans, arrays, and hashes. Special entry values
# correspond to wildcards and matchers of several kinds. See the unit
# tests for examples.
#
# The objects matched include anything constructed out of numbers, booleans,
# including null, and strings using hashes and arrays. In other words,
# objects that can be serialized with json or msgpack.
#
class PortableObjectTemplate < ObjectTemplate
  def fill_matchers k, v  # :nodoc:
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
          @matchers << [k, CLASS_FOR[vv.to_s]]
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

  BOOLEAN = MemberMatchingSet.new([true, false])

  CLASS_FOR = {
    "boolean" => BOOLEAN,
    "number"  => Numeric,
    "integer" => Integer,
    "string"  => String,
    "list"    => Array,
    "map"     => Hash
  }

  CLASS_FOR.default_proc = proc do |h,k|
    raise ArgumentError, "no known class for matching type #{k.inspect}"
  end

  # Convert a ROT spec into a POT spec (without creating a ROT). Not completely
  # general: some POTs cannot be represented in this way.
  def self.spec_from rot_spec
    case rot_spec
    when Array
      rot_spec.map do |col_rot_spec|
        column_spec_from(col_rot_spec)
      end
    when Hash
      h = {}
      rot_spec.each do |k, col_rot_spec|
        h[k] = column_spec_from(col_rot_spec)
      end
      h
    else
      raise ArgumentError
    end
  end

  def self.column_spec_from col_rot_spec
    case col_rot_spec
    when nil
      nil

    when Range
      range = col_rot_spec
      raise if range.exclude_end? ##
      raise unless range.first.kind_of? Numeric ##
      {type: "number", range: [range.first, range.last]}

    when Module
      mdl = col_rot_spec
      class_name,_ = CLASS_FOR.find {|k,v| v == mdl}
      raise unless class_name
      {type: class_name}

    when Regexp
      rx = col_rot_spec
      {regex: rx.source}

    when Set
      set = col_rot_spec
      if set == BOOLEAN
        ## awkward API: must reference PortableObjectTemplate::BOOLEAN
        {type: "boolean"}
      else
        {set: set.to_a}
      end

    else # assume it is a value
      {value: col_rot_spec}
    end
  end
end
