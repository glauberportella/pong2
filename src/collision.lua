-- Colisao entre retangulos {x, y, w, h}

local collision = {}

function collision.aabb(a, b)
  local inter_x = a.x + a.w >= b.x and a.x <= b.x + b.w
  local inter_y = a.y + a.h >= b.y and a.y <= b.y + b.h
  return inter_x and inter_y
end

return collision
