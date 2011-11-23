include Java
require 'Hacksaw.jar'
include_class Java::com.quadcs.hacksaw.Hacksaw
include_class Java::com.quadcs.hacksaw.MethodAction
include_class Java::com.quadcs.hacksaw.ClassMatcher
include_class Java::com.quadcs.hacksaw.ClassModification

module Hack
  
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
    Hacksaw.registerMod(c)
  end
end

include Hack
modify_class "com.quadcs.hacksaw.tests.Foo" do |c| 
  add_before :method=>:foo,   :of=>c, :line=>%{System.out.println("Hi");}  
  add_after  :method=>"foo",  :of=>c, :line=>%{System.out.println("Goodbye");}
end

#Hacksaw.DEBUG=true
test = com.quadcs.hacksaw.tests.Foo.new()
puts test.foo()