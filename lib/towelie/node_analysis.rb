module Towelie
  module NodeAnalysis
    def duplication?
      not duplicates.empty?
    end
    
    def duplicates
      method_nodes = @method_definitions.map(&:body)
      (@method_definitions.inject([]) do |duplicate_defs, method_def|
        node = method_def.body
        if method_nodes.duplicates?(node) && !duplicate_defs.map(&:body).include?(node)
          duplicate_defs << method_def
        end
        duplicate_defs
      end).compact.uniq
    end
    
    def unique
      @method_definitions - duplicates
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
      diff_nodes = []
      stepwise_mdefs do |method_definition_1, method_definition_2|
        if threshold >= (method_definition_1.body - method_definition_2.body).size
          diff_nodes << method_definition_1
          # note this hash approach fails to record multiple one-node-diff methods with the same name
        end
      end
      diff_nodes
    end
    
    protected
      def stepwise_mdefs
        @method_definitions.each do |element1|
          @method_definitions.each do |element2|
            next if element1.body == element2.body
            yield element1, element2
          end
        end
      end
  end
end
