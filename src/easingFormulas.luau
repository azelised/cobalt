--!optimize 2

local easing = {}


-------------------------
-- Linear
-------------------------


easing.Linear = {}

function easing.Linear.In(x)
	return x
end

function easing.Linear.Out(x)
	return x
end

function easing.Linear.InOut(x)
	return x
end


-------------------------
-- Sine
-------------------------


easing.Sine = {}

function easing.Sine.In(x)
	return 1 - math.cos((x * math.pi) / 2)
end

function easing.Sine.Out(x)
	return math.sin((x * math.pi) / 2)
end

function easing.Sine.InOut(x)
	return -(math.cos(math.pi * x) - 1) / 2
end


-------------------------
-- Quad
-------------------------


easing.Quad = {}

function easing.Quad.In(x)
	return x^2
end

function easing.Quad.Out(x)
	return 1 - (1 - x) * (1 - x)
end

function easing.Quad.InOut(x)
	if x < 0.5 then
		return 2*(x^2)
	else
		return 1 - math.pow(-2 * x + 2, 2) / 2
	end
end


-------------------------
-- Cubic
-------------------------


easing.Cubic = {}

function easing.Cubic.In(x)
	return x^3
end

function easing.Cubic.Out(x)
	return 1 - math.pow(1 - x, 3)
end

function easing.Cubic.InOut(x)
	if x < 0.5 then
		return 4*(x^3)
	else
		return 1 - math.pow(-2 * x + 2, 3) / 2
	end
end


-------------------------
-- Quart
-------------------------


easing.Quart = {}

function easing.Quart.In(x)
	return x^4
end

function easing.Quart.Out(x)
	return 1 - math.pow(1 - x, 4)
end

function easing.Quart.InOut(x)
	if x < 0.5 then
		return 8*(x^4)
	else
		return 1 - math.pow(-2 * x + 2, 4) / 2
	end
end


-------------------------
-- Quint
-------------------------


easing.Quint = {}

function easing.Quint.In(x)
	return x^5
end

function easing.Quint.Out(x)
	return 1 - math.pow(1 - x, 5)
end

function easing.Quint.InOut(x)
	if x < 0.5 then
		return 16*(x^5)
	else
		return 1 - math.pow(-2 * x + 2, 5) / 2
	end
end


-------------------------
-- Circular
-------------------------


easing.Circular = {}

function easing.Circular.In(x)
	return 1 - math.sqrt(1 - math.pow(x, 2))
end

function easing.Circular.Out(x)
	return math.sqrt(1 - math.pow(x - 1, 2))
end

function easing.Circular.InOut(x)
	if x < 0.5 then
		return (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2
	else
		return (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2
	end
end


-------------------------
-- Elastic
-------------------------


easing.Elastic = {}

-- Elastic
function easing.Elastic.In(x)
	local c4 = (2 * math.pi) / 3

	if x == 0 then
		return 0
	elseif x == 1 then
		return 1
	else
		return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
	end
end

function easing.Elastic.Out(x)
	local c4 = (2 * math.pi) / 3

	if x == 0 then
		return 0
	elseif x == 1 then
		return 1
	else
		return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
	end
end

function easing.Elastic.InOut(x)
	local c5 = (2 * math.pi) / 4.5;

	if x == 0 then
		return 0
	elseif x == 1 then
		return 1
	elseif x < 0.5 then
		return -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2
	else
		return (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
	end
end


-------------------------
-- Exponential
-------------------------


easing.Exponential = {}

function easing.Exponential.In(x)
	if x == 0 then
		return 0
	else
		return math.pow(2, 10 * x - 10)
	end
end

function easing.Exponential.Out(x)
	if x == 1 then
		return 1
	else
		return 1 - math.pow(2, -10 * x)
	end
end

function easing.Exponential.InOut(x)
	if x == 0 then
		return 0
	elseif x == 1 then
		return 1
	else
		if x < 0.5 then
			return math.pow(2, 20 * x - 10) / 2
		else
			return (2 - math.pow(2, -20 * x + 10)) / 2
		end
	end
end


-------------------------
-- Back
-------------------------


easing.Back = {}

function easing.Back.In(x)
	local c1 = 1.70158
	local c3 = c1 + 1

	return c3 * x * x * x - c1 * x * x;
end

function easing.Back.Out(x)
	local c1 = 1.70158
	local c3 = c1 + 1

	return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
end

function easing.Back.InOut(x)
	local c1 = 1.70158
	local c2 = c1 * 1.525

	if x < 0.5 then
		return (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
	else
		return (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
	end
end


-------------------------
-- Back
-------------------------


easing.Bounce = {}

function easing.Bounce.Out(x)
	local n1 = 7.5625
	local d1 = 2.75

	if (x < 1 / d1) then
		return n1 * x * x
	elseif (x < 2 / d1) then
		x = x - (1.5 / d1)
		return n1 * x * x + 0.75
	elseif (x < 2.5 / d1) then
		x = x - (2.25 / d1)
		return n1 * x * x + 0.9375
	else
		x = x - (2.625 / d1)
		return n1 * x * x + 0.984375
	end
end

function easing.Bounce.In(x)
	return 1 - easing.Bounce.Out(1 - x)
end

function easing.Bounce.InOut(x)
	if x < 0.5 then
		return (1 - easing.Bounce.Out(1 - 2 * x)) / 2
	else
		return (1 + easing.Bounce.Out(2 * x - 1)) / 2
	end
end

return easing