require 'test/unit'
include Java # not really needed
require 'lib\\hacksaw_core.rb'
include Hacksaw



class HacksawTestCase < Test::Unit::TestCase
  attr_accessor :hacksaw_enabled
  def initialize(hacksaw_enabled) 
    @hacksaw_enabled = hacksaw_enabled
  end
  
  def toggled_assert(a,b,msg)
    if @hacksaw_enabled then
      assert_equal(a,b,msg)
    else
      assert_not_equal(a,b,msg)
    end
  end
end

class TestFields < HacksawTestCase
  
end


# Java must be passed this parameter:
# -javaagent:Hacksaw.jar
# Or directly to JRuby as:
# -J-javaagent:Hacksaw.jar

#disable_hacksaw

modify :classes=>/com.quadcs.hacksaw.demo.DemoAccount/ do |c|
    c.add_field 'public boolean active = false;'  
    c.modify :field=>"accountNumber" do |f|
      f.change_modifiers [:public]
    end
end


account = com.quadcs.hacksaw.demo.DemoAccount.new("abcd")
puts "Valid account? #{account.isValidAccount()}"
puts "Is the account active? #{account.active}"
account.active = true
puts "Is the account active? #{account.active}"


