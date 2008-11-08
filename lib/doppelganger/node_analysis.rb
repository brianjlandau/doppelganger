module Doppelganger
  # This handles the analysis of the method definitions.
  # This will use various iterators to compare all the diffent methods in your code base
  # and find similar or duplicate methods. It will also display unique methods.
  module NodeAnalysis
    
    # Are there any duplicates in the code base.
    def duplication?
      not duplicates.empty?
    end
    
    # Finds methods that are exact duplicates, node for node. All duplicate methods
    # are grouped together.
    def duplicates
      method_nodes = @method_definitions.map{ |mdef| mdef.body.remove_literals }
      (@method_definitions.inject([]) do |duplicate_defs, method_def|
        node = method_def.body.remove_literals
        if method_nodes.duplicates?(node)
          if duplicate_defs.map{|mdef| mdef.first.body.remove_literals}.include?(node)
            duplicate_defs.find{|mdef| mdef.first.body.remove_literals == node } << method_def
          else
            duplicate_defs << [method_def]
          end
        end
        duplicate_defs
      end).compact.uniq
    end
    
    # Reports methods that have no duplicates
    def unique
      @method_definitions - duplicates.map(&:first)
    end
    
    # Finds method that differ from another method by the threshold or less, but are not duplicates.
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
    
    # Finds methods that differ by a given threshold percentage or less, but are not duplicates.
    def percent_diff(percentage)
      # To calculate the percentage we can do this in one of two ways we can compare
      # total differences (the diff set flattened) over the total nodes (the flattened bodies added)
      # or we can compare the number of change sets (the size of the diff) over the average number of nodes
      # in the two methods.
      # Not sure which is best but I've gone with the former for now.
      diff_methods = []
      stepwise_mdefs do |method_definition_1, method_definition_2|
        total_nodes = method_definition_1.flat_body_array.size + method_definition_2.flat_body_array.size
        diff_size = Diff::LCS.diff(method_definition_1.flat_body_array, method_definition_2.flat_body_array).flatten.size
        if percentage >= (diff_size.to_f/total_nodes.to_f * 100)
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
            next if element1.body.remove_literals == element2.body.remove_literals
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
