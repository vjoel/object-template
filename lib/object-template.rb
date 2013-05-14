class ObjectTemplate
  def initialize spec
    @spec = spec
    @size = spec.size
    @matchers = []
    @spec.each_with_index do |v, i|
      case v
      when nil # no matcher
      when Hash
        v.each do |kk,vv|
          case kk
          when :value, "value"
            @matchers << [i, vv]
          when :set, "set"
            @matchers << [i, vv.method(:member?).to_proc]
          when :type, "type"
            @matchers << [i, CLASS_FOR[vv]]
          when :range, "range"
            @matchers << [i, Range.new(*vv)]
          end
        end
      else
        raise ArgumentError, "unhandled: #{v.inspect}" ##?
      end
    end
  end
  
  CLASS_FOR = {
    "number" => Numeric
  }
  
  def === obj
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
