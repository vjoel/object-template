class ObjectTemplate
  def initialize spec
    @spec = spec
    @size = spec.size
    @matchers = []
    
    if spec.respond_to? :to_hash # assume hash-like
      @shibboleth = :to_hash
      spec.each do |k, v|
        fill_matchers k, v
      end

    else # assume array-like
      @shibboleth = :to_ary
      spec.each_with_index do |v, i|
        fill_matchers i, v
      end
    end
  end

  def fill_matchers k, v
    case v
    when nil # no matcher
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
        end
      end
    else
      raise ArgumentError, "unhandled: #{v.inspect}" ##?
    end
  end
  
  CLASS_FOR = {
    "number" => Numeric,
    "string" => String,
    "list"   => Array,
    "map"    => Hash
  }
  
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
end
