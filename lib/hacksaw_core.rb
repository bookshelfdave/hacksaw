#/* ***** BEGIN LICENSE BLOCK *****
# * Version: MPL 1.1
# * Copyright (C) 2011- Dave Parfitt. All Rights Reserved.
# *
# * The contents of this file are subject to the Mozilla Public License Version
# * 1.1 (the "License"); you may not use this file except in compliance with
# * the License. You may obtain a copy of the License at
# * http://www.mozilla.org/MPL/
# *
# * Software distributed under the License is distributed on an "AS IS" basis,
# * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# * for the specific language governing rights and limitations under the
# * License.
# *
# * ***** END LICENSE BLOCK ***** */

# Hey - this is a prototype. You will notice a lack of unit tests!

# TODO: Method action is an interface... need to clean up FieldAction, CtorAction etc.

include Java
require 'Hacksaw.jar'
include_class Java::com.quadcs.hacksaw.HacksawMain
include_class Java::com.quadcs.hacksaw.ClassAction
include_class Java::com.quadcs.hacksaw.MethodAction
include_class Java::com.quadcs.hacksaw.FieldAction
include_class Java::com.quadcs.hacksaw.ClassModification
include_class Java::com.quadcs.hacksaw.FieldModification
include_class Java::com.quadcs.hacksaw.MethodModification
include_class Java::com.quadcs.hacksaw.ClassMatcher
include_class Java::com.quadcs.hacksaw.MethodMatcher
include_class Java::com.quadcs.hacksaw.FieldMatcher
include_class Java::com.quadcs.hacksaw.FlatExprEditor

include_class Java::javassist.ClassPool
include_class Java::javassist.CtClass
include_class Java::javassist.CtMethod
include_class Java::javassist.CtField
include_class Java::javassist.CtNewMethod
include_class Java::javassist.bytecode.Descriptor

include_class Java::javassist.bytecode.Mnemonic
include_class Java::javassist.bytecode.CodeAttribute
include_class Java::javassist.bytecode.CodeIterator


