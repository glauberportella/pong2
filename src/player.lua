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
  self:reset_effects()
  return self
end

-- Estado alterado pelos power-ups
function Player:reset_effects()
  self.speed_mult = 1
  self.frozen = false      -- gelo: nao se move
  self.burned = false      -- fogo: nao rebate
  self.invisible = false   -- translucido: nao rebate
  self.full_height = false -- cobre toda a altura da tela
  self.inverted = false    -- controles cima/baixo trocados
end

function Player:height()
  return self.full_height and config.WINDOW_H or config.PLAYER_HEIGHT
end

function Player:top()
  return self.full_height and 0 or self.y
end

function Player:center_y()
  return self:top() + self:height() / 2
end

function Player:rect()
  return { x = self.x, y = self:top(), w = config.PLAYER_THICKNESS, h = self:height() }
end

function Player:can_hit()
  return not self.invisible and not self.burned
end

function Player:update(dt)
  if self.frozen or self.full_height then
    return
  end

  local down = love.keyboard.isDown(self.keys.down)
  local up = love.keyboard.isDown(self.keys.up)
  if self.inverted then
    up, down = down, up
  end

  local speed = config.PLAYER_SPEED * self.speed_mult
  if down then
    self.y = self.y + speed * dt
  end
  if up then
    self.y = self.y - speed * dt
  end

  self.y = math.max(0, math.min(self.y, config.WINDOW_H - config.PLAYER_HEIGHT))
end

function Player:draw()
  if self.burned then
    love.graphics.setColor(1, 0.35, 0.1)
  elseif self.frozen then
    love.graphics.setColor(0.6, 0.85, 1)
  end
  if self.invisible then
    local r, g, b = love.graphics.getColor()
    love.graphics.setColor(r, g, b, 0.2)
  end

  local r = self:rect()
  love.graphics.rectangle("fill", r.x, r.y, r.w, r.h)
  love.graphics.setColor(1, 1, 1, 1)
end

return Player
