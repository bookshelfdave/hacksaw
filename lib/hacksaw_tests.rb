require 'test/unit'
include Java

#class MyMathTest < Test::Unit::TestCase
#  def test_simple
#    assert_equal 0, 0
#  end
#end


class RegexComparator    
  attr_accessor :reg
  def initialize(r)
    @reg = r
  end
  def match(v)
     (v.getName() =~ classes) != nil
  end  
end

class Filter 
    attr_accessor :filters
    @@filterMethods = 
    {
    :lower=>"toLowerCase()",       
    :upper=>"toUpperCase()"
    }           

    def initialize(filters)    
      super()
      @filters = filters
    end

    def exec(s)
      allresults = @filters.keys.map do |k|
        meth = @@filterMethods[k]
        filter = @filters[k]                        
        #jval = eval "s.#{meth}.to_s "
        jval = s.instance_eval "#{meth}.to_s"
        result = case filter
          when String then return jval == filter
          when Regexp then return (jval =~ filter) != nil
          when Array  then return filter.include?(jval)
          when Proc   then return filter.call(jval)
          else false
        end   
        result
      end
      allresults.all? {|x| x == true}
    end
  end
 
#mc1 = MethodCallMod.new(:lower=>/foo/)
#puts mc1.exec(java.lang.String.new("FOO"))

mx2 = MethodCallMod.new(
  :lower=> lambda { |x| x == "bar"},
  :length => lambda { |x| x == 3}
  )
#mx2 = MethodCallMod.new(:lower=> "foo")
if mx2.exec(java.lang.String.new("bar")) then
  puts "FOO!!!"
else
  puts "False"
end
