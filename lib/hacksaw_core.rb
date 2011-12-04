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
  
  class MethodMod 
    
  end
  
  class FieldMod < FieldModification
    def initialize(matcher)
      super(matcher)
    end
    
    def change_modifiers(params)
      getFieldActions().add(ChangeFieldModifiers.new(params))
    end
  end
    
  class ChangeFieldModifiers < FieldAction
    attr_accessor :mods
    @@modvals = { :abstract=>1024, 
      :annotation=>8192, 
      :enum=>16384,
      :final=>16,
      :interface=>512,
      :native=>256,
      :private=>2,
      :protected=>4,
      :public=>1,
      :static=>8,
      :strict=>2048,
      :synchronized=>32,
      :transient=>128, # is 128 correct for transient AND varargs?
      :varargs=>128,
      :volatile=>64
    }
    
    def initialize(mods)
      @mods = mods
    end
    
    def exec(fm)
      ord = @mods.map {|m| @@modvals[m]}.reduce(:|)
      fm.setModifiers(ord)
    end
  end
  
  
  
  
  
  
  class ClassMod < ClassModification
    def initialize(matcher)
      super(matcher)
    end
  
    def modify(params,&blk)
      if params.include? :method or params.include? :methods then
        puts "Modifying methods!"
      elsif params.include? :field or params.include? :fields then
        modify_fields(params,&blk)
      elsif params.include? :constructor or params.include? :constructors then
        puts "Mod ctor"
      end  
    end
    
    
    
    def add_line_after(params)
      a = AddLineAfterMethod.new(params[:method].to_s,params[:line])
      getMethodActions().add(a)
    end

    def add_line_before(params)  
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
    
      matcher = case fields
      when String then RubyFieldMatcher.new { |name,f| name == fields}
      when Regexp then RubyFieldMatcher.new { |name,f| (name =~ fields) != nil }
      when Array  then RubyFieldMatcher.new { |name,f| fields.include?(name) }
      else RubyFieldMatcher.new { |name| false }  
      end
      f = FieldMod.new(matcher)
      yield(f) if block_given?
      getFieldModifications().add(f)
    end

  
  end
  
  
  class RubyClassMatcher
    include ClassMatcher
    attr_accessor :blk
    def initialize(&blk)
      @blk = blk
    end
    def matchClass(classname,c)
      @blk.call(classname,c)
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

  
  
  
  def modify_classes(params)
    if params.include? :class then
      classes = params[:class]
    elsif params.include? :classes then
      classes = params[:classes]
    else
      raise "No classes specified to modify"
    end

    matcher = case classes
    when String then RubyClassMatcher.new { |name,cx| name == classes}
    when Regexp then RubyClassMatcher.new { |name,cx| (name =~ classes) != nil }
    when Array  then RubyClassMatcher.new { |name,cx| classes.include?(name) }
    else ClassMatcher.new { |name| false }  
    end
    
    c = ClassMod.new(matcher)
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


#modify :classes=>/com\.quadcs\.hacksaw\.tests\.*/,extends=>/com\.quadcs\.hacksaw\.tests\.*/ do |c|
modify :classes=>/com\.quadcs\.hacksaw\.tests\.*/ do |c|
  c.modify :field=>"Foo", :type=>/java\.lang\.*/ do |f|
    f.change_modifiers [:Public]
  end  
  
#  c.modify :method=>/.*/, :params=>["java.lang.String",/.*/] do |m|
#    f.add_line_before 'System.out.println("Hello world");'
#    f.add_line_after 'System.out.println("Goodbye world");'
#  end
#  c.modify :constructor=>/.*/ do |ctor|
#    ctor.add_line_before 'System.out.println("Hello from a constructor");'
#  end
end


#HacksawMain.DEBUG=true
test = com.quadcs.hacksaw.tests.Foo.new()
#test.x="Post"

