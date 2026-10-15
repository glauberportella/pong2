-- Beeps gerados por onda quadrada

local sound = {}

function sound.square_wave(tone, rate, length)
  length = length or 1/32
  local p = math.floor(rate / tone) -- comprimento da onda em samples
  local sound_data = love.sound.newSoundData(math.floor(length * rate), rate, 16, 1)
  for i = 0, sound_data:getSampleCount() - 1 do
    -- primeira metade da onda 1 e segunda metade -1
    sound_data:setSample(i, i % p < p / 2 and 1 or -1)
  end
  return love.audio.newSource(sound_data)
end

function sound.beep(source)
  if source then
    source:play()
  end
end

return sound
