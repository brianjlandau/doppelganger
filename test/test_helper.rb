require 'test/unit'
require 'rubygems'
require 'shoulda'
require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib doppelganger]) )


class DoppelgangerTestCase < Test::Unit::TestCase
  def setup
    @the_nodes = [
      # second_file.rb
      [:defn, :foo, [:args], [:scope, [:block, [:return, [:str, "also not unique"]]]]],
      [:defn, :baz, [:args], [:scope, [:block, [:or, [:true], [:str, "is unique"]]]]],

      # first_file.rb
      [:defn, :foo, [:args], [:scope, [:block, [:call, nil, :puts, [:arglist, [:lit, :something_unique]]]]]],
      [:defn, :bar, [:args], [:scope, [:block, [:return, [:str, "something not unique"]]]]]
    ]

    @bigger_diff_blocks = [
[:defn, :foo, [:args], 
  [:scope, 
    [:block, 
      [:call, nil, :puts, 
        [:arglist, [:str, "muppetfuckers"]]], 
        [:iasgn, :@variable, [:str, "foo"]], 
        [:iter, [:call, 
          [:array, [:str, "this"], [:str, "is"], [:str, "some"], [:str, "words"]], :each, [:arglist]], 
          [:lasgn, :word], 
          [:call, [:lvar, :word], :size, [:arglist]]]]]],
[:defn, :bar, [:args], 
  [:scope, [:block, 
    [:call, nil, :puts, 
      [:arglist, [:str, "muppetfuckers"]]], 
      [:iter, [:call, 
        [:array, [:str, "this"], [:str, "is"], [:str, "bad"], [:str, "words"]], :each, [:arglist]], 
        [:lasgn, :word], 
        [:call, nil, :puts, [:arglist, [:lvar, :word]]]], 
      [:iasgn, :@variable, [:str, "bar"]]]]]
    ]
    
    duplicate_sample_file_path = File.expand_path(File.join(File.dirname(__FILE__), 'sample_files/duplicate_test_data'))
    @duplicate_analysis = Doppelganger::Analyzer.new(duplicate_sample_file_path)
  end
  
  def default_test; end
  
  def teardown
    @the_nodes,  @unique_block, @bigger_diff_blocks, @duplicate_analysis = nil
  end
end

