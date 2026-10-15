-- Os 10 power-ups, na mesma ordem dos icones do spritesheet.
-- activate(owner, opponent, game): liga o efeito para quem pegou o power-up.
-- on_paddle_hit(hitter, owner, opponent): opcional, chamado a cada rebatida.
-- Ao terminar o tempo os efeitos sao desfeitos todos de uma vez (ver powerups/init.lua).

local config = require("src.config")
local wall = require("src.powerups.wall")
local fog = require("src.powerups.fog")

return {
  -- 1. Aumentar velocidade da raquete
  {
    id = "speed_up",
    activate = function(owner) owner.speed_mult = config.SPEED_UP_MULT end,
  },
  -- 2. Diminuir velocidade da raquete do oponente
  {
    id = "speed_down",
    activate = function(owner, opponent) opponent.speed_mult = config.SPEED_DOWN_MULT end,
  },
  -- 3. Oponente translucido, nao consegue rebater
  {
    id = "invisible",
    activate = function(owner, opponent) opponent.invisible = true end,
  },
  -- 4. Raquete cobrindo toda a altura da tela
  {
    id = "full_height",
    activate = function(owner) owner.full_height = true end,
  },
  -- 5. Bola de fogo: o oponente rebate e fica queimado, sem rebater ate o fim
  {
    id = "fire",
    activate = function(owner, opponent, game) game.ball.fire = true end,
    on_paddle_hit = function(hitter, owner, opponent)
      if hitter == opponent then opponent.burned = true end
    end,
  },
  -- 6. Bola de gelo: o oponente rebate e fica paralisado ate o fim
  {
    id = "ice",
    activate = function(owner, opponent, game) game.ball.ice = true end,
    on_paddle_hit = function(hitter, owner, opponent)
      if hitter == opponent then opponent.frozen = true end
    end,
  },
  -- 7. Bola piscando
  {
    id = "blink",
    activate = function(owner, opponent, game) game.ball.blink = true end,
  },
  -- 8. Neblina na quadra
  {
    id = "fog",
    activate = function() fog.start() end,
  },
  -- 9. Controles do oponente invertidos
  {
    id = "invert",
    activate = function(owner, opponent) opponent.inverted = true end,
  },
  -- 10. Muralha no centro protegendo quem pegou
  {
    id = "wall",
    activate = function(owner) wall.build(owner) end,
  },
}
