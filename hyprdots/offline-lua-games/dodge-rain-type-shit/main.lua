-- main.lua
-- Pixel Panic: Rain Dodge - Procedural graphics with falling soccer balls

-- Game states
local state = "menu"

-- Virtual resolution
local VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 1920, 1080

-- Player, enemies, puddles, soccer balls
local player, enemies, puddles, soccerBalls, spawnTimer, soccerSpawnTimer
local score, bestScore, health

-- Menu
local menuOptions = {"Start Game", "Exit"}
local selectedOption = 1

-- Gameplay settings
local playerSpeed = 800
local rainSpawnInterval = 0.1
local rainSpeedMin, rainSpeedMax = 500, 900
local bigRainChance = 0.03
local hitboxShrink = 0.75
local puddleDamageTimer = 0

-- Soccer ball settings
local soccerSpawnInterval = 10

-- Fonts
local fontTitle, fontMenu, fontScore

-- Scaling
local scaleX, scaleY

-- Load
function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Pixel Panic: Rain Dodge")
    love.window.setMode(1280,720)

    -- Fonts
    fontTitle = love.graphics.newFont(96)
    fontMenu  = love.graphics.newFont(48)
    fontScore = love.graphics.newFont(36)
    love.graphics.setFont(fontMenu)

    -- Player
    player = { x = VIRTUAL_WIDTH/2 - 25, y = VIRTUAL_HEIGHT - 90, w = 50, h = 30 }

    enemies = {}
    puddles = {}
    soccerBalls = {}
    spawnTimer = 0
    soccerSpawnTimer = 0
    score = 0
    health = 6

    -- Best score
    if love.filesystem.getInfo("bestscore.txt") then
        bestScore = tonumber(love.filesystem.read("bestscore.txt")) or 0
    else
        bestScore = 0
    end

    updateScale()
end

function updateScale()
    local w,h = love.graphics.getDimensions()
    scaleX, scaleY = w / VIRTUAL_WIDTH, h / VIRTUAL_HEIGHT
end

function love.resize(w,h) updateScale() end

