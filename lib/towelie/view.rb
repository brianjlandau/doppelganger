module Towelie
  module View
    def to_ruby(nodes)
      nodes.inject("") do |string, method_def|
        string += Ruby2Ruby.new.process(method_def.node) + "\n\n"
      end
    end
  end
end

Towelie.send :include, Towelie::View
