class Node
    attr_accessor :data, :left, :right
    def initialize(data = nil, left = nil, right = nil)
        @data = data
        @left = left
        @right = right
    end
end

class Tree
    def initialize(array)
        @array_no_duplicates = array.uniq
        @sorted_array = bubble_sort(@array_no_duplicates)
        @root = build_tree(@sorted_array)
    end

    def bubble_sort(array)
        intermediate = 0
        x = 0
        array_count = array.count
        indices = array_count - 1
        while x < array_count
        y = 0
        while y < indices
            if array[y+1] != nil
                if array[y] > array[y+1]
                    intermediate = array[y]
                    array[y] = array[y+1]
                    array[y+1] = intermediate
                end
            end
            y += 1
        end
        x +=1
        end
        return array
    end

    def build_tree(array)
        if array.size == 1 && array[0] == @sorted_array[0]
            return Node.new(array[0])
        elsif array.size == 1
            return nil
        end
        midpoint = array.size / 2
        left_half = array[0...midpoint]
        right_half = array[midpoint...array.size]
        node = Node.new(array[midpoint], build_tree(left_half), build_tree(right_half))
    end

    def insert(value)
        @array_no_duplicates.push(value) unless @array_no_duplicates.include?(value)
        node = @root
        until @root.left == nil && @root.right == nil
            if value < node.data
                if node.left == nil
                    node.left = Node.new(value)
                    break
                else
                    node = node.left
                end
            elsif value > node.data
                if node.right == nil
                    node.right = Node.new(value)
                    break
                else
                    node = node.right
                end
            elsif value == node.data
                return "This element is already present in the tree"
            end
        end
    end

    def pretty_print(node = @root, prefix = '', is_left = true)
        pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
        puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
        pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
    end

    def find(value)
        node = @root
        until node.data == value 
            if value < node.data
                one_prior = node
                node = node.left
            elsif value > node.data
                one_prior = node
                node = node.right
            end
            if node == nil
                return 'This value is not contained in this tree'
            end
        end
        return node
    end 
    
    def delete(value)
        node = @root
        until node.data == value
            if value < node.data
                one_prior = node
                node = node.left
            elsif value > node.data
                one_prior = node
                node = node.right
            end
        end
        if node == @root && node.left == nil && node.right == nil
            return nil
        elsif node.left == nil && node.right == nil && node.data == value
            one_prior.left = nil
        elsif node.left == nil && node.right == nil && node.data == value
            one_prior.right = nil
        elsif node == @root && node.right == nil
            return node.left
        elsif node == @root && node.left == nil
            return node.right
        elsif node.left == nil 
            node.data < one_prior.data ? one_prior.left = node.right : one_prior.right = node.right
        elsif node.right == nil
            node.data < one_prior.data ? one_prior.left = node.left : one_prior.right = node.left
        else
            copy = node
            next_biggest = node.right
            until next_biggest.left == nil
                next_biggest = next_biggest.left
            end
            copy_next_biggest = next_biggest
            delete(next_biggest.data)
            if node != @root 
                node.data > one_prior.data ? one_prior.right = copy_next_biggest : one_prior.left = copy_next_biggest
            else
                @root.data = copy_next_biggest.data
            end
            copy_next_biggest.right = node.right
            copy_next_biggest.left = node.left
        end
    end

    def level_order(node = @root)
        node_queue = []
        node_output = []
        node_queue << node
        until node_queue.empty?
            node = node_queue.shift
            node_queue << node.left unless node.left == nil
            node_queue << node.right unless node.right == nil
            node_output << node
        end
        if block_given? 
            qualifying_nodes = []
            node_output.each do |node|
                if yield(node)
                    qualifying_nodes << node
                end
            end
            return qualifying_nodes
        else
            return node_output
        end
    end

    def preorder(node = @root)
        node_queue = []
        node_queue_right = []
        node_output = []
        root_node = node
        node_output << node
        until node.left == nil && node_queue_right.empty?
            if node.left != nil
                node = node.left
            else
                right = node_queue_right.shift
                node = right
            end
            node_queue << node
            if (node.right != nil)
                node_queue_right.unshift(node.right)
            end
            node_output << node_queue.shift
        end
        node = root_node.right
        node_output << node
        node_queue_right << node.right
        until node.left == nil && node_queue_right.empty? 
            if node.left != nil
                node = node.left
            else
                right = node_queue_right.shift
                node = right
            end
            node_queue << node
            if (node.right != nil)
                node_queue_right.unshift(node.right)
            end
            node_output << node_queue.shift
        end
        if block_given? 
            qualifying_nodes = []
            node_output.each do |node|
                if yield(node)
                    qualifying_nodes << node
                end
            end
            return qualifying_nodes
        else
            return node_output
        end
    end

    def inorder(node = @root)
        node_queue = []
        node_queue << inorder(node.left) unless node.left == nil
        node_queue << node
        node_queue << inorder(node.right) unless node.right == nil
        return node_queue
    end
            
    def postorder(node = @root)
        node_queue = []
        node_queue << postorder(node.left) unless node.left == nil
        node_queue << postorder(node.right) unless node.right == nil
        node_queue << node
        return node_queue
    end

    def depth(value, root = @root)
        node = root
        deep = 0
        until node.data == value 
            if value < node.data
                one_prior = node
                node = node.left
                deep += 1
            elsif value > node.data
                one_prior = node
                node = node.right
                deep += 1
            end
            if node == nil
                return 'This value is not contained in this tree'
            end
        end
        return deep
    end 

    def height(value)
        root = find(value)
        node_output = level_order(root)
        last_element = level_order(root).pop
        depth(last_element.data, root)
    end

    def balanced?
        node_output = level_order
        node_output.each do |node|
            if node.left == nil && node.right != nil
                return false if height(node.right.data) > 1
            elsif node.right == nil && node.left != nil
                return false if height(node.left.data) > 1
            elsif node.left == nil && node.right == nil
            elsif (height(node.left.data) - height(node.right.data) > 1) || (height(node.right.data) - height(node.left.data) > 1)
                return false
            end
        end
        return true
    end

    def rebalance
        node_numbers = @array_no_duplicates
        sorted_numbers = bubble_sort(@array_no_duplicates)
        @root = build_tree(sorted_numbers)
    end

end
tree = Tree.new([1, 3, 5, 7, 9, 11, 13])
tree.pretty_print

p tree.postorder
