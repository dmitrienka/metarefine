#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'optparse'
load 'topaslib.rb'


options = {points:[100.0, 16.0, 0.0], steps:[4.0, 1.0], smart:false,  system: :wine}
OptionParser.new do |opts|
  opts.banner = "Usage: toparun.rb  [-p 100,15,0 -s 1,0.25] filename.inp"
  opts.on("-p", "--points LIST", Array ,"Array of points, representing intervals with different stepsizes"){|list|
    options[:points] = list.map(&:to_f)}
  opts.on("-s", "--steps LIST", Array ,"Well, stepsizes for that intervals"){|list|
    options[:steps] = list.map(&:to_f)}
  opts.on("-s", "--[no-]smart", "Gone smart!") do |s|
    options[:smart] = s
  end
  opts.on("--system [SYS]", [:windows, :wine, :dummy],
              "Select your system (windows, wine, dummy)") do |t|
        options[:system] = t
  end
end.parse!

ARGV[0] || raise("Rrrr! Where is my input file??")

TopasEngine.system = options[:system]


runner = TopasEngine.new
input = TopasInput.new IO.read(ARGV[0]), ARGV[0].sub(/\..{2,3}$/, '')

runner.refine input,  options[:points], options[:steps],  (options[:smart] ? QuantileAnalyzer.new : BaseAnalyzer.new)

