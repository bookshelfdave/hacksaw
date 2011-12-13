include Java # not really needed
require 'lib/hacksaw_core.rb'
include Hacksaw

# Java must be passed this parameter:
# -javaagent:Hacksaw.jar
# Or directly to JRuby as:
# -J-javaagent:Hacksaw.jar
#
#disable_hacksaw
#show_matches_enable





modify :classes=>/com.quadcs.hacksaw.demo.DemoAccount/ do |c|
    c.modify :method=>"getBetterAccountNumber" do |m|                          
      # needs some more work
      # that 1 right there tells hacksaw that we are changing
      # parameter 1 via the return value of this block.
      m.add_ruby_before 1 do |prefix,suffix|
        puts "Ruby in your Java!!"
        puts "Prefix in Ruby=#{prefix}"
        puts "Suffix in Ruby=#{suffix}"
        "<<<Suffix"
      end
    end    
end

  



account = com.quadcs.hacksaw.demo.DemoAccount.new("1234")
puts account.getBetterAccountNumber(">>>","<<<")
