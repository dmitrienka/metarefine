# -*- coding: utf-8 -*-
require 'stringio'
require 'green_shoes'
load "~/github/metarefine/topaslib.rb"


Shoes.app :width => 400, :height => 800  do

  @log = StringIO.new
  @log.write "Hi, log starts here!\n"
  
  def log
    @log
  end
  
  #base flow
  flow  :margin=>10 do

    title 'ToparunGUI'    

    #big stack
    stack do
      caption 'Your system:'
      @systemlist = list_box items:['wine','windows','dummy'], choose:'wine' 

      caption 'Your Topas4-2 directory:'
      
      #small flow 
      flow do
        @topasdir = edit_line
        button 'Open' do
          @topasdir.text = ask_open_folder
        end
      end
      #\small flow
      
      caption  "Points and steps"
      para "TODO объяснить, кто все эти люди"
      flow do
        para "Points:"
        @pointline = edit_line
        @pointline.text = "100,16,0"
      end

      flow do
        para "Points:"
        @stepsline = edit_line
        @stepsline.text = "4,1"
      end
      caption "Your input file"
      flow do
        @inpline = edit_line
        button 'open' do
          @inpline.text = ask_open_file
        end
      end

        button 'Mf button!' do
          begin
            points = @pointline.text.split(/[,\s]+/).map(&:to_f)
            steps  = @stepsline.text.split(/[,\s]+/).map(&:to_f)
            rescue alert("Блюди формат точек и шагов!!")
          end

          Thread.new(points, steps, @log ) do  |points, steps|
            inp = @inpline.text
            TopasEngine.system = @systemlist.text.to_sym
            runner = TopasEngine.new File.dirname(inp) 
            input = TopasInput.new IO.read(inp, :encoding => "UTF-8"),  inp
            runner.refine input,  points, steps,  BaseAnalyzer.new(@log)
            @clear = button 'Clear' do
              @log = StringIO.new
              @clear.clear
            end
          end
        end
  
        para self
      caption "Log:"
      stack :width => 300,   :margin => 20 do
 
 
         @paralog = para
        every 1  do |i|
          a =  @log.string
          @paralog.text = a  unless @paralog.text == a
        flush
        end
      end


    end
  end
end


