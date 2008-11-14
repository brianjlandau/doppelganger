# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'doppelganger'

task :default => 'test:run'

PROJ.name = 'doppelganger'
PROJ.authors = 'Brian Landau'
PROJ.email = 'brian.landau@viget.com'
PROJ.url = 'http://doppelganger.rubyforge.org/'
PROJ.version = Doppelganger::VERSION
PROJ.rubyforge.name = 'doppelganger'

PROJ.rcov.opts = ['--no-html', '-T', '--sort coverage',
                  '-x "\/Library\/Ruby\/"', 
                  '-x "\/opt\/local\/lib/ruby"',
                  '-x "\/System\/Library\/"']


PROJ.gem.development_dependencies = [['thoughtbot-shoulda', '~> 2.0']]
depend_on 'sexp_processor', '~> 3.0.0'
depend_on 'ruby_parser', '~> 2.0.0'
depend_on 'ruby_parser', '~> 2.0.0'
depend_on 'ruby2ruby', '~> 1.2.0'
depend_on 'diff-lcs', '~> 1.1'
depend_on 'highline', '~> 1.4'