module Hacksaw    
  
  def enable_hacksaw
    com.quadcs.hacksaw.HacksawMain.enabled = true
  end

  def disable_hacksaw
    com.quadcs.hacksaw.HacksawMain.enabled = false
  end
  
  def hacksaw_enabled?
    com.quadcs.hacksaw.HacksawMain.enabled
  end

  def show_matches_enable
    com.quadcs.hacksaw.HacksawMain.showMatches = true
  end

  def show_matches_disabled
    com.quadcs.hacksaw.HacksawMain.showMatches = false
  end
  
  def show_matches_enabled?
    com.quadcs.hacksaw.HacksawMain.showMatches
  end

  
  module Filter 
    def filtermethods(k)      
    end
    
    def validFilter?(s)      
      allresults = @filters.keys.map do |k|              
        meth = filtermethods(k)
        filter = filters[k]                        
        #jval = eval "s.#{meth}.to_s "
        if s.nil? then                     
            return false
        end
        expr = "#{meth}.to_s"        
        jval = s.instance_eval expr
        
        result = case filter
          when String then jval == filter
          when Regexp then (jval =~ filter) != nil
          when Array  then filter.include?(jval)
          when Proc   then filter.call(jval)
          else false
        end   
        result
      end
      allresults.all? {|x| x == true}
    end
  end

  
   class MethodCallMod  < FlatExprEditor
     include MethodAction    
     include Filter
         
     attr_accessor :filters
     attr_accessor :blk
     def initialize(filters,&blk)
       super()       
       @filters =filters
       @blk = blk
     end

     ## I'm sure this is bad code!
     ## is there a better way to do this?
    def filtermethods(k)      
      {
      :classname=>"getClassName()",       
      :filename=>"getFileName()", 
      :linenumber=>"getLineNumber()",
      :methodname=>"getMethodName()", 
      :signature=>"getSignature()", 
      :issuper=>"isSuper()", 
      :maythrow=>"mayThrow()"}[k]
    end 
   
     def edit_methodcall(mc)              
       if validFilter?(mc) then         
         code = @blk.call()
         #mc.replace("{ $_ = $0.toLowerCase(); }")
         mc.replace(code)
       end
     end

    def exec(m)      
      m.instrument(self) 
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

    def show_bytecode()  
      a = ListBytecode.new()
      getMethodActions().add(a)
    end 

    def map_bytecode(&block)  
      a = MapBytecode.new(&block)
      getMethodActions().add(a)
    end 
    
    
    def modify_method_calls(params,&blk)
      m = MethodCallMod.new(params,&blk)
      getMethodActions().add(m)
    end
    
    def change_body(params)
      cmb = ChangeMethodBody.new(params)
      getMethodActions().add(cmb)
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
        puts "Not implemented bro!"
      end  
    end

    def save_to(path)
      s = SaveClass.new(path)
      addClassAction(s)
    end
    
    def add_method(body)
      s = AddMethodToClass.new(body)
      addClassAction(s)
    end

    def add_field(fielddef)
      f = AddFieldToClass.new(fielddef)
      addClassAction(f)
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
      addMethodModification(m)
    end

    def modify_fields(params)
      if params.include? :field then
        fields = params[:field]
      elsif params.include? :fields then
        fields = params[:fields]
      else
        raise "No fields(s) specified to modify"
      end
    
      matcher = case fields
        when String then RubyFieldMatcher.new { |f| f.getName() == fields}
        when Regexp then RubyFieldMatcher.new { |f| (f.getName() =~ fields) != nil }
        when Array  then RubyFieldMatcher.new { |f| fields.include?(f.getName()) }
        else RubyFieldMatcher.new { |f| false }  
      end
      f = FieldMod.new(matcher)
      
      yield(f) if block_given?
      addFieldModification(f)
    end

    
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

  class SaveClass < ClassAction
    attr_accessor :path
    def initialize(path)
      super()
      @path = path
    end
    
    def exec(c)
      puts "Saving class #{c.getName()} to #{@path}"
      puts "TODO: This is writing to the lib directory!"
      c.debugWriteFile(@path)
    end
  end

  class AddMethodToClass < ClassAction
    attr_accessor :methoddef
    def initialize(methoddef)
      super()
      @methoddef = methoddef
    end
    
    def exec(c)            
      m = CtNewMethod.make(@methoddef,c)
      c.addMethod(m)
    end
  end

  class AddFieldToClass < ClassAction
    attr_accessor :fielddef
    def initialize(fielddef)
      super()
      @fielddef = fielddef
    end
    
    def exec(c)            
      f = CtField.make(@fielddef,c)
      c.addField(f)
    end
  end
    
  class ChangeFieldModifiers < FieldAction
    attr_accessor :mods
    @@modvals = { 
      :abstract=>1024, 
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
      #puts "Changing modifiers to #{ord}"
      fm.setModifiers(ord)
    end
  end
            
  class AddLineAfterMethod 
    include MethodAction
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

  
  class ListBytecode
    include MethodAction

    def initialize
      super()
    end
    
    def exec(m)
      #cf = m.getDeclaringClass().getClassFile()
      ca = m.getMethodInfo().getCodeAttribute()
      ci = ca.iterator()
      while ci.hasNext()
          index = ci.next()
          ca = ci.get()          
          op = ci.byteAt(index)
          puts "#{Mnemonic.OPCODE[op]}"
                              
      end
    end
  end

  class MapBytecode
    include MethodAction
    attr_accessor :blk
    def initialize(&block)
      super()
      @blk = block
    end
    
    def exec(m)
      ca = m.getMethodInfo().getCodeAttribute()
      ci = ca.iterator()
      while ci.hasNext()
          index = ci.next()
          ca = ci.get()          
          op = ci.byteAt(index)
          #puts "Length: #{ci.codeLength()}"
          atts = ci.get().getAttributes()
          
          atthash = atts.map { |a| {:attname=>a.getName(),:data=>a.get().to_s } }
          
          val = @blk.call(op, Mnemonic.OPCODE[op],atthash)         
          #puts "-->#{val.class.name}"
          ci.writeByte(val,index)          
      end
    end
  end

  
  class AddLineBeforeMethod 
    include MethodAction
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
