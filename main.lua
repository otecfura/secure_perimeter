require "postshader"
require "light"

function love.load()
	player = {
		image = {},
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight()/2,
		angle = 90,
		dead = false
	}
createShader()
	lightWorld = love.light.newWorld()
    --lightWorld.setAmbientColor(60, 0, 0) -- optional

    -- create light (x, y, red, green, blue, range)
    lightMouse = lightWorld.newLight(0, 0, 255, 255, 255, 300)
    lightMouse.setGlowStrength(0.1) -- optional

	MOVE = { up=false, down=false, left=false, right=false }

	player.image = love.graphics.newImage("images/hand.png")


	boo=false
	delta=0
	FLICK=0.5
end

function createShader()
	noisetex = love.image.newImageData(100,100)
	noisetex:mapPixel(function()
		local l = love.math.random() * 255
		return l,l,l,l
	end)
	noisetex = love.graphics.newImage(noisetex)
	shader = love.graphics.newShader[[
		extern number opacity;
		extern number grainsize;
		extern number noise;
		extern Image noisetex;
		extern vec2 tex_ratio;
		float rand(vec2 co)
		{
			return Texel(noisetex, mod(co * tex_ratio / vec2(grainsize), vec2(1.0))).r;
		}
		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
		{
			return color * Texel(texture, tc) * mix(1.0, rand(tc+vec2(noise)), opacity);
		}
	]]
	shader:send("opacity",.3)
	shader:send("grainsize",1)

	shader:send("noise",3)
	shader:send("noisetex", noisetex)
	shader:send("tex_ratio", {love.graphics.getWidth() / noisetex:getWidth(), love.graphics.getHeight() / noisetex:getHeight()})
	flick_rand()
end

function love.draw()
	lightWorld.update()

	if boo then
		love.graphics.setShader(shader)
	end


	love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		updateMove(MOVE)
	computeAngle()
		    love.graphics.draw(player.image, player.x, player.y,player.angle,1/2,1/2,player.image:getHeight(),player.image:getWidth()/2)
    lightWorld.drawShadow()
    	print_FPS()
    if boo then
		    love.graphics.setShader()
		    flick_rand()
	end

	lightWorld.drawShine()
end

function flick_rand()
	FLICK=math.random();
end

function print_FPS()
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 0, 0)
end

function love.keypressed(key)
    if key == "up" then
        MOVE.up=true
    elseif key == "down" then
		MOVE.down=true
    elseif key == "left" then
        MOVE.left=true
    elseif key == "right" then
        MOVE.right=true
    end
end

function love.keyreleased(key)
    if key == "up" then
        MOVE.up=false
    elseif key == "down" then
		MOVE.down=false
    elseif key == "left" then
        MOVE.left=false
    elseif key == "right" then
        MOVE.right=false
    end
end

function computeAngle()
	local xMouse,yMouse=love.mouse.getPosition()
	local dx = player.x - xMouse
	local dy = player.y - yMouse
	player.angle = math.atan2(dy,dx)
end

function updateMove(key)
    if key.up  then
        player.y = player.y - 1
    end
    if key.down then
        player.y = player.y + 1
    end
    if key.left then
        player.x = player.x - 1
    end
    if key.right then
        player.x = player.x + 1
    end
end

function love.update(dt)
	cone=0.4
	lightMouse.setPosition(player.x, player.y)
	lightMouse.setAngle(cone)
	lightMouse.setDirection(math.pi/2-player.angle)
	if delta>FLICK then
		boo=true
		delta=0
	else
		delta = delta+dt
		boo=false
	end
end
