module Towelie
  module NodeAnalysis
    def duplication?
      not duplicates.empty?
    end
    
    def duplicates
      method_nodes = @method_definitions.map(&:body)
      (@method_definitions.inject([]) do |duplicate_defs, method_def|
        node = method_def.body
        if method_nodes.duplicates?(node)
          if duplicate_defs.map{|mdef| mdef.first.body}.include?(node)
            duplicate_defs.find{|mdef| mdef.first.body == node } << method_def
          else
            duplicate_defs << [method_def]
          end
        end
        duplicate_defs
      end).compact.uniq
    end
    
    def unique
      @method_definitions - duplicates.map(&:first)
    end
    
    def homonyms
      homonyms = []
      # this picks up duplicates as well as homonyms, since a duplicate is technically also a homonym;
      # and I should probably run .uniq on it also.
      stepwise_mdefs do |method_definition_1, method_definition_2|
        homonyms << method_definition_1 if method_definition_1.name == method_definition_2.name
      end
      homonyms
    end
    
    def diff(threshold)
      diff_methods = []
      stepwise_mdefs do |method_definition_1, method_definition_2|
        if threshold >= Diff::LCS.diff(method_definition_1.flat_body_array, method_definition_2.flat_body_array).size
          unless diffed_methods_recorded?(diff_methods, method_definition_1, method_definition_2)
            diff_methods << [method_definition_1, method_definition_2]
          end
        end
      end
      diff_methods
    end
    
    protected
      def stepwise_mdefs
        @method_definitions.dup.each do |element1|
          @method_definitions.dup.each do |element2|
            next if element1.body == element2.body
            yield element1, element2
          end
        end
      end
      
      def diffed_methods_recorded?(diff_methods, mdef1, mdef2)
        diff_methods.any? do |method_pair|
          method_pair_nodes = method_pair.map(&:node)
          method_pair_nodes.include?(mdef1.node) && method_pair_nodes.include?(mdef2.node)
        end
      end
  end
end
