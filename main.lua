function love.load()
	player = love.graphics.newImage("images/ass.jpeg")
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

	shader:send("noise",0)
	shader:send("noisetex", noisetex)
	shader:send("tex_ratio", {love.graphics.getWidth() / noisetex:getWidth(), love.graphics.getHeight() / noisetex:getHeight()})
end

function love.draw()
	love.graphics.setShader(shader)
	local x, y = love.mouse.getPosition()
    love.graphics.draw(player, x, y)
    love.graphics.setShader()
end
