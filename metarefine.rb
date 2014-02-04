#!/usr/bin/ruby
# -*- coding: utf-8 -*-
class Refine
  TopasDir = "/home/dmitrienka/.wine/drive_c/TOPAS4-2/"
  

  def initialize (start_file, k1_start = 100, k1_stop = 95, step = 1)
    @k1_curr = k1_start
    @k1_stop = k1_stop
    @step = step
    @out_curr = @inp_curr = start_file
    @base_name = start_file.sub(/\..{2,3}$/ , '' )
    @start_dir = Dir.getwd
    Dir.mkdir @base_name unless Dir.exists? @base_name 
    FileUtils.cp start_file, @base_name
  end
  def gen_next # Не понимает кавычку перед к1 и сиф!!!!
    lines = File.readlines(@out_curr)
    lines = lines.reject{|line|
      (line =~ /penalties_weighting_K1/ ) || (line =~ /Out_CIF_STR/) } +
      ["penalties_weighting_K1 #{@k1_curr}", 'Out_CIF_STR("' + "#{@base_name}#{@k1_curr}.cif" + '")']
    File.open("#{@base_name}#{@k1_curr}.inp", "w+"){|f| f.puts lines}
    @inp_curr = "#{@base_name}#{@k1_curr}.inp"
    @out_curr = "#{@base_name}#{@k1_curr}.out"    
    @k1_curr = @k1_curr - @step
    

  end


  def run 
    begin
      until @k1_curr < @k1_stop do
          Dir.chdir @base_name
          gen_next
          command = "wine tc.exe " +  `winepath -w #{@inp_curr}`.gsub('\\', '\\\\\\').gsub("\n", "")
          p command       
          Dir.chdir Refine::TopasDir
          p Dir.getwd
          system(command)
          Dir.chdir @start_dir
        end
      rescue  
        p "Something is wrong!"
        Dir.chdir @start_dir
    end
    end
   
end
    
a = Refine.new("sucrose-new.INP")
a.run
