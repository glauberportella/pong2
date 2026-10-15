-- Raquete de um jogador

local config = require("src.config")

local Player = {}
Player.__index = Player

-- direction: sentido em que o jogador rebate a bola no eixo x (1 = direita, -1 = esquerda)
function Player.new(id, x, keys, direction, beep)
  local self = setmetatable({}, Player)
  self.id = id
  self.x = x
  self.y = config.PLAYER_START_Y
  self.keys = keys
  self.direction = direction
  self.beep = beep
  return self
end

function Player:height()
  return config.PLAYER_HEIGHT
end

function Player:top()
  return self.y
end

function Player:center_y()
  return self:top() + self:height() / 2
end

function Player:rect()
  return { x = self.x, y = self:top(), w = config.PLAYER_THICKNESS, h = self:height() }
end

function Player:update(dt)
  if love.keyboard.isDown(self.keys.down) then
    self.y = self.y + config.PLAYER_SPEED * dt
  end
  if love.keyboard.isDown(self.keys.up) then
    self.y = self.y - config.PLAYER_SPEED * dt
  end
end

function Player:draw()
  local r = self:rect()
  love.graphics.rectangle("fill", r.x, r.y, r.w, r.h)
end

return Player
