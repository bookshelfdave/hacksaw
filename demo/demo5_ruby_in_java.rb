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
      m.add_callback_before ["$1"] do |x|
        puts "This is a Ruby block in your Java method: #{x}"
      end
    end    
end

  

account = com.quadcs.hacksaw.demo.DemoAccount.new("1234")
puts account.getBetterAccountNumber("Mike Smith")
puts "Finished"