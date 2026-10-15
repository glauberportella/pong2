-- Constantes do jogo

local config = {}

config.WINDOW_W = 1360
config.WINDOW_H = 800

config.FONT_PATH = "assets/Pong-Game.ttf"

config.SCORE_LEFT_X = config.WINDOW_W / 2 - 140
config.SCORE_LEFT_Y = 50
config.SCORE_RIGHT_X = config.WINDOW_W / 2 + 100
config.SCORE_RIGHT_Y = config.SCORE_LEFT_Y
config.SCORE_FONT_SIZE = 72
config.NAME_FONT_SIZE = 24
config.NAME_Y = 18

config.NET_DASH_COUNT = 51
config.NET_LINE_WIDTH = 3

config.BALL_SIZE = 15
config.BALL_SPEED = 1000

config.PLAYER_HEIGHT = config.BALL_SIZE * 8
config.PLAYER_THICKNESS = config.BALL_SIZE
config.PLAYER_PADDING = config.BALL_SIZE * 3
config.PLAYER_START_Y = (config.WINDOW_H - config.PLAYER_HEIGHT) / 2
config.PLAYER_SPEED = config.BALL_SPEED * 0.75

-- Linhas de ponto: bola que passa delas marca ponto para o adversario
config.PLAYER1_SCORE_LINE_X = config.PLAYER_PADDING
config.PLAYER2_SCORE_LINE_X = config.WINDOW_W - config.PLAYER_PADDING

-- Power-ups
config.POWERUP_SHEET_PATH = "assets/powerups/spritesheet_24x24.png"
config.POWERUP_SHEET_COLUMNS = 5
config.POWERUP_SIZE = 24 -- tamanho de cada icone no spritesheet
config.POWERUP_SCALE = 2 -- escala do icone na tela
config.POWERUP_DURATION = 30 -- segundos que um power-up fica ativo
config.POWERUP_SPAWN_MIN = 5 -- intervalo (s) para surgir um novo power-up
config.POWERUP_SPAWN_MAX = 10
config.POWERUP_TIMER_FONT_SIZE = 220

config.SPEED_UP_MULT = 1.6
config.SPEED_DOWN_MULT = 0.5

config.WALL_COLUMNS = 2
config.WALL_ROWS = 16
config.WALL_BRICK_W = config.BALL_SIZE
config.WALL_BRICK_H = config.WINDOW_H / config.WALL_ROWS

-- Partida
config.TARGET_OPTIONS = { 5, 10, 15 } -- pontos para vencer
config.NAME_MAX_LENGTH = 12
config.GAME_BG_DIM = 0.55 -- escurecimento do fundo durante o jogo

-- Com DEBUG = true as teclas 1..9 e 0 ativam o power-up correspondente para o player 1
config.DEBUG = false

return config
