#!/usr/bin/ruby
# -*- coding: utf-8 -*-

class Toparun
  TOPASDIR = "/home/dmitrienka/.wine/drive_c/TOPAS4-2/" #Depends!
  WINE     = true                                       #Set false on windows!

  def initialize
    @start_dir = Dir.getwd
    # Add some tests
  end

  def  refine rfn,  analyzer = BaseAnalyzer.new
    name = rfn.name
    Dir.mkdir(name) unless Dir.exists? name
    @base_dir = File.expand_path(name)
    Dir.chdir @base_dir
    while (k1 = rfn.k1shift) do
      File.open("#{name}#{k1}.inp" , "w+"){|f| f.puts rfn.inp}
      tc "#{name}#{k1}.inp"
      out =  IO.read("#{name}#{k1}.out")
      analyzer.analyze(out) ? rfn.next_inp(out) : break
    end
    analyzer.report
  end

  private
  
  def tc (file)
    if WINE
    then
      path = `winepath -w #{file}`.gsub('\\', '\\\\\\').gsub("\n", "")
      command = "wine tc.exe #{path}"
    else
      command = "tc.exe #{File.expand_path(file)}"
    end
    Dir.chdir TOPASDIR
    system(command)
    Dir.chdir @base_dir
  end

  def dummytc (file)
    sleep rand 3
    new = file.sub(/\..{2,3}$/ , '.out')
    system("cp #{file} #{new}")
    p "Say hello to #{new} ! ^^"
  end

end

class Refinement
  def initialize file, name = inp_name(file),  ps, ss
    raise 'Check k1s and steps!' until ps.size == ss.size + 1
    @name = name
    @start_inp = file
    @k1s = parse ps, ss
    @inp = next_inp @start_inp
  end
  
  attr_reader :inp, :name
  
  def next_inp out # Сделать умнее!
    @inp = out.gsub(/(penalties_weighting_K1\s+)[\d.]+/ , "\\1#{@k1s[0]}").
               gsub(/[\d.]*(\.cif)/ , "#{@k1s[0]}\\1")
  end

  def k1shift
    @k1s.shift
  end
  
  private
  
  def parse points, stepsizes 
    stepsizes.inject([]){|result, stepsize| 
      a = result + points[0].step(points[1] ,-stepsize).to_a
      points.shift
      a}.uniq
  end
  
  def inp_name text
    (text =~ /phase_name\s+\"(.+)\"/) ? $1 : "toparun"
  end

end

class BaseAnalyzer
  def initialize
    @i = 0
  end
  
  def analyze text
    @i = @i + 1
    true
  end
  
  def report
    p "Refinement was finished in #{@i} steps."
    true
  end

end
