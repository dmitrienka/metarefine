require 'green_shoes'
require 'stringio'


Shoes.app :width => 420 , :scroll=> true do

  # init 
  background "#F3F".."#F90"


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
      
   
      
      flow :width => 400, :height=> 150, :margin => 20  do
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


