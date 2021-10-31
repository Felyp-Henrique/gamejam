local Dificults = require('core.match.dificults')
local Hero = require('core.match.hero')
local Enemy = require('core.match.enemy')
local EnemyFactory = require('core.match.enemyfactory')

Match = {}

function Match:new(values)
    assert(values.manager, "scene manager nao pode ser nil")
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.scene = values.manager
    self.level = values.level or 0
    self.points = values.points or 0
    self.dificult = values.dificult or Dificults.EASY
    self.hero = values.hero
    self.enemies = {}
    self.gameOverScene = values.gameOverScene or "gameover"
    self.timer = 0
    return obj
end

-- metodos principais

function Match:gameOver()
    self.scene:change(self.gameOverScene)
end

function Match:enemiesPosition()
    math.randomseed(os.time())
    local nx, ny
    local vertical = math.floor(math.random(1.5, 2.5))
    if vertical == 1 then
        nx = math.floor(math.random(0.5, 1.5)) * 800
        -- X = 0 ou 1 e y = faixa 0 até 600
        ny = math.floor(math.random(0, 600))
    else
        nx = math.floor(math.random(0, 800))
        ny = math.floor(math.random(0.5, 1.5)) * 600
    end
    return nx, ny
end

function Match:enemiesGenerator()
    for _ = 1, 10 do
        local x, y = self:enemiesPosition()
        local enemy = EnemyFactory.random(x, y)
        enemy:load()
        table.insert(self.enemies, enemy)
    end
end

-- metodos para o love

function Match:load()
    if not self.hero then
        self.hero = Hero:new { nick = 'Heroi' }
    end
    self.hero:load()
end

function Match:draw()
    self.hero:draw()

    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end

function Match:update(dt)
    self.hero:update(dt)

    self.timer = self.timer + dt
    if self.timer >= 3 then
        if #self.enemies == 0 then
            self:enemiesGenerator()
        end
        self.timer = 0
    end
end

function Match:mousepressed(x, y, button)
    self.hero:mousepressed(x, y, button)
end

return Match