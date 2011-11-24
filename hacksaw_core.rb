include Java
require 'Hacksaw.jar'
include_class Java::com.quadcs.hacksaw.Main
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

  #  public static final int	ABSTRACT	1024
#  public static final int	ANNOTATION	8192
#  public static final int	ENUM	16384
#  public static final int	FINAL	16
#  public static final int	INTERFACE	512
#  public static final int	NATIVE	256
#  public static final int	PRIVATE	2
#  public static final int	PROTECTED	4
#  public static final int	PUBLIC	1
#  public static final int	STATIC	8
#  public static final int	STRICT	2048
#  public static final int	SYNCHRONIZED	32
#  public static final int	TRANSIENT	128
#  public static final int	VARARGS	128
#  public static final int	VOLATILE	64

  
  class ChangeFieldModifiers < FieldAction
    attr_accessor :mods
    def initialize(fieldname,*mods)
      super(fieldname)
      
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
end

include Hacksaw
modify_class "com.quadcs.hacksaw.tests.Foo" do |c| 
  add_before :method=>:foo,   :of=>c, :line=>%{System.out.println("Hi");}  
  add_after  :method=>"foo",  :of=>c, :line=>%{System.out.println("Goodbye");}
end

#HacksawMain.DEBUG=true
test = com.quadcs.hacksaw.tests.Foo.new()
puts test.foo()