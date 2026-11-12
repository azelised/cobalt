--!optimize 2

-------------------------
-- Lerp Number
-------------------------


local function lerpNum(a: number, b: number, t: number): number
	return a + (b - a) * t
end

-------------------------
-- Lerp Vector2
-------------------------


local function LerpVector2(a, b, dt)
	local ax, ay = lerpNum(a.x, b.x, dt), lerpNum(a.y, b.y, dt)
	return Vector2.new(ax, ay)
end

-------------------------
-- Lerp Color3
-------------------------


local function LerpColor3(a, b, dt)
	local ar, ag, ab = lerpNum(a.r, b.r, dt), lerpNum(a.g, b.g, dt), lerpNum(a.b, b.b, dt)
	return Color3.new(ar, ag, ab)
end

-------------------------
-- Lerp Vector3
-------------------------


local function LerpVector3(a, b, dt)
	local ax, ay, az = lerpNum(a.x, b.x, dt), lerpNum(a.y, b.y, dt), lerpNum(a.z, b.z, dt)
	return Vector3.new(ax, ay, az)
end

-------------------------
-- Lerp CFrame
-------------------------


local function LerpCFrame(CFrameA: CFrame, CFrameB: CFrame, dt)
	local Ax, Ay, Az, Am11, Am12, Am13, Am21, Am22, Am23, Am31, Am32, Am33 = CFrameA:GetComponents()
	local Bx, By, Bz, Bm11, Bm12, Bm13, Bm21, Bm22, Bm23, Bm31, Bm32, Bm33 = CFrameB:GetComponents()
	
	Ax, Ay, Az = lerpNum(Ax, Bx, dt), lerpNum(Ay, By, dt), lerpNum(Az, Bz, dt)
	Am11, Am12, Am13 = lerpNum(Am11, Bm11, dt), lerpNum(Am12, Bm12, dt), lerpNum(Am13, Bm13, dt)
	Am21, Am22, Am23 = lerpNum(Am21, Bm21, dt), lerpNum(Am22, Bm22, dt), lerpNum(Am23, Bm23, dt)
	Am31, Am32, Am33 = lerpNum(Am31, Bm31, dt), lerpNum(Am32, Bm32, dt), lerpNum(Am33, Bm33, dt)

	return CFrame.new(Ax, Ay, Az, Am11, Am12, Am13, Am21, Am22, Am23, Am31, Am32, Am33)
end


-------------------------
-- Lerp UDim2
-------------------------


local function LerpUDim2(a, b, t)
	return UDim2.new(
		lerpNum(a.X.Scale, b.X.Scale, t),
		lerpNum(a.X.Offset, b.X.Offset, t),
		lerpNum(a.Y.Scale, b.Y.Scale, t),
		lerpNum(a.Y.Offset, b.Y.Offset, t)
	)
end


-------------------------
-- Interaction
-------------------------


return function(a, b, t)
	local type = typeof(a)
	if 		type == "CFrame" 	then return LerpCFrame(a, b, t)
	elseif 	type == "number" 	then return lerpNum(a, b, t)
	elseif 	type == "Color3" 	then return LerpColor3(a, b, t)
	elseif 	type == "Vector2" 	then return LerpVector2(a, b, t)
	elseif 	type == "Vector3" 	then return LerpVector3(a, b, t)
	elseif 	type == "UDim2" 	then return LerpUDim2(a, b, t)
	elseif 	type == "boolean" 	then return t < 0.5 and a or b
	end
	error(type.." type is not animatable")
end
