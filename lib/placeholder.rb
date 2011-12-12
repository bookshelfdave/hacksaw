class Instruction
  attr_accessor :inst
  attr_accessor :data
  attr_accessor :index
  
  def initialize(inst,data=0,index=0)
    @inst = inst
    @data = data
    @index = index
  end
  
end

def inst(data,bytes=0,index=0)
  Instruction.new(data,bytes,index)
end


#a = [inst(:nop), inst(:pop,0,1),inst(:pop)]
#a.map {|x| puts x.index}

a = Proc.new do |x,y,z|
  
end

