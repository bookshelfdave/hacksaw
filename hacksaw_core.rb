include Java
require 'Hacksaw.jar'
include_class Java::com.quadcs.hacksaw.HacksawMain
include_class Java::com.quadcs.hacksaw.MethodAction
include_class Java::com.quadcs.hacksaw.FieldAction
include_class Java::com.quadcs.hacksaw.ClassMatcher
include_class Java::com.quadcs.hacksaw.ClassModification


module Hacksaw
  

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
                  :Transient=>128, # is 128 correct for transient AND vararge
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


modify_class "com.quadcs.hacksaw.tests.Foo" do |c| 
  add_before    :method=>:foo,   :of=>c, :line=>%{System.out.println("Hi");}  
  add_after     :method=>"foo",  :of=>c, :line=>%{System.out.println("Goodbye");}
  modify_field  :field=>"x",     :of=>c, :modifiers=>[:Public]
end

#HacksawMain.DEBUG=true
test = com.quadcs.hacksaw.tests.Foo.new()
test.x="Post"