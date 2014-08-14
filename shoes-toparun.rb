# -*- coding: utf-8 -*-
require 'stringio'
load "~/github/metarefine/topaslib.rb"

Shoes.app :width => 300, :height => 500  do

  @log = StringIO.new
  @log.write "Hi, log starts here!\n"

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
      
      caption  "Point and steps"
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

          Thread.new(points, steps ) do  |points, steps|
            inp = @inpline.text
            TopasEngine.system = @systemlist.text.to_sym
            runner = TopasEngine.new File.dirname(inp) 
            input = TopasInput.new IO.read(inp, :encoding => "UTF-8"),  inp.sub(/\..{2,3}$/, '')


            $stdout = @log
            runner.refine input,  points, steps,  BaseAnalyzer.new
            $stdout = STDOUT
          end
        end

      
   
      caption "Log:"
      @logstack = stack :width => 0.9, :height=> 250, :margin => 20, :scroll => true  do
        @paralog = para :width => 1.0, :height => 1.0
        every do 
          @paralog.text = @log.string
          @logstack.scroll_top =  @logstack.scroll_max
        end
      end


    end
  end
end


