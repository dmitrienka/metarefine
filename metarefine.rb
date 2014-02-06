#!/usr/bin/ruby
# -*- coding: utf-8 -*-

class Toparun
  TOPASDIR = "/home/dmitrienka/.wine/drive_c/TOPAS4-2/" #Change for your system one!
  WINE     = true                                       #Set false on windows!

  def initialize (start_file, k1s,  steps)
    raise 'Non-existing file!' until File.exist? start_file
    raise 'Check k1s and steps!' until k1s.size == steps.size + 1
    @k1s = k1s
    @steps = steps
    @start_file= start_file
    @base_name = start_file.sub(/\..{2,3}$/ , '' )
    @start_dir = Dir.getwd
    prepare
  end

  private

  def prepare
    Dir.mkdir @base_name unless Dir.exists? @base_name
    @base_dir = File.expand_path(@base_name)
    k1 = @k1s[0]
    lines = File.readlines(@start_file)
    lines.map!{|line| line.gsub /(.*)['].*/, $1 }
    lines.reject!{|line|
      (line =~ /penalties_weighting_K1/ ) || (line =~ /Out_CIF_STR/) }
    lines = lines.insert(lines.find_index{|i| i =~ /^\s*str\s*$/} + 1 , 
                         "penalties_weighting_K1 #{k1}", 
                         'Out_CIF_STR("' + "#{@base_name}#{k1}.cif" + '")')
    Dir.chdir(@base_dir)
    File.open("#{@base_name}#{k1}.inp", "w+"){|f| f.puts lines}
    self
  end

  def winetc (file) # Шаманская функция вызова wine tc.exe
    winefile = `winepath -w #{file}`.gsub('\\', '\\\\\\').gsub("\n", "")
    Dir.chdir TOPASDIR
    system("wine tc.exe #{winefile}")
    Dir.chdir @base_dir
  end    

  def tc (file)
    path = File.expand_path(file)
    Dir.chdir TOPASDIR
    system("tc.exe #{path}")
    Dir.chdir @base_dir
  end

  def dummytc (file)
    sleep rand 6
    new = "#{@base_name}#{@k1}.out"
    system("cp #{file} #{new}")
  end

  def gen_next (file)
    lines = File.readlines(file)
    @k1 = @k1 - @step    
    lines.map!{|line|
      case line
      when /penalties_weighting_K1/
        "penalties_weighting_K1 #{@k1}"
      when /Out_CIF_STR/
        'Out_CIF_STR("' + "#{@base_name}#{@k1}.cif" + '")'
      else line
      end}
     File.open("#{@base_name}#{@k1}.inp" , "w+"){|f| f.puts lines}
  end

  def run (k1_start, k1_stop, step)
    @k1 = k1_start
    @k1_stop = k1_stop
    @step = step
    until @k1 < @k1_stop do
       if WINE 
         winetc "#{@base_name}#{@k1}.inp" 
       else 
         tc "#{@base_name}#{@k1}.inp"
       end
       gen_next "#{@base_name}#{@k1}.out"
    end
  end
  
 public

  def  refine 
    @steps.each_with_index{|step, i|
    run(@k1s[i], @k1s[i+1], step)}
  end
    
end

require 'optparse'

options = {points:[100.0,15.0,0.0], steps:[1.0,0.25]}
OptionParser.new do |opts|
  opts.banner = "Usage: metarefine.rb  [-k 100,15,0 -s 1,0.25] filename.inp"
  opts.on("-p", "--points LIST", Array ,"Array of points, representing intervals with different stepsizes"){|list|
    options[:points] = list.map(&:to_f)}
  opts.on("-s", "--steps LIST", Array ,"Well, stepsizes for that intervals"){|list|
    options[:steps] = list.map(&:to_f)}
end.parse!

ARGV[0] || raise("Rrrr! Where is my input file??")
Toparun.new( ARGV[0], options[:points], options[:steps]).refine
