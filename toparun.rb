#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'optparse'
load 'ToparunClasses.rb'


options = {points:[100.0, 16.0, 0.0], steps:[4.0, 1.0]}
OptionParser.new do |opts|
  opts.banner = "Usage: toparun.rb  [-p 100,15,0 -s 1,0.25] filename.inp"
  opts.on("-p", "--points LIST", Array ,"Array of points, representing intervals with different stepsizes"){|list|
    options[:points] = list.map(&:to_f)}
  opts.on("-s", "--steps LIST", Array ,"Well, stepsizes for that intervals"){|list|
    options[:steps] = list.map(&:to_f)}
end.parse!

ARGV[0] || raise("Rrrr! Where is my input file??")

runner = Toparun.new
refinement = Refinement.new IO.read(ARGV[0]), ARGV[0].sub(/\..{2,3}$/, '') ,  options[:points], options[:steps]
runner.refine refinement
