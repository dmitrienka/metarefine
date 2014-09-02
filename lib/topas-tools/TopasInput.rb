class TopasInput
  def initialize text, base_name = nil
    @text = text.dup
    @k1 = get_k1
    @base_name  = get_base_name base_name
    @name = get_name
    @restrains = get_restrains
    @r_wp = get_rwp
  end

  attr_reader :k1, :name, :base_name, :restrains, :text, :r_wp
 
 
  def set_k1!(num)
    @k1 = num.to_f
    @text = @text.sub(/(penalties_weighting_K1\s+)[\d.]+/ , "\\1#{@k1}").
          sub(/[\d.]*(\.cif)/ , "#{@k1}\\1")
    @name = get_name
    self
  end

  def set_k1(num)
    dup.set_k1!(num)
  end
  
  def restrain_names
    @restrains.map{|r| r[:name]}
  end

  def set_restrain!(name, new)
    if r = @restrains.select{|r| r[:name] == name}[0]
      r[:restrain] = new
      @text = write_restrains
      self
    else
      raise  "No restrain with the name #{name}"
    end
  end

  def set_restrain(name, new)
    dup.set_restrain!(name, new)
  end

  private
  


  def get_k1
    @text.scan(/penalties_weighting_K1\s+([\d.]+)/)[0][0].to_f
  end

  def get_rwp
    @text.scan(/r_wp\s+([\d.]+)/)[0][0].to_f
  end


  def get_base_name bn
    if   bn
      base_name = File.basename(bn, File.extname(bn))
      @text = @text.sub(/phase_name\s+".+"/, %Q[phase_name "#{bn}"])
      base_name
    else
      base_name = @text.match(/phase_name\s+"(.+)"/)[1]
      base_name
    end
  end




  def get_name
      "#{@base_name}_#{@k1}"
  end


  def get_restrains
    restrains_pattern = /(Distance_Restrain(?:_Breakable|_Morse)?)\(\s*(\w+\s+\w+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)[`_\d.]*\s*,\s*([\d.]+\s*,\s*[\d.]+)\s*\)/
    if @text =~ restrains_pattern
      @text.scan(restrains_pattern).reduce([]){|memo, (type ,name, restrain, value, rest)|
        memo << {name:name, type:type, restrain:restrain.to_f, value:value.to_f, rest:rest}
        memo}
    else
      nil
    end
  end

  def write_restrains
    @restrains.reduce(@text) { |memo, r|
      pattern = /#{r[:type]}\s*\(\s*#{r[:name]}\s*,\s*[\d.]+\s*,\s*[\d.]+[`_\d.]*\s*,\s*[\d.]+\s*,\s*[\d.]+\s*\)/ 
      memo.sub(pattern, "#{r[:type]}(#{r[:name]}, #{r[:restrain]}, #{r[:value]}, #{r[:rest]})")        
    }
  end

end


def dumbdiff as, bs
  as = as.split /\n/
  bs = bs.split /\n/
  as.zip(bs).reject{ |a, b| a == b}
end
