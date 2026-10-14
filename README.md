# Pong 2

Versão do clássico Pong feita em Lua com o framework [LÖVE](https://love2d.org/).
Dois jogadores disputam no mesmo teclado, cada um controlando uma raquete.

## Requisitos

- [LÖVE](https://love2d.org/) 11.x ou superior

No macOS, é possível instalar com Homebrew:

```sh
brew install --cask love
```

## Como jogar

Na pasta do projeto, execute:

```sh
love .
```

## Controles

| Ação                | Jogador 1 (esquerda) | Jogador 2 (direita) |
|---------------------|----------------------|---------------------|
| Mover para cima     | `W`                  | `O`                 |
| Mover para baixo    | `S`                  | `L`                 |
| Sacar               | `Espaço`             | `Espaço`            |

## Regras

- O jogador 1 começa com a bola.
- Antes do saque, a bola acompanha a raquete de quem vai sacar. Posicione a raquete e aperte `Espaço` para lançar.
- Quando a bola passa pela linha de fundo de um jogador, o adversário marca um ponto.
- Quem sofreu o ponto fica com o próximo saque.
- O placar de cada jogador aparece no topo da tela, de cada lado da rede.

## Estrutura do projeto

```
pong2/
├── main.lua              # Código do jogo (configuração, lógica e desenho)
└── assets/
    └── Pong-Game.ttf     # Fonte usada no placar
```

## Configuração

As principais constantes ficam no início de `main.lua` e podem ser ajustadas:

| Constante          | Padrão | Descrição                         |
|--------------------|--------|-----------------------------------|
| `WINDOW_W`         | 1360   | Largura da janela                 |
| `WINDOW_H`         | 800    | Altura da janela                  |
| `BALL_SIZE`        | 20     | Tamanho da bola em pixels         |
| `BALL_SPEED`       | 500    | Velocidade da bola (pixels/s)     |
| `PLAYER_HEIGHT`    | 140    | Altura das raquetes               |
| `PLAYER_SPEED`     | 375    | Velocidade das raquetes (pixels/s)|
| `SCORE_FONT_SIZE`  | 72     | Tamanho da fonte do placar        |
