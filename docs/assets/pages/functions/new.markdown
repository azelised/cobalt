---
layout: page
title: :new()
permalink: /cobalt/functions/new/
parent: Functions
---

# :new()
Function
{: .label .label-yellow }

### `cobalt:new()`, `concept:new()`

#### Description
Creates a new concept, which defines its class, and optionally, its properties. You can call this function under cobalt to create new one or you can call it underneath an existing concept to parent it to it.

--- 
#### Parameters
- `Class: string` 
The class of the concept, this can be a user defined class or a roblox class.
- `Props: props?`
The props of the concept, such as properties, children, connections, etc.
- `Source: classSource?`
The source of the class, if its a user defined class or a roblox class.

{: .highlight }
The `Source` parameter is entirely **optional**, as both types are checked by default.


---

#### Examples
Using the code below, you can generate a `ScreenGui` concept, a virtual container for rest of the UI you wish to create.

```lua
    local cobalt = require("@game/path/to/cobalt")
    cobalt:new("ScreenGui", {
        -- Your properties, children, connections, etc.
    })
```

### Parenting

As for parenting, you can approach this in two different ways.

- You can parent cobalt concepts directly in `Props`, skipping the need of defining it.
```lua
    local cobalt = require("@game/path/to/cobalt")
    cobalt:new("ScreenGui", {
        cobalt:new("Frame")
    })
```
- Additionally, you can parent them to the concept's variable.
```lua
    local cobalt = require("@game/path/to/cobalt")
    local Concept = cobalt:new("ScreenGui")
    Concept:new("Frame")
```

It is perferred to parent them underneath `Props`, as this saves you more space.

### Repeated usage

For basic objects that you plan to use throughout your codebase, its recommended to use [classes](/functions/class).