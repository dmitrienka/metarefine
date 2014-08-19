Gem::Specification.new do |s|
  s.name        = 'topas-tools'
  s.version     = '0.0.0'
  s.date        = '2014-08-19'
  s.summary     = 'Rrrrr!'
  s.description = 'Gem for repetitive Rietveld refinements with Topas4-2'
  s.authors     = ["Artem Dmitrienko"]
  s.email       = 'dmitrienka@gmail.com'
  s.files       = ["lib/topas-tools.rb",
                   "lib/topas-tools/TopasEngine.rb",
                   "lib/topas-tools/TopasInput.rb",
                   "lib/topas-tools/Analyzers.rb"]
  s.add_runtime_dependency 'green_shoes',  '~> 1.1', '>= 1.1.374'
  s.executables   = ["toparunGUI", "toparun"]
  s.license       = 'GPL2'
end
