require 'pp'
module Towelie
  class CodeBase < SexpProcessor
    include UnifiedRuby
    
    attr_reader :method_definitions
    
    def initialize
      super
      self.auto_shift_type = true
      @pt = ParseTree.new(false)
      @method_definitions = []
    end
    
    def extract_definitions(dir)
      dir = File.expand_path(dir)
      Find.find(*Dir["#{dir}/**/*.rb"]) do |filename|
        if File.file? filename
          @current_filename = filename
          sexp = @pt.parse_tree_for_string(File.read(filename), filename)
          process Sexp.from_array(sexp).first
        end
      end
      @method_definitions
    end
  
    def process_defn(exp)
      method = OpenStruct.new
      method.name = exp.shift
      method.args = process exp.shift
      method.body = process exp.shift
      method.node = s(:defn, method.name, method.args, method.body)
      method.filename = File.expand_path(@current_filename)
      
      @method_definitions << method
      
      s(:defn, method.name, method.args, method.body)
    end
    
  end
end
