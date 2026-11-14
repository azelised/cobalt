--!optimize 2

-------------------------
-- Variables
-------------------------


local animate = {}
local internal = {}

local animations = {}

-- Types
type EasingStyle = 
	"Linear" 
	|"Quad"
	|"Cubic"
	|"Quart"
	|"Quint"
	|"Sine"
	|"Exponential"
	|"Circular"
	|"Elastic"
	|"Back"
	|"Bounce"

type EasingDirection = 
	"In"
	|"InOut"
	|"Out"

export type Easing = {()->() |number|EasingStyle|EasingDirection}
export type Spring = {()->() |number}


-------------------------
-- Utility
-------------------------


local typeFormulas = require "@self/typeFormulas"
local easingFormulas = require "@self/easingFormulas"

--[=[
	Interpolation using easing methods.
	
	@private
]=]
function internal.easing(data: {any}, easing: Easing)
	local value,target,callFunctions = table.unpack(data)
	local start = value[2]
	local counter = 0
	
	repeat
		counter += task.wait()
		local time = math.clamp(easing[2] == 0 and 1 or counter/easing[2],0,1)
		local ratio = easingFormulas[easing[3]][easing[4]](time)

		value[2] = counter >= easing[2] and target or typeFormulas(start,target,ratio)
		callFunctions(value)

	until counter >= easing[2]
	animations[data] = nil
end

--[=[
	Interpolation using analytical spring mechanics.
	
	@private
]=]
function internal.spring(data: {any}, spring: Spring)
	local value, target, callFunctions = table.unpack(data)
	local start, ratio, v, stopTask = value[2], 0, 0, false

	local f = math.clamp(spring[2] :: number,0.01,100)
	local d = math.clamp(spring[3] :: number,0.01,100)

	repeat
		local dt = math.min(task.wait(), 0.05)
		
		local offset = ratio - 1
		local decay = math.exp(-d * f * dt)

		if math.abs(d - 1) < 1e-4 then
			
			-- Critically damped (d = 1)
			local fdt = f * dt
			ratio = (offset * (1 + fdt) + v * dt) * decay + 1
			v = (v * (1 - fdt) - offset * (f * f * dt)) * decay

		elseif d < 1 then
			
			-- Underdamped (d < 1)
			local c = math.sqrt(1 - d * d)
			local fc = f * c
			local i = math.cos(fc * dt)
			local j = math.sin(fc * dt)

			local z = (c > 1e-4) and (j / c) or (dt * f + (((dt * f)^2) * (c * c) / 20 - (c * c)) * ((dt * f)^3) / 6)
			local y = (fc > 1e-4) and (j / fc) or (dt + ((dt^2) * (fc * fc) / 20 - (fc * fc)) * (dt^3) / 6)

			ratio = (offset * (i + d * z) + v * y) * decay + 1
			v = (v * (i - z * d) - offset * (z * f)) * decay

		else
			
			-- Overdamped (d > 1)
			local c = math.sqrt(d * d - 1)
			local r1 = -f * (d + c) 						
			local r2 = -f * (d - c)

			local co2 = (v - offset * r1) / (2 * f * c) 	
			local co1 = offset - co2

			local e1 = co1 * math.exp(r1 * dt) 				
			local e2 = co2 * math.exp(r2 * dt)
			ratio = e1 + e2 + 1
			v = e1 * r1 + e2 * r2
		end

		stopTask = math.abs(ratio - 1) < 1e-3 and math.abs(v) < 1e-3
		value[2] = stopTask and target or typeFormulas(start, target, ratio)
		callFunctions(value)
	until stopTask
	animations[data] = nil
end

--[=[
	Starts a new animation
	
	@private
]=]
function internal.start(data: {any}, easing: Easing|Spring)
	if easing[1] == animate.easing then internal.easing(data,easing :: Easing) 
	elseif easing[1] == animate.spring then internal.spring(data,easing :: Spring)
	end
end



-------------------------
-- Interaction
-------------------------


--[=[
	Creates easing data for value animations.
	
	@param time number -- The amount of time it should take.
	@param style EasingStyle? -- How it should get to the end goal.
	@param direction EasingDirection? -- The direction of the EasingStyle.
]=]
function animate:easing(time: number, style: EasingStyle?, direction: EasingDirection?): Easing
	return {animate.easing :: any, time,style or "Linear",direction or "Out"}
end

--[=[
	Creates spring data for value animations.
	
	@param frequency number -- The angular frequency of the spring.
	@param dampingRatio EasingStyle? -- How the spring settles down.
]=]
function animate:spring(frequency: number, dampingRatio: number?): Spring
	return {animate.spring :: any,frequency,dampingRatio or 1}
end

--[=[
	Cancels the value animation thread
	
	@private
]=]
function animate.stop(value)
	if animations[value] then 
		task.cancel(animations[value]) 
		animations[value] = nil 
	end
end

--[=[
	Creates a new value animation thread
	
	@private
]=]
function animate.play(data: {any}, easing: Easing|Spring)
	animate.stop(data[1])
	animations[data[1]] = task.spawn(internal.start,data,easing)
	
	local funcs = {}
	
	--[=[
		Stops the animation at its current position.
	]=]
	function funcs:stop() 
		animate.stop(data[1]) 
	end
	
	return funcs
end

return animate