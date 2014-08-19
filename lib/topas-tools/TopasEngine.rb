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
