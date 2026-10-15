-- Muralha: protege o dono do power-up. O oponente rebate contra ela,
-- quebrando um tijolo a cada batida, ate abrir passagem para a bola.

local config = require("src.config")
local collision = require("src.collision")

local wall = {}

local bricks = {}
local owner = nil

function wall.build(player)
  owner = player
  bricks = {}
  local total_w = config.WALL_COLUMNS * config.WALL_BRICK_W
  local x0 = (config.WINDOW_W - total_w) / 2
  for col = 0, config.WALL_COLUMNS - 1 do
    for row = 0, config.WALL_ROWS - 1 do
      table.insert(bricks, {
        x = x0 + col * config.WALL_BRICK_W,
        y = row * config.WALL_BRICK_H,
        w = config.WALL_BRICK_W,
        h = config.WALL_BRICK_H,
      })
    end
  end
end

function wall.clear()
  owner = nil
  bricks = {}
end

-- Quebra o tijolo atingido e devolve a bola. Retorna true se houve batida.
function wall.collide(ball)
  -- so bloqueia a bola que vai em direcao ao dono da muralha
  if not owner or ball.dx * owner.direction >= 0 then
    return false
  end

  local ball_rect = ball:rect()
  for i, brick in ipairs(bricks) do
    if collision.aabb(ball_rect, brick) then
      table.remove(bricks, i)
      ball:bounce_from(owner)
      return true
    end
  end
  return false
end

function wall.draw()
  for _, brick in ipairs(bricks) do
    love.graphics.setColor(0.55, 0.32, 0.25)
    love.graphics.rectangle("fill", brick.x, brick.y, brick.w, brick.h)
    -- rejunte
    love.graphics.setColor(0.25, 0.2, 0.2)
    love.graphics.rectangle("line", brick.x, brick.y, brick.w, brick.h)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return wall
