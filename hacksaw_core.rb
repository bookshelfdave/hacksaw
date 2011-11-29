include Java
require 'Hacksaw.jar'
include_class Java::com.quadcs.hacksaw.HacksawMain
include_class Java::com.quadcs.hacksaw.MethodAction
include_class Java::com.quadcs.hacksaw.FieldAction
include_class Java::com.quadcs.hacksaw.ClassMatcher
include_class Java::com.quadcs.hacksaw.MethodMatcher
include_class Java::com.quadcs.hacksaw.ClassModification


include_class Java::javassist.ClassPool
include_class Java::javassist.CtClass
include_class Java::javassist.bytecode.Descriptor


module Hacksaw
    
  class SingleMethodNameMatcher
    include MethodMatcher
    attr_accessor :methodname
    def initialize(name)
      @methodname = name
    end
    def matchMethod(method, sig)
      # this WILL match all methods with the same name in a class
      method == @methodname
    end
  end
  
  class RegexMethodNameMatcher
    include MethodMatcher
    attr_accessor :regex
    def initialize(regex)
      @regex = regex
    end
    def matchMethod(method, sig)
        @regex.match(method) 
    end
  end

  class ListMethodNameMatcher
    include MethodMatcher
    attr_accessor :l
    def initialize(methodlist)
      @l = methodlist
    end
    def matchMethod(method, sig)
      @l.include? method
    end
  end

 
  
  
  class SingleClassMatcher
    include ClassMatcher
    attr_accessor :classname
    def initialize(classname)
      @classname=classname
    end
    def matchClass(classname)
      @classname == classname
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
  
  def modify_class(classname)
    cm = SingleClassMatcher.new(classname)
    c = ClassModification.new(cm)
    yield(c) if block_given?
    #c.getMethodActions().each do |m|
    #  puts "Running action #{m}"
    #end
    HacksawMain.registerMod(c)
  end
  
  def modify_field(params)
    c = params[:of]
    m = params[:modifiers]
    field = params[:field]
    cm = ChangeFieldModifiers.new(field.to_s,m)
    c.getFieldActions().add(cm)
  end
end

include Hacksaw


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


#modify :class=>"com.quadcs.hacksaw.tests.Foo" do |c|
#  modify :method=>"Foo", :of=>c, :add_line_before=>"System.out.println(1000);"
#  modify :field=>"x", :of=>c, :modifiers=>[:Public]  
#  modify :constructor, :of=>c, 
#end


#HacksawMain.DEBUG=true
test = com.quadcs.hacksaw.tests.Foo.new()
#test.x="Post"

def test_regex(params)
  obj = params[:name]  
  case obj 
    when String then puts "String"
    when Regexp then 
  end
end