-- Update
function love.update(dt)
    if state ~= "play" then return end

    -- Player movement
    if love.keyboard.isDown("a") then player.x = player.x - playerSpeed*dt end
    if love.keyboard.isDown("d") then player.x = player.x + playerSpeed*dt end
    player.x = math.max(0, math.min(VIRTUAL_WIDTH - player.w, player.x))

    -- Spawn rain
    spawnTimer = spawnTimer + dt
    if spawnTimer > rainSpawnInterval then
        spawnTimer = 0
        local isBig = math.random() < bigRainChance
        local w,h,dy = 20, 40, rainSpeedMin + math.random()*(rainSpeedMax-rainSpeedMin)
        local damage = 2
        if isBig then
            w,h,dy = 80,80, rainSpeedMin + math.random()*200
            damage = math.random(3,4)
        end
        table.insert(enemies,{
            x = math.random(0, VIRTUAL_WIDTH - w),
            y = 0,
            w = w, h = h,
            dy = dy,
            big = isBig,
            damage = damage
        })
    end

    -- Move enemies
    for i=#enemies,1,-1 do
        local e = enemies[i]
        e.y = e.y + e.dy*dt

        local ph = player.h*hitboxShrink
        local pw = player.w*hitboxShrink
        local px = player.x + (player.w-pw)/2
        local py = player.y + (player.h-ph)/2

        local eh = e.h*hitboxShrink
        local ew = e.w*hitboxShrink
        local ex = e.x + (e.w-ew)/2
        local ey = e.y + (e.h-eh)/2

        if ex < px+pw and ex+ew > px and ey < py+ph and ey+eh > py then
            health = health - e.damage
            table.remove(enemies,i)
            if health <= 0 then gameOver() end
        elseif e.big and e.y + e.h >= VIRTUAL_HEIGHT - 60 then
            table.insert(puddles,{
                x = e.x, y = VIRTUAL_HEIGHT - 60, w = e.w, h = 20, timer = 3
            })
            table.remove(enemies,i)
        elseif e.y > VIRTUAL_HEIGHT then
            table.remove(enemies,i)
        end
    end

    -- Puddles
    puddleDamageTimer = puddleDamageTimer + dt
    for i=#puddles,1,-1 do
        local p = puddles[i]
        p.timer = p.timer - dt
        if p.timer <= 0 then table.remove(puddles,i) end
        if puddleDamageTimer >= 2 then
            local px = player.x + player.w*(1-hitboxShrink)/2
            local py = player.y + player.h*(1-hitboxShrink)/2
            local pw = player.w*hitboxShrink
            local ph = player.h*hitboxShrink
            if px < p.x+p.w and px+pw > p.x and py+ph > p.y then
                health = health - 1
                if health <= 0 then gameOver() end
            end
        end
    end
    if puddleDamageTimer >= 2 then puddleDamageTimer = 0 end

    score = score + dt

    -- Soccer ball spawning
    soccerSpawnTimer = soccerSpawnTimer + dt
    if soccerSpawnTimer > soccerSpawnInterval then
        soccerSpawnTimer = 0
        local direction = math.random(2) == 1 and "left" or "right"
        local speed = 600 + math.random()*200
        table.insert(soccerBalls,{
            x = direction=="left" and 0 or VIRTUAL_WIDTH-50,
            y = -50,
            w = 50, h = 50,
            dx = direction=="left" and speed or -speed,
            vy = 600,
            landingY = VIRTUAL_HEIGHT - 60 - 50,
            damage = 4,
            landed = false,
            hit = false -- NEW: only damage once
        })
    end

    -- Move soccer balls
    for i=#soccerBalls,1,-1 do
        local b = soccerBalls[i]

        -- vertical movement until landing
        if not b.landed then
            b.y = b.y + b.vy*dt
            if b.y >= b.landingY then
                b.y = b.landingY
                b.landed = true
            end
        end

        -- horizontal movement
        b.x = b.x + b.dx*dt

        -- hitbox check
        local ph = player.h*hitboxShrink
        local pw = player.w*hitboxShrink
        local px = player.x + (player.w-pw)/2
        local py = player.y + (player.h-ph)/2

        local bh = b.h*hitboxShrink
        local bw = b.w*hitboxShrink
        local bx = b.x + (b.w-bw)/2
        local by = b.y + (b.h-bh)/2

        if bx < px+pw and bx+bw > px and by < py+ph and by+bh > py then
            if not b.hit then
                health = health - b.damage
                b.hit = true
                if health <= 0 then gameOver() end
            end
        end

        if b.x + b.w < 0 or b.x > VIRTUAL_WIDTH then
            table.remove(soccerBalls,i)
        end
    end
end

