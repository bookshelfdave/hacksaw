include Java # not really needed
require 'lib\\hacksaw_core.rb'
include Hacksaw

# Java must be passed this parameter:
# -javaagent:Hacksaw.jar
# Or directly to JRuby as:
# -J-javaagent:Hacksaw.jar
#
#disable_hacksaw

modify :classes=>/com.quadcs.hacksaw.demo.DemoAccount/ do |c|
    c.modify :method=>"deposit" do |m|                      
        m.map_bytecode do |bytes,op,atts|         
          if op == "athrow" then
            0
          else
            bytes  
          end          
        end        
    end    
    #c.save_to("hacksaw")
end

account = com.quadcs.hacksaw.demo.DemoAccount.new("abcd")
puts account.getAccountNumber()
puts account.getBalance()
account.deposit(-100)
puts account.getBalance()
