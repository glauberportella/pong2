-- Neblina sobre a quadra inteira

local config = require("src.config")

local fog = {}

local CLOUD_COUNT = 14

local clouds = {}
local active = false

local function new_cloud()
  local size = love.math.random(140, 260)
  return {
    x = love.math.random(-size, config.WINDOW_W),
    y = love.math.random(0, config.WINDOW_H),
    size = size,
    speed = love.math.random(20, 60) * (love.math.random() < 0.5 and -1 or 1),
  }
end

function fog.start()
  active = true
  clouds = {}
  for i = 1, CLOUD_COUNT do
    clouds[i] = new_cloud()
  end
end

function fog.stop()
  active = false
  clouds = {}
end

function fog.update(dt)
  if not active then
    return
  end
  -- nuvens deslizam e reaparecem do outro lado
  for _, cloud in ipairs(clouds) do
    cloud.x = cloud.x + cloud.speed * dt
    if cloud.x > config.WINDOW_W + cloud.size then
      cloud.x = -cloud.size
    elseif cloud.x < -cloud.size then
      cloud.x = config.WINDOW_W + cloud.size
    end
  end
end

function fog.draw()
  if not active then
    return
  end

  -- camada de fundo para a quadra toda
  love.graphics.setColor(0.6, 0.6, 0.65, 0.35)
  love.graphics.rectangle("fill", 0, 0, config.WINDOW_W, config.WINDOW_H)

  -- nuvens: cada uma e um grupo de elipses
  love.graphics.setColor(0.75, 0.75, 0.8, 0.45)
  for _, c in ipairs(clouds) do
    love.graphics.ellipse("fill", c.x, c.y, c.size, c.size * 0.45)
    love.graphics.ellipse("fill", c.x - c.size * 0.5, c.y + c.size * 0.1, c.size * 0.6, c.size * 0.35)
    love.graphics.ellipse("fill", c.x + c.size * 0.5, c.y + c.size * 0.15, c.size * 0.55, c.size * 0.3)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return fog