-- Draw
function love.draw()
    love.graphics.push()
    love.graphics.scale(scaleX, scaleY)

    if state == "menu" then
        love.graphics.setBackgroundColor(0.1,0.1,0.15)
        love.graphics.setFont(fontTitle)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Pixel Panic", 0, 150, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(fontMenu)
        love.graphics.printf("Rain Dodge", 0, 250, VIRTUAL_WIDTH, "center")

        for i, option in ipairs(menuOptions) do
            local y = 400 + i*80
            local textWidth = fontMenu:getWidth(option)
            local textHeight = fontMenu:getHeight()
            local paddingX, paddingY = 20,10
            if i == selectedOption then
                love.graphics.setColor(1,0.8,0)
                love.graphics.rectangle("fill", VIRTUAL_WIDTH/2 - textWidth/2 - paddingX,
                    y - paddingY, textWidth + paddingX*2, textHeight + paddingY*2)
                love.graphics.setColor(0,0,0)
            else
                love.graphics.setColor(1,1,1)
            end
            love.graphics.printf(option, 0, y, VIRTUAL_WIDTH, "center")
        end

        love.graphics.setColor(1,1,1)
        love.graphics.setFont(fontScore)
        love.graphics.printf("Best Score: "..math.floor(bestScore),0,700,VIRTUAL_WIDTH,"center")

    elseif state == "play" then
        -- Background gradient
        for y=0,VIRTUAL_HEIGHT do
            love.graphics.setColor(0.2,0.6 - y/VIRTUAL_HEIGHT*0.2, 0.2)
            love.graphics.line(0,y,VIRTUAL_WIDTH,y)
        end

        -- Ground
        love.graphics.setColor(0.1,0.4,0.1)
        love.graphics.rectangle("fill",0,VIRTUAL_HEIGHT-60,VIRTUAL_WIDTH,60)

        -- Player
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("fill",player.x,player.y,player.w,player.h,10,10)
        love.graphics.setColor(0,0.5,0)
        love.graphics.rectangle("line",player.x,player.y,player.w,player.h,10,10)

        -- Rain
        for _, e in ipairs(enemies) do
            if e.big then love.graphics.setColor(0.6,0,0.8,0.9)
            else love.graphics.setColor(0.4,0,0.5,0.8) end
            love.graphics.rectangle("fill", e.x, e.y, e.w, e.h)
        end

        -- Puddles
        for _, p in ipairs(puddles) do
            love.graphics.setColor(0.2,0,0.4,0.6)
            love.graphics.rectangle("fill",p.x,p.y,p.w,p.h)
        end

        -- Soccer balls + landing indicator
        for _, b in ipairs(soccerBalls) do
            if not b.landed then
                love.graphics.setColor(1,1,0,0.5)
                love.graphics.rectangle("fill",b.x,b.landingY,b.w,5)
            end
            love.graphics.setColor(0.9,0.9,0.9)
            love.graphics.circle("fill", b.x + b.w/2, b.y + b.h/2, b.w/2)
            love.graphics.setColor(0.7,0.7,0.7)
            love.graphics.circle("line", b.x + b.w/2, b.y + b.h/2, b.w/2)
        end

        -- Score + shadow
        love.graphics.setFont(fontScore)
        love.graphics.setColor(0,0,0,0.4)
        love.graphics.print("Score: "..math.floor(score),52,52)
        love.graphics.print("Best: "..math.floor(bestScore),52,102)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Score: "..math.floor(score),50,50)
        love.graphics.print("Best: "..math.floor(bestScore),50,100)

        -- Hearts
        for i=1,6 do
            if i <= health then love.graphics.setColor(1,0,0)
            else love.graphics.setColor(0.4,0,0) end
            love.graphics.polygon("fill",
                50 + i*50 + 10,150,
                50 + i*50 + 30,150,
                50 + i*50 + 40,165,
                50 + i*50 + 20,190,
                50 + i*50,165
            )
        end

    elseif state == "gameover" then
        love.graphics.setBackgroundColor(0.15,0.05,0.15)
        love.graphics.setFont(fontTitle)
        love.graphics.setColor(1,0.5,0.5)
        love.graphics.printf("Game Over!",0,400,VIRTUAL_WIDTH,"center")
        love.graphics.setFont(fontScore)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Score: "..math.floor(score),0,520,VIRTUAL_WIDTH,"center")
        love.graphics.printf("Best: "..math.floor(bestScore),0,600,VIRTUAL_WIDTH,"center")
        love.graphics.printf("Press Enter to return to Menu",0,700,VIRTUAL_WIDTH,"center")
    end

    love.graphics.pop()
end

-- Key pressed
function love.keypressed(key)
    if state=="menu" then
        if key=="up" then selectedOption = selectedOption-1
            if selectedOption<1 then selectedOption=#menuOptions end
        elseif key=="down" then selectedOption = selectedOption+1
            if selectedOption>#menuOptions then selectedOption=1 end
        elseif key=="return" then
            if menuOptions[selectedOption]=="Start Game" then startGame()
            else love.event.quit() end
        end
    elseif state=="gameover" then
        if key=="return" then state="menu" end
    end
end

-- Start game
function startGame()
    state="play"
    enemies={}
    puddles={}
    soccerBalls={}
    spawnTimer=0
    soccerSpawnTimer=0
    score=0
    health=6
    player.x,player.y=VIRTUAL_WIDTH/2-player.w/2,VIRTUAL_HEIGHT-60-player.h
end

-- Game over
function gameOver()
    if score>bestScore then
        bestScore=score
        love.filesystem.write("bestscore.txt", tostring(bestScore))
    end
    state="gameover"
end
