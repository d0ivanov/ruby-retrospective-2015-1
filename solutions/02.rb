def sum_arrays(a, b)
  a.map.with_index {|element, i| element + b[i]}
end

def cells(width, height)
  cell_count = [width, height].max
  cells = [*0..cell_count].repeated_permutation(2).to_a
  cells.reject {|cell| cell[0] >= width or cell[1] >= height}
end

def move(snake, direction)
  new_snake = snake + [sum_arrays(snake.last, direction)]
  new_snake.shift
  new_snake
end

def grow(snake, direction)
  snake + [sum_arrays(snake.last, direction)]
end

def new_food(food, snake, dimensions)
  (cells(dimensions[:width], dimensions[:height]) - snake - food).sample
end

def obstacle_ahead?(snake, direction, dimensions)
  snake = move(snake, direction)
  cells = cells(dimensions[:width], dimensions[:height])

  snake.count(snake.last) > 1 or !cells.include?(snake.last)
end

def danger?(snake, direction, dimensions)
  moved_snake_a = move(snake, direction)
  moved_snake_b = move(moved_snake_a, direction)

  obstacle_ahead?(moved_snake_a, direction, dimensions) or
    obstacle_ahead?(moved_snake_b, direction, dimensions)
end
