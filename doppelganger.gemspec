Gem::Specification.new do |s|
  s.name = %q{doppelganger}
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Landau"]
  s.date = %q{2008-11-18}
  s.default_executable = %q{doppelganger}
  s.description = %q{Doppelganger helps you to find areas of your code that are good places to refactor.  It does this by finding methods and blocks that are duplicates or have less then a set threshold level of difference or be less then a specified percent different. This library can either be used with in another larger code metric/heuristic library, or called from the command line.}
  s.email = %q{brian.landau@viget.com}
  s.executables = ["doppelganger"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.rdoc"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "bin/doppelganger", "doppelganger.gemspec", "lib/doppelganger.rb", "lib/doppelganger/extractor.rb", "lib/doppelganger/exts/array.rb", "lib/doppelganger/exts/sexp.rb", "lib/doppelganger/node_analysis.rb", "lib/doppelganger/unified_ruby.rb", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/manifest.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/test.rake", "test/array_test.rb", "test/doppelganger_test.rb", "test/sample_files/duplicate_test_data/first_file.rb", "test/sample_files/duplicate_test_data/second_file.rb", "test/sample_files/larger_diff/first_file.rb", "test/sample_files/larger_diff/second_file.rb", "test/sample_files/repeats_removal_sample_file.rb", "test/sample_files/sexp_test_file.rb", "test/sexp_ext_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://doppelganger.rubyforge.org/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{doppelganger}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Doppelganger helps you to find areas of your code that are good places to refactor}
  s.test_files = ["test/array_test.rb", "test/doppelganger_test.rb", "test/sexp_ext_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sexp_processor>, ["~> 3.0.0"])
      s.add_runtime_dependency(%q<ruby_parser>, ["~> 2.0.0"])
      s.add_runtime_dependency(%q<ruby2ruby>, ["~> 1.2.0"])
      s.add_runtime_dependency(%q<diff-lcs>, ["~> 1.1"])
      s.add_runtime_dependency(%q<highline>, ["~> 1.4"])
      s.add_runtime_dependency(%q<facets>, ["~> 2.4"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, ["~> 2.0"])
    else
      s.add_dependency(%q<sexp_processor>, ["~> 3.0.0"])
      s.add_dependency(%q<ruby_parser>, ["~> 2.0.0"])
      s.add_dependency(%q<ruby2ruby>, ["~> 1.2.0"])
      s.add_dependency(%q<diff-lcs>, ["~> 1.1"])
      s.add_dependency(%q<highline>, ["~> 1.4"])
      s.add_dependency(%q<facets>, ["~> 2.4"])
      s.add_dependency(%q<thoughtbot-shoulda>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<sexp_processor>, ["~> 3.0.0"])
    s.add_dependency(%q<ruby_parser>, ["~> 2.0.0"])
    s.add_dependency(%q<ruby2ruby>, ["~> 1.2.0"])
    s.add_dependency(%q<diff-lcs>, ["~> 1.1"])
    s.add_dependency(%q<highline>, ["~> 1.4"])
    s.add_dependency(%q<facets>, ["~> 2.4"])
    s.add_dependency(%q<thoughtbot-shoulda>, ["~> 2.0"])
  end
end
