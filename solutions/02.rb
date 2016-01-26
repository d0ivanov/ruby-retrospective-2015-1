def cells(width, height)
  columns = (0...dimensions[:width]).to_a
  rows = (0...dimensions[:height]).to_a

  columns.product(rows)
end

def move(snake, direction)
  grow(snake, direction).drop(1)
end

def grow(snake, direction)
  body_part = [snake.last[0] + direction[0], snake.last[1] + direction[1]]
  snake + [body_part]
end

def new_food(food, snake, dimensions)
  (cells(*dimensions.values) - snake - food).sample
end

def obstacle_ahead?(snake, direction, dimensions)
  cell_ahead = grow(snake, direction).last

  (is_wall?(cell_ahead, dimensions) || is_body_part?(cell_ahead, snake))
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) or
    obstacle_ahead?(move(snake, direction), direction, dimensions)
end

def is_wall?(position, dimensions)
  x, y = position
  x < 0 or x >= dimensions[:width] or y < 0 or y >= dimensions[:height]
end

def is_body_part?(position, snake)
  snake.include?(position)
end
