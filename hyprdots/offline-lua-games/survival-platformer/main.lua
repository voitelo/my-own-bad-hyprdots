-- main.lua
local state = "menu"
local VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 1920,1080

-- Player
local player = { x=0, y=0, w=50, h=50, vx=0, vy=0, onGround=false }

-- Platforms and zombies
local platforms = {}
local zombies = {}
local platformTimer = 0
local zombieTimer = 0
local lastPlatformX = 0

-- Camera
local camX = 0

-- Score
local score = 0
local bestScore = 0

-- Menu
local menuOptions = {"Start Game","Exit"}
local selectedOption = 1

-- Settings
local playerSpeed = 700
local jumpPower = 1200
local gravity = 2500
local platformWidth, platformHeight = 200,30
local platformSpeedMin, platformSpeedMax = 100,250
local platformDisappearTime = 4
local zombieSpeedMin, zombieSpeedMax = 150,250
local platformGapMin, platformGapMax = 150,400

-- Fonts and scaling
local fontTitle, fontMenu, fontScore
local scaleX, scaleY

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Cave Run: Horizontal Chase")
    love.window.setMode(1280,720)

    fontTitle = love.graphics.newFont(96)
    fontMenu  = love.graphics.newFont(48)
    fontScore = love.graphics.newFont(36)
    love.graphics.setFont(fontMenu)

    player.x, player.y = VIRTUAL_WIDTH/4, VIRTUAL_HEIGHT - 150

    lastPlatformX = player.x
    table.insert(platforms,{
        x=lastPlatformX,
        y=VIRTUAL_HEIGHT - 100,
        w=platformWidth,
        h=platformHeight,
        type="static",
        disappear=false,
        timer=0,
        speed=0
    })

    -- Load best score
    if love.filesystem.getInfo("bestscore.txt") then
        bestScore = tonumber(love.filesystem.read("bestscore.txt")) or 0
    else
        bestScore = 0
    end

    updateScale()
end

function updateScale()
    local w,h = love.graphics.getDimensions()
    scaleX, scaleY = w/VIRTUAL_WIDTH, h/VIRTUAL_HEIGHT
end

function love.resize(w,h) updateScale() end

