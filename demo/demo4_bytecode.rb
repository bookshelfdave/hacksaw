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
    c.modify :method=>"deposit" do |m|                          
	# actual, this just shows the opcodes for now
        #m.show_bytecode 

        # this replaces ALL exceptions thrown with a NOP *and* a POP      
 	# this needs some work
 	
 	# need to come up with a decent syntax to represent Bytecode ops
 	# such as inserting code around the current instruction etc.
        m.map_bytecode do |bytes,op|         
          op == "athrow" ? 0 : bytes
	end
    end    
    #c.save_to("hacksaw")
end



account = com.quadcs.hacksaw.demo.DemoAccount.new("abcd")
puts "Account number = #{account.getAccountNumber()}"
puts "Balance = #{account.getBalance()}"
account.deposit(-100)
puts "Balance = #{account.getBalance()}"
  
