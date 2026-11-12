--!optimize 2

-------------------------
-- Variables
-------------------------


local cobalt = {}
local internal = {}

-- Custom class functions
local classes = {}

-- The basic data structure
local basedata = {
	"",		-- Class
	{},		-- Props (contains Properties, Children, Connections, etc.)
}

-- The basic value structure
local basevalue = {
	nil,	-- cobalt.value
	nil,	-- The raw value itself
	{},		-- The functions observing the value
}

-- Types
type cobalt = typeof(cobalt)
type props = {
	[string|number]: any|Concept|{}
}
type classSource = "@base"|"@user"

-- Modules
local animate = require "@self/animate"

cobalt.easing = animate.easing
cobalt.spring = animate.spring


-------------------------
-- Utility
-------------------------


--[=[
	Clones the table fully, including nested tables
	
	@private
]=]
function internal.deepClone(x: {any}): {any}
	local Clone = table.clone(x)
	for y,z in x do if type(z) == "table" then Clone[y] = internal.deepClone(z) end end
	return Clone
end


-------------------------
-- Assignment
-------------------------


--[=[
	Sets the raw property value.
	
	@private
]=]
function internal.set(x: string, y: any, inst: Instance, attribute: true?)
	if attribute then inst:SetAttribute(x,y) else inst[x] = y end
end

--[=[
	Assigns a property to an instance.
	
	@private
]=]
function internal.assign(x: string, y: any, inst: Instance, attribute: true?)
	if typeof(y) == "table" and y[1] == cobalt.value then
		internal.set(x,y[2],inst,attribute)
		
		local position = #y[3]+1
		y[3][position] = function(z: any) internal.set(x,z,inst,attribute) end
		inst.Destroying:Once(function() y[3][position] = nil end)
	else
		internal.set(x,y,inst,attribute)
	end
end

--[=[
	Assigns a function to an instance's changes.
	
	@private
]=]
function internal.changed(data: {any}, inst: Instance)
	local sig = if data[4] then inst:GetAttributeChangedSignal(data[2]) else inst:GetPropertyChangedSignal(data[2])
	
	local connection
	connection = sig:Connect(function()
		if data[3](data[4] and inst:GetAttribute(data[2]) or inst[data[2]]) == cobalt.disconnect then 
			connection:Disconnect() 
			connection = nil 
		end
	end)
end

--[=[
	Assigns a function to an instance's signal.
	
	@private
]=]
function internal.signal(data: {any}, inst: Instance)
	local sig = inst[data[2]]
	
	local connection
	connection = sig:Connect(function(...)
		if data[3](...) == cobalt.disconnect then 
			connection:Disconnect() 
			connection = nil
		end
	end)
end

--[=[
	Specifies special parameter value rendering order.
	
	@private
]=]
function internal.special(renderOrder: {any}, data: {any})
	if data[1] == cobalt.attribute then 		
		renderOrder[2][data[2]] = {data[3],true}
		return
	elseif data[1] == cobalt.onChanged then 	
		table.insert(renderOrder[3], data)
		return
	elseif data[1] == cobalt.connect then 		
		table.insert(renderOrder[4], data)
		return
	elseif data[1] == cobalt.onRender then 		
		table.insert(renderOrder[5], data[2])
		return
	elseif data[1] == cobalt.params then error("Class parameters were passed, but were not used")
	end
	error(tostring(data[1]).." is not a valid special parameter")
end


-------------------------
-- Rendering
-------------------------


