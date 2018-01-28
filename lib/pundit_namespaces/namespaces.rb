module PunditNamespaces
  class Namespaces
    def namespace(name, options = {}, &block)
      name = name.to_sym
      @parent ||= []

      ns = Namespace.new(name, options)
      @parent.inject(tree) { |acc, val| acc = acc[val]; acc } << Tree::TreeNode.new(name, ns)

      if block_given?
        @parent << name
        instance_eval(&block)
        @parent.pop
      end
    end

    def root_namespace(options = {}, &block)
      namespace(:_root_namespace, options, &block)
    end

    def matches(matcher)
      match_tree = find_match(matcher)
      children_names(match_tree)
    end

    private

    def find_match(matcher)
      new_tree = @tree.dup

      new_tree.each do |node|
        next unless node.content
        node.remove_from_parent! unless node.content.match?(matcher)
      end

      new_tree
    end

    def children_names(match_tree)
      match_tree.children.inject([]) do |acc, child|
        acc << child.name
        acc << children_names(child) if child.has_children?
        acc
      end
    end

    def tree
      @tree ||= Tree::TreeNode.new(:_root)
    end
  end
end
