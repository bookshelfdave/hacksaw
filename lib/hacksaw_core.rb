include Java
require '../Hacksaw.jar'
include_class Java::com.quadcs.hacksaw.HacksawMain
include_class Java::com.quadcs.hacksaw.MethodAction
include_class Java::com.quadcs.hacksaw.FieldAction
include_class Java::com.quadcs.hacksaw.ClassMatcher
include_class Java::com.quadcs.hacksaw.MethodMatcher
include_class Java::com.quadcs.hacksaw.FieldMatcher
include_class Java::com.quadcs.hacksaw.ClassModification
include_class Java::com.quadcs.hacksaw.FieldModification


include_class Java::javassist.ClassPool
include_class Java::javassist.CtClass
include_class Java::javassist.bytecode.Descriptor


module Hacksaw
  
  class RubyClassMatcher
    include ClassMatcher
    attr_accessor :blk
    def initialize(&blk)
        @blk = blk
      end
      def matchClass(classname)
        @blk.call(classname)
      end
    end

  class RubyMethodMatcher
    include MethodMatcher
    attr_accessor :blk
    def initialize(&blk)
        @blk = blk
      end

      def matchMethod(methodname,m)
        @blk.call(methodname,m)
      end
    end

    
   class RubyFieldMatcher
    include FieldMatcher
    attr_accessor :blk
    def initialize(&blk)
        @blk = blk
      end

      def matchField(fieldname,f)
        @blk.call(fieldname,f)
      end
    end
   
    
  class ChangeFieldModifiers < FieldAction
    attr_accessor :mods
    @@modvals = { :Abstract=>1024, 
                  :Annotation=>8192, 
                  :Enum=>16384,
                  :Final=>16,
                  :Interface=>512,
                  :Native=>256,
                  :Private=>2,
                  :Protected=>4,
                  :Public=>1,
                  :Static=>8,
                  :Strict=>2048,
                  :Synchronized=>32,
                  :Transient=>128, # is 128 correct for transient AND varargs?
                  :Varargs=>128,
                  :Volatile=>64
                }
    
    def initialize(fieldname,mods)
      super(fieldname)
      @mods = mods
    end
    
    def exec(fm)
      ord = @mods.map {|m| @@modvals[m]}.reduce(:|)
      fm.setModifiers(ord)
    end
  end
  
  class AddLineAction < MethodAction
    attr_accessor :line
    
    def initialize(methodname, line, sig=nil) 
      super(methodname,sig)
      @line = line
    end
  end

  class AddLineAfterMethod < AddLineAction
    def initialize(methodname, line, sig=nil) 
      super(methodname,line,sig)
    end
    def exec(c)
      begin
        c.insertAfter(line)
      rescue
        puts "Busted!"
      end
    end
  end


  class AddLineBeforeMethod < AddLineAction
    def initialize(methodname, line, sig=nil) 
      super(methodname,line,sig)
    end

    def exec(c)
      begin
        c.insertBefore(line)
      rescue
        puts "Busted!"
      end
    end
  end

  class ClassMods < Array
    attr_accessor :classname
    def initialize(classname)
     @classname = classname
    end
  end

  def add_after(params)
    c = params[:of]
    a = AddLineAfterMethod.new(params[:method].to_s,params[:line])
    c.getMethodActions().add(a)
  end

  def add_before(params)  
    c = params[:of]
    a = AddLineBeforeMethod.new(params[:method].to_s,params[:line])
    c.getMethodActions().add(a)
  end
  
  
  
  def modify_fields(params)
    if params.include? :field then
      fields = params[:field]
    elsif params.include? :fields then
      fields = params[:fields]
    else
      raise "No field(s) specified to modify"
    end
    
    fm = params[:of]
    
    matcher = case fields
      when String then RubyFieldMatcher.new { |name,f| name == fields}
      when Regexp then RubyFieldMatcher.new { |name,f| (name =~ fields) != nil }
      when Array  then RubyFieldMatcher.new { |name,f| fields.include?(name) }
      else RubyFieldMatcher.new { |name| false }  
    end
    f = FieldModification.new(matcher)
    yield(f) if block_given?
    fm.getFieldModifications().add(f)
  end
  
  
  
  def modify_classes(params)
    if params.include? :class then
      classes = params[:class]
    elsif params.include? :classes then
      classes = params[:classes]
    else
      raise "No classes specified to modify"
    end

    matcher = case classes
      when String then RubyClassMatcher.new { |name| name == classes}
      when Regexp then RubyClassMatcher.new { |name| (name =~ classes) != nil }
      when Array  then RubyClassMatcher.new { |name| classes.include?(name) }
      else ClassMatcher.new { |name| false }  
    end
    
    c = ClassModification.new(matcher)
    yield(c) if block_given?
    HacksawMain.registerMod(c)
  end
  
  
#  def modify_field(params)
#    c = params[:of]
#    m = params[:modifiers]
#    field = params[:field]
#    cm = ChangeFieldModifiers.new(field.to_s,m)
#    c.getFieldActions().add(cm)
#  end
  
  
  def modify(params,&blk)
   if params.include? :class or params.include? :classes then
     modify_classes(params,&blk)
   elsif params.include? :method or params.include? :methods then
     puts "Modifying methods!"
   elsif params.include? :field or params.include? :fields then
    modify_fields(params,&blk)
   end 
  end
  

  
end

include Hacksaw


modify :classes=>/com\.quadcs\.hacksaw\.tests\.*/ do |c|
  modify :field=>"Foo", :of=>c do |f|
    
  end
  
#  modify :method=>"Foo", :of=>c, :add_line_before=>"System.out.println(1000);"
#  modify :field=>"x", :of=>c, :modifiers=>[:Public]  
#  modify :constructor, :of=>c, 
  puts "Modifying classes!"
end


#HacksawMain.DEBUG=true
test = com.quadcs.hacksaw.tests.Foo.new()


#test.x="Post"



#modify_class "com.quadcs.hacksaw.tests.Foo" do |c| 
#  add_before    :method=>:foo,   :of=>c, :line=>%{System.out.println("Hi");}  
#  add_after     :method=>"foo",  :of=>c, :line=>%{System.out.println("Goodbye");}
#  modify_field  :field=>"x",     :of=>c, :modifiers=>[:Public]
#end
#
#
#modify_class "com.quadcs.hacksaw.tests.Foo" do |c| 
#  modify_method "foo", :of=>c do |m|
#    add_before    :method=>:foo,   :of=>c, :line=>%{System.out.println("Hi");}  
#    add_after     :method=>"foo",  :of=>c, :line=>%{System.out.println("Goodbye");}
#  end
# 
#  modify_field "x", :of=>c do |f|
#  end
#  
#  modify_field  :field=>"x",     :of=>c, :modifiers=>[:Public]
#end
#
#
#
#modify_class "com.quadcs.hacksaw.tests.Foo" do |c| 
#  add_before_method :name=>"foo"
#  add_after_method :name=>/[a-zA-Z0-9_]/ 
#  
#  #modify_method
#  #modify_field "x", :of=>c, :modifiers=>[:Public]
#  #modify_constructor
#end  



#def test_regex(params)
#  obj = params[:name]  
#  case obj 
#    when String then puts "String"
#    when Regexp then 
#  end
#end

#t = testit(:name=>"foo") 
#t2 = testit(:name=>/[a-zA-Z0-9_]+/)
#t3 = testit(:name=>["com.foo.Baz","com.foo.bar"])
#puts t.matchClass("foo")
#puts t2.matchClass("com.foo.bar")
#puts t3.matchClass("com.foo.bar")