--[=[
	Renders the concept to instances.
	
	@private
]=]
function internal.render(data: Concept,parent: Instance?): Instance
	local inst: Instance = Instance.new(data[1])
	local renderOrder = {
		{},		-- Children
		{},		-- Properties
		{},		-- onChanged
		{},		-- Signals
		{},		-- onRender
	}
	
	for x,y in data[2] do
		if typeof(x) == "string" then
			renderOrder[2][x] = {y} 
			continue
		elseif typeof(x) == "number" then 
			
			assert(typeof(y) == "table", "Values in the array must be a table")
			if typeof(y[1]) == "string" then table.insert(renderOrder[1],y); continue
			elseif typeof(y[1]) == "function" then internal.special(renderOrder, y); continue
			end
		end
		error(tostring(y).." is incorrectly formatted")
	end
	
	for i,v in renderOrder do
		for x,y in v do
			if i == 1 then internal.render(y,inst)					-- Children
			elseif i == 2 then internal.assign(x,y[1],inst,y[2])	-- Properties
			elseif i == 3 then internal.changed(y,inst)				-- onChanged
			elseif i == 4 then internal.signal(y,inst)				-- Signals
			elseif i == 5 then task.spawn(y,inst)					-- onRender
			end
		end
		
		-- Parents after properties and children are assigned
		if i == 2 then if parent then inst.Parent = parent end end
	end
	
	return inst
end


-------------------------
-- Object
-------------------------


--[=[
	Parameters for the custom class function.
	
	@private
]=]
function internal.classParameters(props: props?)
	local Parameters = {}
	
	if props then
		for i,data in props do
			if typeof(data) == "table" and data[1] == cobalt.params then
				for x,y in data do
					if x ~= 1 then table.insert(Parameters,y) end
				end
				table.remove(props :: {any},i)
			end
		end
	end
	return table.unpack(Parameters)
end

--[=[
	Gets the object class from the source.
	
	@private
]=]
function internal.classObject(class: string, source: classSource?, props: props?)
	if source ~= "@base" and classes[class] then 
		return classes[class](internal.classParameters(props)) 
	elseif source ~= "@user" then 
		local data = internal.deepClone(basedata) 
		data[1] = class 
		return data
	end
	error([[Failed to find class "]]..class..[["]])
end

--[=[
	Parents the concept, returning itself nested underneath the parent.
	
	@private
]=]
function internal.parentObject(data: Concept, parent: Concept?): Concept
	if parent then
		local x = #parent[2]+1
		parent[2][x] = data
		return parent[2][x]
	else
		return data
	end
end

--[=[
	Sets the property of the concept, and detects if that property is a sub-concept.
	
	@private
]=]
function internal.setProperty(x, y, data: Concept)
	if typeof(x) == "string" and typeof(y) == "table" and typeof(y[1]) ~= "function" then
		for i,z in ipairs(data[2]) do
			if typeof(z[1]) ~= "string" then continue end
			local name = z[2]["Name"] or z[1]
			if x == name then return internal.setProps(z,y) end
		end
	end
	if typeof(x) == "number" then table.insert(data[2],y) else data[2][x]=y end
	return
end

--[=[
	Overrides the properties of the concept.
	
	@private
]=]
function internal.setProps(data: Concept, props: props?)
	if not props then return end
	for x,y in props do
		internal.setProperty(x,y,data)
	end
end

--[=[
	Calls the functions of a value object.
	
	@private
]=]
function internal.callFunctions(value: Value)
	for i,func in value[3] do 
		task.spawn(function()
			if func(value[2]) == cobalt.disconnect then value[3][i] = nil end
		end)
	end
end

--[=[
	Creates a concept object.
	
	@private
]=]
function internal.newObject(class: string, props: props?, source: classSource?, parent: Concept?): Concept
	local self = internal.classObject(class,source,props)
	internal.setProps(self,props)
	return internal.parentObject(self,parent)
end


-------------------------
-- Functions
-------------------------


--[=[
	Creates a new concept under the parent.
	
	@param class string -- The class of the concept.
	@param props props? -- The props of the concept, such as properties, children, connections, etc.
	@param source classSource? -- The source of the class, if its a user defined class or a base class.
]=]
function basedata:new(class: string, props: props?, source: classSource?): Concept
	return internal.newObject(class,props,source,self)
end

--[=[
	Sets the props of the concept.
	
	@param props props -- The props of the concept, such as properties, children, connections, etc.
]=]
function basedata:props(props: props): Concept
	internal.setProps(self,props)
	return self
