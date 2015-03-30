require 'libs.light.light'
require 'libs.light.postshader'

function love.load()
	width=love.graphics.getWidth()
	height=love.graphics.getHeight()
	cone=0.4

	player = {
		image = {},
		x = width/2,
		y = height/2,
		angle = 90,
		dead = false,
		colorPosition = 1
	}



	enemies= {
		{x=player.x+10,y=player.y+10, angle=0}
	}

	light = {{255,255,255},{255,0,0},{0,255,0},{0,0,255}}


	createShader()

	lightWorld = love.light.newWorld()
    lightMouse = lightWorld.newLight(0, 0, 255, 255, 255, 300)
    setColorOfLight()
    lightMouse.setGlowStrength(0.1) -- optional

	MOVE = { up=false, down=false, left=false, right=false }

	player.image = love.graphics.newImage("images/hand.png")
	enemyImage = love.graphics.newImage("images/spider.png")


	boo=false
	delta=0
	flick_rand()
end

function setColorOfLight()
	lightMouse.setColor(light[player.colorPosition][1],light[player.colorPosition][2],light[player.colorPosition][3])
end

function createShader()
	noisetex = love.image.newImageData(100,100)
	noisetex:mapPixel(function()
		local l = love.math.random() * 255
		return l,l,l,l
	end)
	noisetex = love.graphics.newImage(noisetex)
	shader = love.graphics.newShader("shaders/grain.glsl")
	shader:send("opacity",.9)
	shader:send("grainsize",10)

	shader:send("noise",10)
	shader:send("noisetex", noisetex)
	shader:send("tex_ratio", {width / noisetex:getWidth(), height/ noisetex:getHeight()})
end

function love.draw()
	lightWorld.update()

	if boo then
		love.graphics.setShader(shader)
	end


	love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, width, height)


	love.graphics.draw(player.image, player.x, player.y,player.angle,1/5,1/5,player.image:getHeight(),player.image:getWidth()/2)

	for index,value in ipairs(enemies) do
		love.graphics.draw(enemyImage, value.x, value.y,enemies[index].angle,1/5,1/5,enemyImage:getHeight(),enemyImage:getWidth()/2)
	end

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
	if key== "f" then
    	player.light = not player.light
    end
end

function love.mousepressed( x, y, button )
	if button == "wu" then
		if player.colorPosition < table.getn(light) then
			player.colorPosition=player.colorPosition+1
    		setColorOfLight()
    	end
  	elseif button == "wd" then
  		if player.colorPosition > 1 then
    		player.colorPosition=player.colorPosition-1
    		setColorOfLight()
    	end
    end
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

function computeAngleEnemies()
for index,value in ipairs(enemies) do
	local dx = enemies[index].x - player.x
	local dy = enemies[index].y - player.y
	enemies[index].angle = math.atan2(dy,dx)
end
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
    	if player.x>0 then
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
	updateMove(MOVE)
	computeAngle()
	computeAngleEnemies()
	lightMouse.setPosition(player.x, player.y)
	lightMouse.setAngle(cone)
	lightMouse.setRange(100)
	lightMouse.setDirection(math.pi/2-player.angle)
	if delta>FLICK then
		boo=true
		delta=0
	else
		delta = delta+dt
		boo=false
	end
end
