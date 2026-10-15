-- Partida em andamento. ESC pausa; sair pela pausa abandona sem registrar.

local config = require("src.config")
local ui = require("src.ui")
local scene = require("src.scene")
local game = require("src.game")
local settings = require("src.settings")
local records = require("src.records")
local backgrounds = require("src.backgrounds")

local play = {}

local END_DELAY = 1.2 -- segundos mostrando o ultimo ponto antes do fim

local params = nil
local paused = false
local paused_sources = nil
local pause_buttons = nil
local end_timer = 0

local function resume()
  paused = false
  if paused_sources then
    love.audio.play(paused_sources)
    paused_sources = nil
  end
end

local function pause()
  paused = true
  paused_sources = love.audio.pause()
  pause_buttons.focus = 1
end

function play.enter(p)
  params = p
  paused = false
  paused_sources = nil
  end_timer = 0
  game.start({ names = p.names, target = p.target })

  local w, h = 380, 60
  local x = (config.WINDOW_W - w) / 2
  pause_buttons = ui.button_list({
    ui.button("CONTINUAR", x, 360, w, h, resume),
    ui.button("SAIR PARA O MENU", x, 440, w, h, function() scene.switch("menu") end),
  })
end

function play.leave()
  game.stop()
  paused_sources = nil
end

local function finish()
  local s1, s2 = game.score.player1, game.score.player2
  records.add(params.names[1], params.names[2], s1, s2, params.target)
  scene.switch("gameover", {
    names = params.names,
    target = params.target,
    score = { s1, s2 },
    winner = game.winner == game.players[1] and 1 or 2,
  })
end

function play.update(dt)
  if paused then
    return
  end
  game.update(dt)
  if game.winner then
    end_timer = end_timer + dt
    if end_timer >= END_DELAY then
      finish()
    end
  end
end

function play.keypressed(key)
  if paused then
    if key == "escape" then
      resume()
    else
      pause_buttons:keypressed(key)
    end
    return
  end
  if key == "escape" and not game.winner then
    pause()
  else
    game.keypressed(key)
  end
end

function play.mousemoved(x, y)
  if paused then
    pause_buttons:mousemoved(x, y)
  end
end

function play.mousepressed(x, y, button)
  if paused then
    pause_buttons:mousepressed(x, y, button)
  end
end

function play.draw()
  backgrounds.draw(settings.background, config.GAME_BG_DIM)
  game.draw()

  if game.winner then
    ui.text_center(game.winner.name .. " VENCEU!", config.WINDOW_H / 2 - 30, 48, ui.colors.yellow)
  elseif game.state ~= "jogando" then
    ui.text_center("ESPAÇO SACA   ESC PAUSA", config.WINDOW_H - 40, 16, ui.colors.muted)
  end

  if paused then
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, config.WINDOW_W, config.WINDOW_H)
    ui.text_center("PAUSA", 260, 56, ui.colors.yellow)
    pause_buttons:draw()
    ui.text_center("Sair agora abandona a partida sem registrar o resultado", 540, 18, ui.colors.muted)
  end
end

return play
