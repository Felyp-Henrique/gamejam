local Scene = require('core.scenes.scene')
local ImageAsset = require('core.assets.image')
local LoveUtils = require('core.utils.love')
local KeysEvent = require('core.events.keys')
local FogAnimation = require('core.animations.fog')
local MouseEvent = require('core.events.mouse')
local AudioAsset = require('core.assets.audio')
local StatusComponent = require('scenes.ui.status')
local HeroObject = require('scenes.objects.hero')
local ProjectileObject = require('scenes.objects.projectile')

local CavernasScene = Scene:new {
    alias = 'cavernas',
}

function CavernasScene:new(obj)
    self.__index = self
    return setmetatable(obj or {}, self)
end

function CavernasScene:load()
    if not self.loaded then
        self.timer = 0

        self.projectiles = {}

        self.world = love.physics.newWorld(0, 0)

        self.hero = HeroObject:new {
            x = love.physics.getMeter(),--LoveUtils.getCenterX() / love.physics.getMeter(),
            y = love.physics.getMeter(),--LoveUtils.getCenterY() / love.physics.getMeter(),
            world = self.world,
        }
        self.hero:load()

        self.chao = ImageAsset:new {
            path = 'assets/tiles/caves/floor.png',
        }
        self.chao:load()
        self.chao.x = 0
        self.chao.y = 0
        self.chao.r = 0
        self.chao.ox = 0
        self.chao.oy = 0

        self.som_gotas = AudioAsset:new {
            path = 'assets/audios/ambiente_gota.ogg',
        }
        self.som_gotas:load()

        self.som_vento = AudioAsset:new {
            path = 'assets/audios/ambiente_vento.ogg',
        }
        self.som_vento:load()

        self.mouse = MouseEvent:new()

        -- atirar pedras
        self.mouse:add(MouseEvent.left, function()
            local direcao = math.atan2(
                love.mouse.getY() - self.hero.y,
                love.mouse.getX() - self.hero.x
            )
            local projectile = ProjectileObject:new {
                x = self.hero.x,
                y = self.hero.y,
                direction = direcao,
                world = self.world,
            }
            projectile:load()
            table.insert(self.projectiles, projectile)
        end)

        self.fog = FogAnimation:new {
            asset = ImageAsset:new({ path = 'assets/pictures/fog_normal.png' }),
            interval = 5,
            duration = 60 * 2,
        }
        self.fog:load()
        self.fog:start()

        self.status = StatusComponent:new()

        self.loaded = true
    end
end

function CavernasScene:draw()
    love.graphics.clear()
    love.graphics.setBackgroundColor(255, 255, 255, 1)
    love.graphics.setColor(1, 1, 1, 1)

    self.chao:draw()
    self.fog:draw()
    self.status:draw()

    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end

    self.hero:draw()
end

function CavernasScene:update(dt)
    self.world:update(dt)

    self.timer = self.timer + dt
    if self.timer >= 5 then
        self.som_gotas:loop()
        self.timer = 0
    elseif self.timer >= 2 then
        self.som_vento:loop()
    end
    self.fog:update(dt)
    self.status.life = 100
    self.status.points = 1
    self.hero.r = math.atan2(
        love.mouse.getX() - self.hero.x,
        self.hero.y - love.mouse.getY()
    )
    self.hero:update(dt)

    for _, projectile in ipairs(self.projectiles) do
        projectile:update(dt)
    end
end


function CavernasScene:keypressed(key, scancode, isrepeat)
end

function CavernasScene:mousepressed(x, y, button)
    self.mouse:mousepressed(x, y, button)
end

return CavernasScene