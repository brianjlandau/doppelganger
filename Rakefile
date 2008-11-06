# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'doppelganger'

task :default => 'spec:run'

PROJ.name = 'doppelganger'
PROJ.authors = 'Brian Landau'
PROJ.email = 'brian.landau@viget.com'
PROJ.url = 'http://github.com/brianjlandau/doppelganger'
PROJ.version = Doppelganger::VERSION
PROJ.rdoc.include << 'LICENSE'

PROJ.spec.opts << '--color --format specdoc --diff'

%W(parse_tree ruby2ruby diff-lcs sexp_processor).each  do |gem|
  depend_on gem
end
