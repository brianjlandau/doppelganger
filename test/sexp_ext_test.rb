require File.dirname(__FILE__) + '/test_helper'

class DoppelgangerSexpTest < Test::Unit::TestCase
  
  context 'extended Sexp object' do
    setup do
      @pt = RubyParser.new
      @sexp = @pt.process(File.read('sample_files/sexp_test_file.rb'), 'sample_files/sexp_test_file.rb')
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
    
    teardown do
      @pt, @sexp = nil
    end
  end
  
end
