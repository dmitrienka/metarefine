class TopasEngine
  def self.create system, topasdir
    case system
    when :wine
      WineTopasEngine.new    topasdir
    when :windows
      WindowsTopasEngine.new topasdir
    when :dummy
      TopasEngine.new        topasdir
    else
      raise "Bad system: #{system}"
    end
  end
  
  def initialize topasdir
    @enc = 'UTF-8'
    Dir.exists?(topasdir) || raise("Non-existing directory!")
    Dir.entries(topasdir).any?{|f| f == 'tc.exe'} || raise("Where is my tc.exe?!")
    @topasdir = topasdir    
  end

  def tc dir, input
    infile = "#{input.name}.inp"
    Dir.chdir dir
    File.open(infile, mode:'w'){|f| f.write input.text}
    cmd = command infile
    Dir.chdir @topasdir
    system(cmd)
    Dir.chdir dir
    TopasInput.new IO.read("#{input.name}.out", :encoding => @enc)
  end

  private
  
  def command filename
    filepath = File.expand_path filename
    dirpath =  File.dirname filepath
    outfile =  File.join dirpath, filename.sub(/\..{2,3}$/ , '.out')
    "cp #{filepath} #{outfile}"
  end
end

class WindowsTopasEngine < TopasEngine
  private
  def command infile
    "tc.exe #{File.expand_path(infile)}"
  end
end

class WineTopasEngine < TopasEngine
  private
  def command infile
    path = `winepath -w #{infile}`.gsub('\\', '\\\\\\').gsub("\n", "")
    "wine tc.exe #{path}"
  end
end
