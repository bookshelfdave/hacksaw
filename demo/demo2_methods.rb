include Java # not really needed
require 'lib/hacksaw_core.rb'
include Hacksaw

# Java must be passed this parameter:
# -javaagent:Hacksaw.jar
# Or directly to JRuby as:
# -J-javaagent:Hacksaw.jar

#disable_hacksaw
#show_matches_enable
modify :classes=>/com.quadcs.hacksaw.demo.DemoAccount/ do |c|
    c.add_field 'public int secret = 0;'  
    
    c.modify :field=>"accountNumber" do |f| 
      f.change_modifiers [:public] 
    end
    
    c.modify :method=>"isValidAccount" do |m|  
      m.add_line_before 'if(accountNumber.equals("abcd")) { return true; }'
    end      
    
    c.add_method '
      public String generateSwissAccountNumber(int salt) { 
        return accountNumber + "." + secret + "." + salt; 
      }'    
    c.save_to("hacksaw")
end

account = com.quadcs.hacksaw.demo.DemoAccount.new("abcd")
puts account.secret

puts "The Swiss bank account number is : #{account.generateSwissAccountNumber(123)}"
account.accountNumber = "DAVESACCT"
puts "The Swiss bank account number is : #{account.generateSwissAccountNumber(123)}"

#foo = com.quadcs.hacksaw.demo.Foo.new()
#bar = com.quadcs.hacksaw.demo.Bar.new()
#puts foo.mynewfield
#puts bar.mynewfield