function love.update(dt)
    if state ~= "play" then return end

    -- Player input
    player.vx = 0
    if love.keyboard.isDown("left","a") then player.vx = -playerSpeed end
    if love.keyboard.isDown("right","d") then player.vx = playerSpeed end
    if love.keyboard.isDown("up","w","space") and player.onGround then
        player.vy = -jumpPower
        player.onGround = false
    end

    -- Gravity
    player.vy = player.vy + gravity*dt
    player.x = player.x + player.vx*dt
    player.y = player.y + player.vy*dt
    player.x = math.max(0, player.x)

    -- Smooth camera
    local camTargetX = player.x - VIRTUAL_WIDTH/4
    camX = camX + (camTargetX - camX) * math.min(1,5*dt)
    if camX < 0 then camX = 0 end

    -- Platforms update
    for i=#platforms,1,-1 do
        local p = platforms[i]
        if p.type=="moving" then
            p.x = p.x + p.speed*dt
        end
        if p.disappear then
            p.timer = p.timer + dt
            if p.timer >= platformDisappearTime then table.remove(platforms,i) end
        end
    end

    -- Collision: player with platforms
    player.onGround = false
    for _,p in ipairs(platforms) do
        if player.y + player.h >= p.y and player.y + player.h <= p.y + p.h and player.x + player.w > p.x and player.x < p.x + p.w and player.vy>=0 then
            player.y = p.y - player.h
            player.vy = 0
            player.onGround = true
            if not p.disappear then p.disappear=true; p.timer=0 end
        end
    end

    if player.y > VIRTUAL_HEIGHT then gameOver() end

    -- Spawn new platforms progressively to the right
    platformTimer = platformTimer + dt
    if platformTimer > 1 then
        platformTimer = 0
        local gap = platformGapMin + math.random()*(platformGapMax-platformGapMin)
        local px = lastPlatformX + gap
        local py = VIRTUAL_HEIGHT - 100
        local type = math.random() < 0.5 and "moving" or "static"
        local speed = 0
        if type=="moving" then speed = platformSpeedMin + math.random()*(platformSpeedMax-platformSpeedMin) end
        table.insert(platforms,{x=px,y=py,w=platformWidth,h=platformHeight,type=type,disappear=false,timer=0,speed=speed})
        lastPlatformX = px
    end

    -- Spawn zombies behind player
    zombieTimer = zombieTimer + dt
    if zombieTimer > 2 then
        zombieTimer = 0
        local backPlatforms = {}
        for _,p in ipairs(platforms) do
            if p.x + p.w < player.x - 20 then
                table.insert(backPlatforms,p)
            end
        end
        if #backPlatforms>0 then
            local plat = backPlatforms[math.random(#backPlatforms)]
            local minDist, maxDist = 150, 300
            local zx = player.x - (minDist + math.random()*(maxDist-minDist))
            if zx < 0 then zx = 0 end
            local zy = plat.y - 50
            table.insert(zombies,{x=zx,y=zy,w=50,h=50,plat=plat,speed=zombieSpeedMin + math.random()*(zombieSpeedMax-zombieSpeedMin)})
        end
    end

    -- Move zombies (cannot go past player)
    for _,z in ipairs(zombies) do
        local p = z.plat
        if z.x + z.w < player.x then
            z.x = math.min(z.x + z.speed*dt, player.x - 1)
        end
        z.x = math.max(p.x, math.min(p.x+p.w - z.w, z.x))
        if z.x + z.w > player.x and z.x < player.x + player.w and z.y + z.h > player.y and z.y < player.y + player.h then
            gameOver()
        end
    end

    score = score + dt
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(scaleX,scaleY)
    love.graphics.translate(-camX,0)

    if state=="menu" then
        love.graphics.setBackgroundColor(0,0,0.05)
        love.graphics.setFont(fontTitle)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Cave Run",0,150,VIRTUAL_WIDTH,"center")
        love.graphics.setFont(fontMenu)
        love.graphics.printf("Glow Escape",0,250,VIRTUAL_WIDTH,"center")
        for i,opt in ipairs(menuOptions) do
            local y = 400 + i*80
            local w,h = fontMenu:getWidth(opt),fontMenu:getHeight()
            local padX,padY=20,10
            if i==selectedOption then
                love.graphics.setColor(1,0.8,0)
                love.graphics.rectangle("fill",VIRTUAL_WIDTH/2-w/2-padX,y-padY,w+padX*2,h+padY*2)
                love.graphics.setColor(0,0,0)
            else love.graphics.setColor(1,1,1) end
            love.graphics.printf(opt,0,y,VIRTUAL_WIDTH,"center")
        end
        love.graphics.setColor(1,1,1)
    elseif state=="play" then
        love.graphics.setBackgroundColor(0,0,0.05)
        for _,p in ipairs(platforms) do
            love.graphics.setColor(0.3,0.6,1,p.disappear and 0.3 or 0.8)
            love.graphics.rectangle("fill",p.x,p.y,p.w,p.h,10,10)
        end
        love.graphics.setColor(1,1,0.3)
        love.graphics.rectangle("fill",player.x,player.y,player.w,player.h,8,8)
        for _,z in ipairs(zombies) do
            love.graphics.setColor(0.6,0,0)
            love.graphics.rectangle("fill",z.x,z.y,z.w,z.h,8,8)
        end
    elseif state=="gameover" then
        love.graphics.setBackgroundColor(0.05,0,0)
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

    -- Draw HUD (score/best) fixed on screen
    if state=="play" then
        love.graphics.push()
        love.graphics.scale(scaleX,scaleY)
        love.graphics.setFont(fontScore)
        love.graphics.setColor(0,0,0,0.4)
        love.graphics.print("Score: "..math.floor(score),52,52)
        love.graphics.print("Best: "..math.floor(bestScore),52,102)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Score: "..math.floor(score),50,50)
        love.graphics.print("Best: "..math.floor(bestScore),50,100)
        love.graphics.pop()
    end
end

function love.keypressed(key)
    if state=="menu" then
        if key=="up" then selectedOption=selectedOption-1 if selectedOption<1 then selectedOption=#menuOptions end
        elseif key=="down" then selectedOption=selectedOption+1 if selectedOption>#menuOptions then selectedOption=1 end
        elseif key=="return" then
            if menuOptions[selectedOption]=="Start Game" then startGame() else love.event.quit() end
        end
    elseif state=="gameover" then
        if key=="return" then state="menu" end
    end
end

function startGame()
    state="play"
    player.x,player.y = VIRTUAL_WIDTH/4, VIRTUAL_HEIGHT - 150
    player.vx,player.vy = 0,0
    platforms = {}
    zombies = {}
    platformTimer = 0
    zombieTimer = 0
    score = 0
    lastPlatformX = player.x
    table.insert(platforms,{
        x=lastPlatformX,
        y=VIRTUAL_HEIGHT - 100,
        w=platformWidth,
        h=platformHeight,
        type="static",
        disappear=false,
        timer=0,
        speed=0
    })
end

function gameOver()
    if score>bestScore then
        bestScore=score
        love.filesystem.write("bestscore.txt", tostring(bestScore))
    end
    state="gameover"
end
