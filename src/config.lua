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

return config
