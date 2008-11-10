require File.dirname(__FILE__) + '/test_helper'

class DoppelgangerSexpTest < Test::Unit::TestCase
  
  context 'extended Sexp object' do
    setup do
      @pt = RubyParser.new
      sample_file_path = File.expand_path(File.join(File.dirname(__FILE__), 'sample_files/sexp_test_file.rb'))
      @sexp = @pt.process(File.read(sample_file_path), sample_file_path)
    end
    
    should 'remove all literal objects' do
      clean_sexp_array = [:defn,
                         :muir,
                         [:args],
                         [:scope,
                          [:block,
                           [:call, :puts, [:arglist, [:str]]],
                           [:iasgn, :@variable, [:str]],
                           [:iter,
                            [:call,
                             [:array, [:str], [:str], [:str], [:str]],
                             :each,
                             [:arglist]],
                            [:lasgn, :word],
                            [:call, [:lvar, :word], :size, [:arglist]]]]]]
      assert_equal clean_sexp_array, @sexp.remove_literals.to_a
    end
    
    should 'return flattened array' do
      flat_array = [:defn, :muir, :args, :scope, :block, :call, nil, :puts, :arglist, :str, 
                    "John Muir", :iasgn, :@variable, :str, "muir", :iter, :call, :array, :str, 
                    "this", :str, "is", :str, "some", :str, "words", :each, :arglist, :lasgn, 
                    :word, :call, :lvar, :word, :size, :arglist]
      assert_equal flat_array, @sexp.to_flat_ary
    end
    
    should 'retrive last line number for a given node' do
      assert_respond_to @sexp, :last_line_number
      assert_equal 6, @sexp.last_line_number
    end
    
    teardown do
      @pt, @sexp = nil
    end
  end
  
end
