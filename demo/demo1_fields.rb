include Java 
require 'lib/hacksaw_core.rb'
include Hacksaw

# Java must be passed this parameter:
# -javaagent:Hacksaw.jar
# Or directly to JRuby as:
# -J-javaagent:Hacksaw.jar

#disable_hacksaw
#show_matches_enable

modify :classes=>/.*\.DemoAccount/ do |c|
    c.add_field 'public boolean active = false;'
    c.modify :field=>"accountNumber" do |f|
      f.change_modifiers [:public]
    end
end


account = com.quadcs.hacksaw.demo.DemoAccount.new("abcd")
puts "Valid account? #{account.isValidAccount()}"
account.accountNumber = "1234"
puts "Valid account? #{account.isValidAccount()}"

puts "Is the account active? #{account.active}"
account.active = true
puts "Is the account active? #{account.active}"


