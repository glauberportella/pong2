-- Power-ups: surgem na quadra, sao ativados quando a bola passa por eles
-- (em favor de quem sacou/rebateu por ultimo) e ficam ativos por POWERUP_DURATION.

local config = require("src.config")
local collision = require("src.collision")
local effects = require("src.powerups.effects")
local wall = require("src.powerups.wall")
local fog = require("src.powerups.fog")

local powerups = {}

local ICON_SIZE = config.POWERUP_SIZE * config.POWERUP_SCALE

local sheet = nil
local quads = {}
local timer_font = nil

local on_field = nil -- { effect, x, y }: power-up esperando a bola
local active = nil   -- { effect, owner, opponent, time_left }
local spawn_timer = 0

local function random_spawn_time()
  return love.math.random(config.POWERUP_SPAWN_MIN, config.POWERUP_SPAWN_MAX)
end

function powerups.load()
  sheet = love.graphics.newImage(config.POWERUP_SHEET_PATH)
  sheet:setFilter("nearest", "nearest")
  for i = 1, #effects do
    local col = (i - 1) % config.POWERUP_SHEET_COLUMNS
    local row = math.floor((i - 1) / config.POWERUP_SHEET_COLUMNS)
    quads[i] = love.graphics.newQuad(col * config.POWERUP_SIZE, row * config.POWERUP_SIZE,
      config.POWERUP_SIZE, config.POWERUP_SIZE, sheet:getDimensions())
  end
  timer_font = love.graphics.newFont(config.FONT_PATH, config.POWERUP_TIMER_FONT_SIZE)
  spawn_timer = random_spawn_time()
end

-- Novo power-up em posicao aleatoria, longe das raquetes e do placar
local function spawn()
  on_field = {
    effect = love.math.random(#effects),
    x = love.math.random(config.WINDOW_W * 0.25, config.WINDOW_W * 0.75 - ICON_SIZE),
    y = love.math.random(config.SCORE_LEFT_Y + config.SCORE_FONT_SIZE + 30, config.WINDOW_H - ICON_SIZE - 30),
  }
end

function powerups.deactivate(game)
  for _, player in ipairs(game.players) do
    player:reset_effects()
  end
  game.ball:reset_effects()
  wall.clear()
  fog.stop()
  active = nil
  spawn_timer = random_spawn_time()
end

function powerups.activate(effect, owner, game)
  if active then
    powerups.deactivate(game)
  end
  local opponent = game.opponent(owner)
  active = { effect = effect, owner = owner, opponent = opponent, time_left = config.POWERUP_DURATION }
  on_field = nil
  effects[effect].activate(owner, opponent, game)
end

function powerups.on_paddle_hit(hitter)
  if active and effects[active.effect].on_paddle_hit then
    effects[active.effect].on_paddle_hit(hitter, active.owner, active.opponent)
  end
end

function powerups.update(dt, game)
  fog.update(dt)

  if active then
    active.time_left = active.time_left - dt
    if active.time_left <= 0 then
      powerups.deactivate(game)
    end
    return
  end

  if on_field then
    local icon = { x = on_field.x, y = on_field.y, w = ICON_SIZE, h = ICON_SIZE }
    if game.state == "jogando" and game.last_hitter and collision.aabb(game.ball:rect(), icon) then
      powerups.activate(on_field.effect, game.last_hitter, game)
    end
    return
  end

  spawn_timer = spawn_timer - dt
  if spawn_timer <= 0 then
    spawn()
  end
end

local function draw_icon(effect, cx, cy, scale)
  local half = config.POWERUP_SIZE * scale / 2
  love.graphics.draw(sheet, quads[effect], cx - half, cy - half, 0, scale, scale)
end

-- Icone esperando na quadra, pulsando levemente
function powerups.draw_field()
  if not on_field then
    return
  end
  local pulse = 1 + 0.08 * math.sin(love.timer.getTime() * 6)
  draw_icon(on_field.effect, on_field.x + ICON_SIZE / 2, on_field.y + ICON_SIZE / 2, config.POWERUP_SCALE * pulse)
end

-- Contador translucido no centro da tela com o icone do power-up ativo
function powerups.draw_timer()
  if not active then
    return
  end
  local text = string.format("%d", math.ceil(active.time_left))
  local text_w = timer_font:getWidth(text)
  local text_h = timer_font:getHeight()
  local cx = config.WINDOW_W / 2
  local cy = config.WINDOW_H / 2

  love.graphics.setColor(1, 1, 1, 0.25)
  love.graphics.setFont(timer_font)
  love.graphics.print(text, cx - text_w / 2, cy - text_h / 2)
  love.graphics.setColor(1, 1, 1, 0.5)
  draw_icon(active.effect, cx, cy - text_h / 2 - 20, config.POWERUP_SCALE)
  love.graphics.setColor(1, 1, 1, 1)
end

return powerups
