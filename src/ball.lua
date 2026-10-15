-- Bola

local config = require("src.config")

local Ball = {}
Ball.__index = Ball

function Ball.new()
  local self = setmetatable({}, Ball)
  self.x = 0
  self.y = 0
  self.dx = config.BALL_SPEED
  self.dy = config.BALL_SPEED
  self:reset_effects()
  return self
end

-- Estado alterado pelos power-ups
function Ball:reset_effects()
  self.fire = false
  self.ice = false
  self.blink = false
end

function Ball:rect()
  return { x = self.x, y = self.y, w = config.BALL_SIZE, h = config.BALL_SIZE }
end

-- Move a bola, quicando nas bordas da tela
function Ball:update(dt)
  local nx = self.x + self.dx * dt
  if nx < 0 or nx + config.BALL_SIZE >= config.WINDOW_W then
    self.dx = -self.dx
  else
    self.x = nx
  end

  local ny = self.y + self.dy * dt
  if ny < 0 or ny + config.BALL_SIZE >= config.WINDOW_H then
    self.dy = -self.dy
  else
    self.y = ny
  end
end

-- Bola na mao do jogador que vai sacar, acompanhando a raquete
function Ball:place_at_serve(player)
  if player.direction > 0 then
    self.x = player.x + config.PLAYER_THICKNESS + 1
  else
    self.x = player.x - config.BALL_SIZE - 1
  end
  self.y = player:center_y() - config.BALL_SIZE / 2
end

-- Rebatida (ou saque): manda a bola para o lado do adversario do jogador
function Ball:bounce_from(player)
  self.dx = player.direction * math.abs(self.dx)
end

function Ball:draw()
  -- piscando: some metade do tempo
  if self.blink and math.floor(love.timer.getTime() * 6) % 2 == 1 then
    return
  end

  if self.fire then
    love.graphics.setColor(1, 0.45, 0.1)
  elseif self.ice then
    love.graphics.setColor(0.6, 0.85, 1)
  end
  love.graphics.rectangle("fill", self.x, self.y, config.BALL_SIZE, config.BALL_SIZE)
  love.graphics.setColor(1, 1, 1, 1)
end

return Ball
