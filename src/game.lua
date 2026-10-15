-- Estado e regras da partida

local config = require("src.config")
local collision = require("src.collision")
local sound = require("src.sound")
local court = require("src.court")
local Player = require("src.player")
local Ball = require("src.ball")
local powerups = require("src.powerups")
local wall = require("src.powerups.wall")
local fog = require("src.powerups.fog")

local game = {}

local beeps = nil

local function load_assets()
  if beeps then
    return
  end
  court.load()
  powerups.load()
  beeps = {
    player1 = sound.square_wave(240.0, 44100, 1/32),
    player2 = sound.square_wave(440.0, 44100, 1/32),
    wall = sound.square_wave(120.0, 44100, 1/32),
  }
end

-- Comeca uma partida nova.
-- opts.names: nomes dos jogadores 1 e 2; opts.target: pontos para vencer
function game.start(opts)
  load_assets()
  opts = opts or {}

  game.names = opts.names or { "Jogador 1", "Jogador 2" }
  game.target = opts.target or 10

  game.players = {
    Player.new("player1", config.PLAYER_PADDING, { up = "w", down = "s" }, 1, beeps.player1),
    Player.new("player2", config.WINDOW_W - config.PLAYER_PADDING - config.PLAYER_THICKNESS, { up = "o", down = "l" }, -1,
      beeps.player2),
  }
  game.players[1].name = game.names[1]
  game.players[2].name = game.names[2]

  game.ball = Ball.new()
  game.score = { player1 = 0, player2 = 0 }
  court.set_score(game.score)
  court.set_names(game.names)

  -- "player1"/"player2": bola na mao de quem vai sacar; "jogando": bola em jogo
  game.state = "player1"
  -- ultimo jogador que sacou ou rebateu
  game.last_hitter = nil
  -- jogador que venceu a partida (nil enquanto em andamento)
  game.winner = nil

  powerups.reset()
end

function game.player(id)
  return id == "player1" and game.players[1] or game.players[2]
end

function game.opponent(player)
  return player == game.players[1] and game.players[2] or game.players[1]
end

-- Marca ponto para o jogador; quem fez o ponto saca
local function point_for(player)
  game.score[player.id] = game.score[player.id] + 1
  court.set_score(game.score)
  game.state = player.id
  if game.score[player.id] >= game.target then
    game.winner = player
  end
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
    if player:can_hit() and collision.aabb(game.ball:rect(), player:rect()) then
      sound.beep(player.beep)
      game.ball:bounce_from(player)
      game.last_hitter = player
      powerups.on_paddle_hit(player)
    end
  end
end

function game.update(dt)
  if game.winner then
    return
  end

  if game.state == "jogando" then
    check_score()
    game.ball:update(dt)
    check_paddle_hits()
    if wall.collide(game.ball) then
      sound.beep(beeps.wall)
    end
  else
    serve(game.player(game.state))
  end

  powerups.update(dt, game)

  for _, player in ipairs(game.players) do
    player:update(dt)
  end
end

-- Encerra efeitos e musica (fim da partida ou saida para o menu)
function game.stop()
  powerups.reset()
end

-- Teclas 1..9 e 0 ativam os power-ups 1..10 para o player 1 (so com DEBUG)
function game.keypressed(key)
  if not config.DEBUG then
    return
  end
  local n = tonumber(key)
  if n then
    powerups.activate(n == 0 and 10 or n, game.players[1], game)
  end
end

function game.draw()
  court.draw_score()
  court.draw_net()
  wall.draw()
  powerups.draw_field()
  for _, player in ipairs(game.players) do
    player:draw()
  end
  game.ball:draw()
  fog.draw()
  powerups.draw_timer()
end

return game