end

--[=[
	Renders the concept into instances.
	
	@param parent Instance? -- The parent of the instance.
]=]
function basedata:render(parent: Instance?): Instance
	return internal.render(self,parent)
end

--[=[
	Gets the raw value.
]=]
function basevalue:get(): any
	return self[2]
end

--[=[
	Sets the value object.

	@param value any -- The updated value your assigning it.
]=]
function basevalue:set(value: any): Value
	animate.stop(self)
	if self[2] ~= value then
		self[2] = value
		internal.callFunctions(self)
	end
	return self
end

--[=[
	Animates the value object.

	@param target any -- The end result of the animation.
	@param easing Easing|Spring -- The motion of the animation, generated with cobalt.easing or cobalt.spring.
]=]
function basevalue:animate(target: any, easing: animate.Easing|animate.Spring)
	return animate.play({self, target, internal.callFunctions}, easing)
end

--[=[
	Fires a function upon observing a change in the value.

	@param func (any)->(...any) -- The function that will be fired.
]=]
function basevalue:observe(func: (any) -> (...any)): Value
	table.insert(self[3],func)
	return self
end

export type Value = typeof(basevalue)
export type Concept = typeof(basedata)


-------------------------
-- Interaction
-------------------------


--[=[
	Creates a new concept.

	@param class string -- The class of the concept.
	@param props props? -- The props of the concept, such as properties, children, connections, etc.
	@param source classSource? -- The source of the class, if its a user defined class or a base class.
]=]
function cobalt:new(class: string, props: props?, source: classSource?): Concept
	return internal.newObject(class,props,source)
end

--[=[
	Creates a new class, can override base classes and parameters can be passed to it.

	@param class string -- The name the class should be known as.
	@param func (any)->(Concept)? -- The function that generates a new concept.
]=]
function cobalt:class(class: string, func: (any)->(Concept)): cobalt
	classes[class] = func
	return cobalt
end

--[=[
	Creates a new cobalt value, updates associated properties when changed

	@param value any -- The value your assigning it.
]=]
function cobalt:value(value: any): Value
	local data = internal.deepClone(basevalue)
	data[1] = cobalt.value 
	data[2] = value 
	data[3] = {}
	return data
end

--[=[
	Connects to a signal when passed in props, return cobalt:disconnect() to disconnect.

	@param signal string -- The name of the signal your connecting to.
	@param func (...any)->(...any) -- The function that will be fired.
]=]
function cobalt:connect(signal: string, func: (...any)->(...any)): ()
	return {cobalt.connect,signal,func}
end

--[=[
	Passes parameters to the class when passed in props.

	@param ... any -- Any parameters to send to the class function.
]=]
function cobalt:params(...: any)
	return {cobalt.params,...}
end

--[=[
	Connects to a property or attribute changing when passed in props, return cobalt:disconnect() to disconnect.

	@param prop string -- The name of the property your connecting to.
	@param func (...any)->(...any) -- The function that will be fired.
	@param attribute "Attribute"? -- Specifies if you are connecting to an attribute instead
]=]
function cobalt:onChanged(prop: string, func: (...any)->(...any), attribute: "Attribute"?): ()
	return {cobalt.onChanged,prop,func,attribute and true or false}
end

--[=[
	Fires the function upon being rendered when passed in props.

	@param func (Instance)->(...any) -- The function that will be fired.
]=]
function cobalt:onRender(func: (Instance)->(...any)): ()
	return {cobalt.onRender,func}
end

--[=[
	Modifies an attribute when passed in a property table

	@param name string -- The name of the attribute to be changed.
	@param value any -- The new value of the attribute.
]=]
function cobalt:attribute(name: string, value: any): ()
	return {cobalt.attribute,name,value}
end

--[=[
	Disconnects the current connection if returned
]=]
function cobalt:disconnect(): ()
	return cobalt.disconnect
end

return cobalt