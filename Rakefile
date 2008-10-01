# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'towelie'

task :default => 'spec:run'

PROJ.name = 'towelie'
PROJ.authors = 'Giles Bowkett, Brian Landau'
PROJ.email = ''
PROJ.url = 'http://github.com/brianjlandau/towelie'

PROJ.spec.opts << '--color --format specdoc --diff'
