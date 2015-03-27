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
    lightMouse = lightWorld.newLight(0, 0, 255, 255, 255, 300)
    lightMouse.setGlowStrength(0.1) -- optional

	MOVE = { up=false, down=false, left=false, right=false }

	player.image = love.graphics.newImage("images/hand.png")


	boo=false
	delta=0
	flick_rand()
end

function createShader()
	noisetex = love.image.newImageData(100,100)
	noisetex:mapPixel(function()
		local l = love.math.random() * 255
		return l,l,l,l
	end)
	noisetex = love.graphics.newImage(noisetex)
	shader = love.graphics.newShader("shader/grain.glsl")
	shader:send("opacity",.9)
	shader:send("grainsize",10)

	shader:send("noise",10)
	shader:send("noisetex", noisetex)
	shader:send("tex_ratio", {love.graphics.getWidth() / noisetex:getWidth(), love.graphics.getHeight() / noisetex:getHeight()})
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
	keyHandle(key, true)
end

function love.keyreleased(key)
	keyHandle(key, false)
end

function keyHandle(key,boo)
	if key == "w" then
		MOVE.up=boo
    elseif key == "s" then
		MOVE.down=boo
    elseif key == "a" then
    	MOVE.left=boo
    elseif key == "d" then
    	MOVE.right=boo
    end
end

function computeAngle()
	local xMouse,yMouse=love.mouse.getPosition()
	local dx = player.x - xMouse
	local dy = player.y - yMouse
	player.angle = math.atan2(dy,dx)
end

function updateMove(key)
    if key.up then
    	if player.y>0 then
    		player.y = player.y - 1
    	end
    end
    if key.down then
    	if player.y<love.graphics.getHeight() then
        	player.y = player.y + 1
        end
    end
    if key.left then
    	if player.y>0 then
        	player.x = player.x - 1
        end
    end
    if key.right then
    	if player.x<love.graphics.getWidth() then
        	player.x = player.x + 1
    	end
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
