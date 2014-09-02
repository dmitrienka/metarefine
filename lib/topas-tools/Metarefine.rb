class Steps
  def initialize ps, ss
    ss.empty? &&  raise("Empty steps!")
    (ps.size == (ss.size + 1) ) || raise("Inconsistent points and steps: #{ps}, #{ss}")   
    @k1s = get_k1s ps, ss
  end
  attr_reader :k1s
  def get_k1s points, stepsizes 
    stepsizes.reduce([]){|result, stepsize| 
      a = result + 
          points[0].step(points[1] ,-stepsize.to_f).to_a + 
          [points[1].to_f]
      points.shift
      a}.uniq
  end    
end

class Metarefine 
  def initialize engine, input, basedir, steps
    @engine = engine
    @input = input
    @basedir = basedir
    @steps = steps 
    Dir.chdir @basedir
  end

  def toparun analyzer, work_dir = File.expand_path(@input.base_name)
    Dir.mkdir(work_dir) unless Dir.exists? work_dir
    @steps.k1s.reduce(@input) do |inp, k1|
      out = @engine.tc work_dir, inp.set_k1(k1)
      analyzer.analyze(out) ? out : break
    end
    Dir.chdir @basedir
    analyzer.report
  end
end
