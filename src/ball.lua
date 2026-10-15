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
  return self
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
  love.graphics.rectangle("fill", self.x, self.y, config.BALL_SIZE, config.BALL_SIZE)
end

return Ball
