require "#{Doppelganger::LIBPATH}doppelganger/node_analysis"

MethodDef = Struct.new(:name, :args, :body, :node, :filename, :flat_body_array)

module Doppelganger
  # This class goes through all the ruby files in a directory and parses it into Sexp's.
  # It then exracts the definitions and stores them all and then includes the NodeAnalysis module
  # with allows a number of comparisons.
  class Analyzer < SexpProcessor
    include UnifiedRuby
    include Doppelganger::NodeAnalysis
    
    attr_reader :method_definitions, :dir
    
    def initialize(dir)
      super()
      @dir = File.expand_path(dir)
      self.auto_shift_type = true
      @pt = ParseTree.new(false)
      @method_definitions = []
      extract_definitions
    end
    
    # This does throw all the files in the directory and parses them extracting all the
    # method definitions.
    def extract_definitions
      Find.find(*Dir["#{self.dir}/**/*.rb"]) do |filename|
        if File.file? filename
          @current_filename = filename
          sexp = @pt.parse_tree_for_string(File.read(filename), filename)
          process Sexp.from_array(sexp).first
        end
      end
      @method_definitions
    end
    
    # When ever a <tt>defn</tt> node is enountered this is method is called and used
    # to process it. It extracts the method definition into our collection of methods.
    def process_defn(exp)
      method = MethodDef.new
      method.name = exp.shift
      method.args = process exp.shift
      method.body = process exp.shift
      method.flat_body_array = method.body.to_a.flatten
      method.node = s(:defn, method.name, method.args, method.body)
      method.filename = File.expand_path(@current_filename)
      
      @method_definitions << method
      
      s(:defn, method.name, method.args, method.body)
    end
    
  end
end
