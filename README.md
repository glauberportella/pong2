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

Se o `love` não estiver no PATH (instalação padrão no macOS):

```sh
/Applications/love.app/Contents/MacOS/love .
```

## Telas

- **Início**: escolha o fundo da quadra (setas esquerda/direita ou clique nas setas) e use os botões Iniciar, Recordes, Créditos e Sair. Mouse e teclado funcionam em todas as telas.
- **Nova partida**: digite o nome dos dois jogadores e escolha quantos pontos vencem a partida (5, 10 ou 15). Os últimos nomes e opções ficam salvos.
- **Partida**: `Esc` pausa. Sair pela pausa abandona a partida sem registrar o resultado.
- **Fim de partida**: mostra o vencedor, o confronto entre os dois jogadores, a maior vitória e as últimas partidas da dupla.
- **Recordes**: ranking geral de vitórias e os confrontos mais recentes.

## Controles

| Ação                | Jogador 1 (esquerda) | Jogador 2 (direita) |
|---------------------|----------------------|---------------------|
| Mover para cima     | `W`                  | `O`                 |
| Mover para baixo    | `S`                  | `L`                 |
| Sacar               | `Espaço`             | `Espaço`            |
| Pausar              | `Esc`                | `Esc`               |

## Regras

- Vence quem fizer primeiro o número de pontos escolhido.
- O jogador 1 começa com a bola.
- Antes do saque, a bola acompanha a raquete de quem vai sacar. Posicione a raquete e aperte `Espaço` para lançar.
- Quando a bola passa pela linha de fundo de um jogador, o adversário marca um ponto.
- Quem sofreu o ponto fica com o próximo saque.
- O placar de cada jogador aparece no topo da tela, de cada lado da rede.

## Power-ups

De tempos em tempos um power-up aparece na quadra. Quando a bola passa por ele, o power-up é ativado a favor de quem sacou ou rebateu por último. Cada power-up fica ativo por 30 segundos, com um contador translúcido no centro da tela. Só um power-up fica ativo por vez; o próximo aparece alguns segundos depois que o anterior acaba. Enquanto um power-up está ativo toca uma trilha de tensão, gerada por código e em volume baixo, que acelera nos últimos 10 segundos.

| #  | Power-up          | Efeito                                                                 |
|----|-------------------|------------------------------------------------------------------------|
| 1  | Aumentar velocidade | Sua raquete fica mais rápida                                         |
| 2  | Diminuir velocidade | A raquete do oponente fica mais lenta                                |
| 3  | Invisibilidade    | O oponente fica translúcido e não consegue rebater                     |
| 4  | Altura total      | Sua raquete cobre toda a altura da tela                                |
| 5  | Bola de fogo      | O oponente rebate a bola em chamas e fica queimado, sem rebater mais   |
| 6  | Bola de gelo      | O oponente rebate a bola de gelo e fica paralisado (mas ainda rebate)  |
| 7  | Bola piscando     | A bola pisca                                                           |
| 8  | Neblina           | Neblina cobre a quadra inteira                                         |
| 9  | Inverter controle | Para cima e para baixo do oponente ficam trocados                      |
| 10 | Muralha           | Uma muralha no centro protege você; o oponente quebra um tijolo a cada batida até abrir passagem |

Para testar, ative `config.DEBUG = true` em `src/config.lua`: as teclas `1` a `9` e `0` ativam o power-up correspondente para o jogador 1.

## Recordes e preferências

Ficam na pasta de save do LÖVE, em `records.lua` e `settings.lua`:

- macOS: `~/Library/Application Support/LOVE/pong2/`
- Windows: `%APPDATA%\LOVE\pong2\`
- Linux: `~/.local/share/love/pong2/`

Para zerar os recordes basta apagar `records.lua`.

## Estrutura do projeto

```
pong2/
  conf.lua              # Configuracao da janela
  main.lua              # Callbacks do LOVE, delega para a cena atual
  src/
    config.lua          # Constantes do jogo
    scene.lua           # Troca de telas
    scenes/             # Telas: menu, setup, play, gameover, records, credits
    ui.lua              # Botoes, paineis e textos
    backgrounds.lua     # Planos de fundo
    records.lua         # Recordes das partidas
    settings.lua        # Preferencias salvas
    save.lua            # Leitura e escrita dos saves
    music.lua           # Trilha de tensao dos power-ups
    game.lua            # Estado e regras da partida
    player.lua          # Raquete
    ball.lua            # Bola
    court.lua           # Rede e placar
    collision.lua       # Colisao entre retangulos
    sound.lua           # Beeps
    powerups/
      init.lua          # Surgimento, ativacao e contador dos power-ups
      effects.lua       # Os 10 power-ups
      wall.lua          # Muralha
      fog.lua           # Neblina
  assets/
    Pong-Game.ttf       # Fonte usada no placar
    bg/                 # Tela inicial e planos de fundo
    powerups/           # Icones dos power-ups (spritesheet 24x24)
```

## Configuração

As principais constantes ficam em `src/config.lua` e podem ser ajustadas:

| Constante          | Padrão | Descrição                         |
|--------------------|--------|-----------------------------------|
| `WINDOW_W`         | 1360   | Largura da janela                 |
| `WINDOW_H`         | 800    | Altura da janela                  |
| `BALL_SIZE`        | 15     | Tamanho da bola em pixels         |
| `BALL_SPEED`       | 1000   | Velocidade da bola (pixels/s)     |
| `PLAYER_HEIGHT`    | 120    | Altura das raquetes               |
| `PLAYER_SPEED`     | 750    | Velocidade das raquetes (pixels/s)|
| `SCORE_FONT_SIZE`  | 72     | Tamanho da fonte do placar        |
| `POWERUP_DURATION` | 30     | Duração de um power-up (s)        |
| `POWERUP_SPAWN_MIN`/`MAX` | 5 / 10 | Intervalo para surgir um novo power-up (s) |
