-- Estado e regras da partida

local config = require("src.config")
local collision = require("src.collision")
local sound = require("src.sound")
local court = require("src.court")
local Player = require("src.player")
local Ball = require("src.ball")

local game = {}

function game.load()
  court.load()

  game.players = {
    Player.new("player1", config.PLAYER_PADDING, { up = "w", down = "s" }, 1,
      sound.square_wave(240.0, 44100, 1/32)),
    Player.new("player2", config.WINDOW_W - config.PLAYER_PADDING - config.PLAYER_THICKNESS, { up = "o", down = "l" }, -1,
      sound.square_wave(440.0, 44100, 1/32)),
  }
  game.ball = Ball.new()
  game.score = { player1 = 0, player2 = 0 }

  -- "player1"/"player2": bola na mao de quem vai sacar; "jogando": bola em jogo
  game.state = "player1"
  -- ultimo jogador que sacou ou rebateu
  game.last_hitter = nil
end

function game.player(id)
  return id == "player1" and game.players[1] or game.players[2]
end

function game.opponent(player)
  return player == game.players[1] and game.players[2] or game.players[1]
end

-- Marca ponto para o jogador; quem sofreu o ponto saca
local function point_for(player)
  game.score[player.id] = game.score[player.id] + 1
  court.set_score(game.score)
  game.state = game.opponent(player).id
end

local function check_score()
  local ball = game.ball
  -- bola passou da linha do player 1 => ponto para o player 2
  if ball.x + config.BALL_SIZE < config.PLAYER1_SCORE_LINE_X then
    point_for(game.players[2])
  end
  -- bola passou da linha do player 2 => ponto para o player 1
  if ball.x > config.PLAYER2_SCORE_LINE_X then
    point_for(game.players[1])
  end
end

local function serve(player)
  game.ball:place_at_serve(player)
  if love.keyboard.isDown("space") then
    game.ball:bounce_from(player)
    game.last_hitter = player
    game.state = "jogando"
  end
end

local function check_paddle_hits()
  for _, player in ipairs(game.players) do
    if collision.aabb(game.ball:rect(), player:rect()) then
      sound.beep(player.beep)
      game.ball:bounce_from(player)
      game.last_hitter = player
    end
  end
end

function game.update(dt)
  if game.state == "jogando" then
    check_score()
    game.ball:update(dt)
    check_paddle_hits()
  else
    serve(game.player(game.state))
  end

  for _, player in ipairs(game.players) do
    player:update(dt)
  end
end

function game.draw()
  court.draw_score()
  court.draw_net()
  for _, player in ipairs(game.players) do
    player:draw()
  end
  game.ball:draw()
end

return game
