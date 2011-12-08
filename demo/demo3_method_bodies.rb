include Java # not really needed
require 'lib\\hacksaw_core.rb'
include Hacksaw

# Java must be passed this parameter:
# -javaagent:Hacksaw.jar
# Or directly to JRuby as:
# -J-javaagent:Hacksaw.jar

#disable_hacksaw


#modify :classes=>/com.quadcs.hacksaw.demo.[FB][a-z]+/ do |c| 
#  c.add_field 'public String mynewfield = "Hello world";'    
#  
#  c.modify :method=>/getFoo/ do |m|        
#      m.modify_method_calls :classname=>"java.lang.String",:methodname=>"toUpperCase" do
#         "{ $_ = $0.toLowerCase(); }"
#    end  
#  end      
#end