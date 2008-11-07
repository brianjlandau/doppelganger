
if test(?e, PROJ.test.file) or not PROJ.test.files.to_a.empty?
require 'rake/testtask'
if HAVE_RCOV
  require 'rcov/rcovtask'
end

namespace :test do

  Rake::TestTask.new(:run) do |t|
    t.libs = PROJ.libs
    t.test_files = if test(?f, PROJ.test.file) then [PROJ.test.file]
                   else PROJ.test.files end
    t.ruby_opts += PROJ.ruby_opts
    t.ruby_opts += PROJ.test.opts
  end

  if HAVE_RCOV
    desc 'Run rcov on the unit tests'
    Rcov::RcovTask.new do |t|
      t.test_files = PROJ.test.files
      opts = PROJ.rcov.opts.dup << '-o' << PROJ.rcov.dir
      t.rcov_opts = PROJ.rcov.opts
    end
  end

end  # namespace :test

desc 'Alias to test:run'
task :test => 'test:run'

end

# EOF
