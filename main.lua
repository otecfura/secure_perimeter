function love.load()
	player = {
		image = {},
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight()/2,
		angle = 90,
		dead = false
	}

	MOVE = { up=false, down=false, left=false, right=false }

	player.image = love.graphics.newImage("images/ass.jpeg")

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
	boo=false
	delta=0
end

function love.draw()
	if boo then
		love.graphics.setShader(shader)
	end

	updateMove(MOVE)
	computeAngle()
    love.graphics.draw(player.image, player.x, player.y,player.angle,1,1,player.image:getHeight()/2,player.image:getWidth()/2)
    love.graphics.print(delta, 0, 0)
    if boo then
		    love.graphics.setShader()
	end
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
	if delta>1 then
		boo=true
		delta=0
	else
		delta = delta+dt
		boo=false
	end
end
