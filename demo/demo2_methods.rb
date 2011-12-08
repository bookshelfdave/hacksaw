include Java # not really needed
require 'lib\\hacksaw_core.rb'
include Hacksaw

# Java must be passed this parameter:
# -javaagent:Hacksaw.jar
# Or directly to JRuby as:
# -J-javaagent:Hacksaw.jar

#disable_hacksaw

#modify :classes=>/com\.quadcs\.hacksaw\.tests\.*/ do |c|
#  c.modify :method=>"foo", :params=>["java.lang.String",/.*/] do |m|
#    m.add_line_before 'System.out.println("Hello World");'
#    m.add_line_after 'System.out.println("Goodbye world y");'
#  end
#end

modify :classes=>/com.quadcs.hacksaw.demo.DemoAccount/ do |c|
    c.add_field 'public int z = 0;'  

    c.modify :field=>"accountNumber" do |f|
      f.change_modifiers [:public]
    end
    
    c.modify :method=>"isValidAccount" do |m|  
      m.add_line_before 'if(accountNumber.equals("abcd")) { return true; }'          
    end      
    
    c.add_method 'public String somethingNew(int dx) { return accountNumber + "." + z + "." + dx; }'    
    #c.save_to(".")
end


# TO GET THIS TO RUN, YOU WILL NEED TO APPEND THIS AS AN ARG TO JAVA.EXE
# -javaagent:Hacksaw.jar


#HacksawMain.DEBUG=true

modify :classes=>/com.quadcs.hacksaw.demo.[FB][a-z]+/ do |c| 
  c.add_field 'public String mynewfield = "Hello world";'    
  c.modify :method=>/getFoo/ do |m|        
      m.modify_method_calls :classname=>"java.lang.String",:methodname=>"toUpperCase" do
         "{ $_ = $0.toLowerCase(); }"
    end  
  end      
end

bar = com.quadcs.hacksaw.demo.Bar.new()

puts "-->#{bar.getFoo()}"
puts "-->#{bar.getFoobar()}"


#a = com.quadcs.hacksaw.demo.DemoAccount.new("abcd")
#puts a.z
#puts a.somethingNew(99)
#foo = com.quadcs.hacksaw.demo.Foo.new()
#bar = com.quadcs.hacksaw.demo.Bar.new()
#puts foo.mynewfield
#puts bar.mynewfield

#puts "-->#{bar.getFoo()}"
#puts "-->#{bar.getFoobar()}"
#puts a.getAccountNumber()
#puts a.accountNumber
#a.accountNumber = "123"
#puts a.accountNumber
