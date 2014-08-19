#!/usr/bin/ruby
# -*- coding: utf-8 -*-


class BaseAnalyzer
  def initialize output = $stdout
    @out = output
    @count = 0
  end
  
  def analyze inp
    @out.print "Analizing #{inp.name}... \n"
    @count = @count + 1
    true
  end
  
  def report 
    @out.print "Refinement  was finished in #{@count} steps.\n"
    true
  end
end



class TopasInput
  def initialize text, base_name = nil
    @text = text.dup
    @k1 = get_k1
    @base_name  = get_base_name base_name
    @name = get_name
    @restrains = get_restrains
  end

  attr_reader :k1, :name, :base_name, :restrains, :text
 
 
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



class TopasEngine
  
  Systems = [:windows, :wine, :dummy]
  
  @@topasdir = "/home/dmitrienka/.wine/drive_c/TOPAS4-2/" #Depends!
  @@system     = :dummy                                   #[:wine, : :windows, :dummy]

  
  def self.system=(system)
    if Systems.any?{|sys| sys = system}
      @@system = system
    else
      raise "Unknown system!"
    end
  end

  def self.topasdir=(topasdir)
    @@topasdir = topasdir
  end


  def initialize dir = Dir.getwd
    @base_dir = dir
    Dir.chdir @base_dir
    print "#{@base_dir}\n"
    print "#{Dir.getwd} \n"
    @enc = "UTF-8"
  end

  def tc input
    infile = "#{input.name}.inp"
    File.open(infile, mode:'w'){|f| f.write input.text}
    case @@system
    when :wine
      path = `winepath -w #{infile}`.gsub('\\', '\\\\\\').gsub("\n", "")
      command = "wine tc.exe #{path}"
      go_n_do command
    when :windows
      command = "tc.exe #{File.expand_path(infile)}"
      go_n_do command
    when :dummy
     outfile = "#{input.name}.out"
      p "Say hello to #{outfile} with k1 = #{input.k1}"
      File.open(outfile , mode:'w'){|f| f.write input.text}
    end
    TopasInput.new IO.read("#{input.name}.out", :encoding => @enc)
  end
  

  def  refine input, ps, ss,  analyzer = BaseAnalyzer.new
    k1s = get_k1s ps, ss
    name = input.base_name
    Dir.mkdir(name) unless Dir.exists? name
    @work_dir = File.expand_path(name)
    Dir.chdir @work_dir
    k1s.reduce(input) do |inp, k1|
      out = tc inp.set_k1(k1)
      analyzer.analyze(out) ? out : break
    end
    Dir.chdir @base_dir
    analyzer.report
  end

  private
  
  def go_n_do command
    Dir.chdir @@topasdir
    system(command)
    Dir.chdir @work_dir
  end

  def get_k1s points, stepsizes 
    stepsizes.inject([]){|result, stepsize| 
      a = result + points[0].step(points[1] ,-stepsize).to_a
      points.shift
      a}.uniq
  end
  
end
