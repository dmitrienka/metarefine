require 'stringio'


Shoes.app :width => 400, :height => 600  do


  #base flow
  flow  :margin=>10 do

    title 'It\'s toparun2.rb in shoes!!'    

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
      
      caption  "Mf test now!"
      flow do 
        @mfline = edit_line
        @mfline.text = "Fuck you!"
        button 'Mf button!' do
          Thread.new{
            $stdout = @log
            (1..10).each{|i| sleep 0.5; print "This is yor motherfucking string: #{@mfline.text}\n"}
            $stdout = STDOUT
          }
        end
      end
      
   
      
      flow :width => 0.9, :height=> 400, :margin => 20, :scroll => true  do
        caption "Loggin para!"
        @log = StringIO.new
        @log.write "Hi, log starts here!\n"

        @paralog = para
        every 1 do 
          @paralog.text = @log.string
        end
      end


    end
  end
end


