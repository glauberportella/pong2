WINDOW_W = 1360
WINDOW_H = 800

SCORE_LEFT_X = WINDOW_W / 2 - 140
SCORE_LEFT_Y = 50
SCORE_RIGHT_X = WINDOW_W / 2 + 100
SCORE_RIGHT_Y = SCORE_LEFT_Y
SCORE_FONT_SIZE = 72

NET_DASH_COUNT = 51
NET_LINE_WIDTH = 3
DEFAULT_LINE_WITDH = 1

BALL_SIZE = 15
BALL_SPEED = 1000

PLAYER_HEIGHT = BALL_SIZE * 8
PLAYER_THICKNESS = BALL_SIZE
PLAYER_PADDING = BALL_SIZE * 3
PLAYER_START_Y = (WINDOW_H - PLAYER_HEIGHT) / 2
PLAYER_SPEED = BALL_SPEED * 0.75

-- Score

score_p1 = 0
score_p2 = 0

score_font = love.graphics.newFont("assets/Pong-Game.ttf", SCORE_FONT_SIZE)
score_p1_text = love.graphics.newText(score_font, string.format("%d", score_p1))
score_p2_text = love.graphics.newText(score_font, string.format("%d", score_p2))

-- Players

player1_x = PLAYER_PADDING
player1_y = PLAYER_START_Y
player2_x = WINDOW_W - PLAYER_PADDING - PLAYER_THICKNESS
player2_y = PLAYER_START_Y

saque = "player1"

-- Ball

ball_dx = BALL_SPEED
ball_dy = BALL_SPEED
ball_x = player1_x + BALL_SIZE
ball_y = PLAYER_START_Y - BALL_SIZE / 2 

-- Point line

PLAYER1_SCORE_LINE_X = PLAYER_PADDING
PLAYER2_SCORE_LINE_X = WINDOW_W - PLAYER_PADDING

-- Beep
function generate_sound_source(tone, rate, length)
  if not length then length = 1/32 end
  local p = math.floor(rate / tone) -- 100 (comprimento da onda em samples)
  local soundData = love.sound.newSoundData(math.floor(length * rate), rate, 16, 1)
  for i = 0, soundData:getSampleCount() - 1 do
    -- soundData:setSample(i, math.sin(2*math.pi*i/p)) -- senoide.
    soundData:setSample(i, i % p < p / 2 and 1 or -1)     -- quadrada; primeira metade da onda 1 e segunda metade -1
  end
  return love.audio.newSource(soundData)
end

p1_beep = nil
p2_beep = nil

function beep(source)
  if source then
    source:play()
  end
end

-- Draws

function draw_net()
  local segment_length = WINDOW_H / NET_DASH_COUNT

  DEFAULT_LINE_WIDTH = love.graphics.getLineWidth()
  love.graphics.setLineWidth(NET_LINE_WIDTH)

  local net_x = WINDOW_W / 2

  -- Desenha a rede
  for i = 0,NET_DASH_COUNT - 1 do
    if i % 2 == 0 then
      love.graphics.line(net_x, i * segment_length, net_x, (i + 1) * segment_length)
    end
  end

  -- Restaura line width
  love.graphics.setLineWidth(DEFAULT_LINE_WIDTH)
end

function draw_score()
  love.graphics.draw(score_p1_text, SCORE_LEFT_X, SCORE_LEFT_Y)
  love.graphics.draw(score_p2_text, SCORE_RIGHT_X, SCORE_RIGHT_Y)
end

function draw_players()
  love.graphics.rectangle("fill", player1_x, player1_y, PLAYER_THICKNESS, PLAYER_HEIGHT)
  love.graphics.rectangle("fill", player2_x, player2_y, PLAYER_THICKNESS, PLAYER_HEIGHT)
end

function draw_ball()
  love.graphics.rectangle("fill", ball_x, ball_y, BALL_SIZE, BALL_SIZE)
end

-- Colision

function colision_aabb(borda_topo_a, borda_direita_a, borda_base_a, borda_esquerda_a, borda_topo_b, borda_direita_b, borda_base_b, borda_esquerda_b)
  local interX = borda_direita_a >= borda_esquerda_b and borda_esquerda_a <= borda_direita_b
  local interY = borda_base_a >= borda_topo_b and borda_topo_a <= borda_base_b
  return interX and interY
