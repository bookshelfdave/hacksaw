include Java
require '../Hacksaw.jar'
include_class Java::com.quadcs.hacksaw.HacksawMain
include_class Java::com.quadcs.hacksaw.MethodAction
include_class Java::com.quadcs.hacksaw.FieldAction
include_class Java::com.quadcs.hacksaw.ClassModification
include_class Java::com.quadcs.hacksaw.FieldModification
include_class Java::com.quadcs.hacksaw.MethodModification
include_class Java::com.quadcs.hacksaw.ClassMatcher
include_class Java::com.quadcs.hacksaw.MethodMatcher
include_class Java::com.quadcs.hacksaw.FieldMatcher
include_class Java::javassist.ClassPool
include_class Java::javassist.CtClass
include_class Java::javassist.bytecode.Descriptor



module Hacksaw  
 
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
        super()
        @mods = mods
      end
    
      def exec(fm)
        ord = @mods.map {|m| @@modvals[m]}.reduce(:|)
        puts "Changing modifiers to #{ord}"
        fm.setModifiers(ord)
      end
    end

  
  
  
  class MethodMod < MethodModification
    def initialize(matcher)
      super(matcher)
    end
    def add_line_after(line)
      a = AddLineAfterMethod.new(line)
      getMethodActions().add(a)
    end

    def add_line_before(line)  
      a = AddLineBeforeMethod.new(line)
      getMethodActions().add(a)
    end
  end
  
  
  
  class FieldMod < FieldModification
    def initialize(matcher)
      super(matcher)
    end
    
    def change_modifiers(params)
      getFieldActions().add(ChangeFieldModifiers.new(params))
    end
  end
    
  class ClassMod < ClassModification
    def initialize(matcher)
      super(matcher)
    end
  
    def modify(params,&blk)
      if params.include? :method or params.include? :methods then
        modify_methods(params,&blk)
      elsif params.include? :field or params.include? :fields then
        modify_fields(params,&blk)
      elsif params.include? :constructor or params.include? :constructors then
        puts "Mod ctor"
      end  
    end
    
    
    

  def modify_methods(params)
      if params.include? :method then
        methods = params[:method]
      elsif params.include? :methods then
        methods = params[:methods]
      else
        raise "No methods(s) specified to modify"
      end
    
      matcher = case methods
      when String then RubyMethodMatcher.new { |m| m.getName() == methods}
      when Regexp then RubyMethodMatcher.new { |m| (m.getName() =~ methods) != nil }
      when Array  then RubyMethodMatcher.new { |m| methods.include?(m.getName()) }
      else RubyMethodMatcher.new { |m| false }  
      end
      m = MethodMod.new(matcher)
      
      yield(m) if block_given?
      getMethodModifications().add(m)
    end
 
  
#    def modify_fields(params)
#      if params.include? :field then
#        fields = params[:field]
#      elsif params.include? :fields then
#        fields = params[:fields]
#      else
#        raise "No field(s) specified to modify"
#      end
#    
#      matcher = case fields
#      when String then GenMatcher.new { |name,f| name == fields}
#      when Regexp then GenMatcher.new { |name,f| (name =~ fields) != nil }
#      when Array  then GenMatcher.new { |name,f| fields.include?(name) }
#      else RubyFieldMatcher.new { |name| false }  
#      end
#      f = FieldMod.new(matcher)
#      
#      yield(f) if block_given?
#      getFieldModifications().add(f)
#    end 
  end
  
  
  class RubyClassMatcher
    include ClassMatcher
    attr_accessor :blk
    def initialize(&blk)
      @blk = blk
    end
    def match(c)
      @blk.call(c)
    end
  end
  
  class RubyMethodMatcher
    include MethodMatcher
    attr_accessor :blk
    def initialize(&blk)
      @blk = blk
    end

    def match(m)
      @blk.call(m)
    end
  end

    
  class RubyFieldMatcher
    include FieldMatcher
    attr_accessor :blk
    def initialize(&blk)
      @blk = blk
    end

    def match(f)
      @blk.call(f)
    end
  end
   
    
 
  class AddLineAfterMethod < MethodAction
    attr_accessor :line
    def initialize(line) 
      super()
      @line = line
    end
    
    def exec(m)
      begin
        m.insertAfter(line)
      rescue
        puts "Busted!"
      end
    end
  end

  class AddLineBeforeMethod < MethodAction
    attr_accessor :line
    def initialize(line) 
      super()
      @line = line
    end
    
    def exec(m)
      begin
        m.insertBefore(line)
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
    when String then RubyClassMatcher.new { |c| c.getName() == classes}
    when Regexp then RubyClassMatcher.new { |c| (c.getName() =~ classes) != nil }
    when Array  then RubyClassMatcher.new { |c| classes.include?(c.getName()) }
    else RubyClassMatcher.new { |name| false }  
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
#  c.modify :field=>"Foo", :type=>/java\.lang\.*/ do |f|
#    f.change_modifiers [:public]
#  end  
#  
#  c.modify :constructor=>/.*/ do |ctor|
#    ctor.add_line_before 'System.out.println("Hello from a constructor");'
#  end



modify :classes=>/com\.quadcs\.hacksaw\.tests\.*/ do |c|
    c.modify :method=>"foo", :params=>["java.lang.String",/.*/] do |m|
      m.add_line_before 'System.out.println("Hello world x");'
      m.add_line_after 'System.out.println("Goodbye world y");'
    end
end



#HacksawMain.DEBUG=true
t = com.quadcs.hacksaw.tests.Foo.new()
puts t.foo()
#test.x="Post"

