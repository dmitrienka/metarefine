class BaseAnalyzer

K1TABLE = [5.62619251369954 ,3.59689767105988, 2.99683950381941, 2.9141936236358 , 3.37232041437195 ,2.93196313616901, 2.72771585462825, 2.70417682172506, 2.86576896853064 ,2.66921102377684, 2.57092705221669, 2.55881443841962, 2.64995441497466 ,2.53075618782533, 2.47791909362932, 2.4741828679544 , 2.53384546494551 ,2.45983379319381, 2.4212286638301 , 2.4159429171073 , 2.45784825894735 ,2.40879237590095, 2.38090443345185, 2.38216835038994, 2.41048201093783 ,2.36989342570794, 2.35215022384351, 2.3524695182014, 2.37772035649117 ,2.34643406722578, 2.33269558844597, 2.33379314746303, 2.35213581186961 ,2.3293126888992 , 2.31585973838799, 2.32211834728897, 2.33719246258054 ,2.31822219208683, 2.30836925652429, 2.30928647548234, 2.32053355883361 ,2.30880999917026, 2.29983955811199, 2.30081635190135, 2.31427557030017 ,2.29827012906655]

  def initialize output = $stdout
    @out = output
    @count = 0
    @rtable = []
  end
  
  def analyze inp
    restrains = inp.restrains
    restrains.each do |r|
      @rtable << {k1:inp.k1, r_wp:inp.r_wp, name:r[:name],
                  delta:(r[:value] - r[:restrain])}
    end
    @name = inp.base_name
    errors = restrains.map{|r| r[:value] - r[:restrain]}
    mdev = max_dev(errors)
    mult = K1TABLE[restrains.size - 5]
    outlier = (mdev > mult ? "x" : "o")
    @out.print "%d\t%0.3f\t%0.3f\t%0.3f\t#{outlier}\n" % [inp.k1, inp.r_wp, mdev, mult]
    @count = @count + 1
    true
  end

  
  def report 
    @out.print "Refinement  was finished in #{@count} steps.\n"
    file = File.open("#{@name}_rtable.dat", 'w')
    file.write("K1\tRwp\tBond\tDelta\tError\n")
    @rtable.each do |rt|
      file.write("#{rt[:k1]}\t#{rt[:r_wp]}\t#{rt[:name]}\t#{rt[:delta]}\t0\n")
    end
    file.close
    true
  end
  
  private
  
  def quantile7 p, x
    n = x.size
    sorted = x.sort
    j = (n*p - p +1).floor
    g = n*p - p + 1 - j
    (1 - g) * sorted[j - 1] + g * sorted[j]
  end

  def max_dev x
    q1 = quantile7 0.25, x
    q3 = quantile7 0.75, x
    iqr = q3 - q1
    [(q1 - x.min)/iqr, (x.max-q3)/iqr].max
  end
end
