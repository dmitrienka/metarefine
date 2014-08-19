class BaseAnalyzer
  def initialize output = $stdout
    @out = output
    @count = 0
  end
  
  def analyze inp
    @out.print "Analizing #{inp.name}... \n"
    @count = @count + 1
    true
  end
  
  def report 
    @out.print "Refinement  was finished in #{@count} steps.\n"
    true
  end
end