end

function is_colision(bx, by, px, py)
  return colision_aabb(by, bx + BALL_SIZE, by + BALL_SIZE, bx, py, px + PLAYER_THICKNESS, py + PLAYER_HEIGHT, px)
end

-- Score count
-- Marca ponto para player
function update_score(player)
  if player == "player1" then
    score_p1 = score_p1 + 1
  end

  if player == "player2" then
    score_p2 = score_p2 + 1
  end

  score_p1_text:set(string.format("%d", score_p1))
  score_p2_text:set(string.format("%d", score_p2))
end

function mark_score()
  -- testa se bola passou do point line para o player 1 => ponto para o player 2
  if ball_x + BALL_SIZE < PLAYER1_SCORE_LINE_X then
    update_score("player2")
    saque = "player2"
  end
  -- testa se bola passou do point line para o player 2 => ponto para o player 1
  if ball_x > PLAYER2_SCORE_LINE_X then
    update_score("player1")
    saque = "player1"
  end
end

-- Updates

function players_update(dt)
  local player1_down = love.keyboard.isDown("s")
  local player1_up = love.keyboard.isDown("w")
  local player2_down = love.keyboard.isDown("l")
  local player2_up = love.keyboard.isDown("o")

  if player1_down then
    player1_y = player1_y + PLAYER_SPEED*dt
  end

  if player1_up then
    player1_y = player1_y - PLAYER_SPEED*dt
  end

  if player2_down then
    player2_y = player2_y + PLAYER_SPEED*dt
  end

  if player2_up then
    player2_y = player2_y - PLAYER_SPEED*dt
  end
end

function ball_update(dt)
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  
  local ball_nx = ball_x + ball_dx*dt
  if ball_nx < 0 or ball_nx + BALL_SIZE >= w then
    ball_dx = -ball_dx
  else
    ball_x = ball_nx
  end

  local ball_ny = ball_y + ball_dy*dt
  if ball_ny < 0 or ball_ny + BALL_SIZE >= h then
    ball_dy = -ball_dy
  else
    ball_y = ball_ny
  end
end

function sacar(player)
  if player == "player1" then
    ball_x = player1_x + PLAYER_THICKNESS + 1
    ball_y = player1_y + (PLAYER_HEIGHT - BALL_SIZE) / 2
    if love.keyboard.isDown("space") then
      saque = "jogando"
      if ball_dx < 0 then 
        ball_dx = -ball_dx
      end
    end
  end
  if player == "player2" then
    ball_x = player2_x - BALL_SIZE - 1
    ball_y = player2_y + (PLAYER_HEIGHT - BALL_SIZE) / 2
    if love.keyboard.isDown("space") then
      saque = "jogando"
      ball_dx = -ball_dx
      ball_dy = -ball_dy
    end
  end
end

-- Carregar valores/resources
function love.load()
  love.window.setTitle("Pong2")
  love.window.setMode(WINDOW_W, WINDOW_H)
  p1_beep = generate_sound_source(240.0, 44100, 1/32)
  p2_beep = generate_sound_source(440.0, 44100, 1/32)
end

-- Atualizar estado do jogo em cada frame
function love.update(dt)
  if saque == "player1" then
    -- bola na mao do player 1 para sacar
    sacar("player1")
  elseif saque == "player2" then
    -- bola na mao do player 2 para sacar
    sacar("player2")
  else
    -- jogando
    mark_score()
    ball_update(dt)
    -- verificar colisao nas raquetes
    if is_colision(ball_x, ball_y, player1_x, player1_y) then
      beep(p1_beep)
      if ball_dx < 0 then
        ball_dx = -ball_dx
      end
    end
    if is_colision(ball_x, ball_y, player2_x, player2_y) then
      beep(p2_beep)
      ball_dx = -ball_dx
    end
  end
  players_update(dt)
end

-- Desenhar na tela em cada frame
function love.draw()
  draw_score()
  draw_net()
  draw_players()
  draw_ball()
end
