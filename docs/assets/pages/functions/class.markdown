---
layout: page
title: :class()
permalink: /functions/class/
parent: Functions
---

# :class()
Function
{: .label .label-yellow }

### `cobalt:new()`

#### Description
Creates a new class, which can be used to override base classes and allows parameters to be passed to it.

--- 
#### Parameters
- `Class: string` 
The name of the class, this can be any string or even existing classes.
- `Function: (any) -> (Concept)?`
The function that generates a new concept. This must return a concept.

{: .warning }
Classes that call themselves will result in an **infinite loop**, use the `Source` parameter in [:new()](/functions/new) to specify that you aren't calling a user defined class.


---

#### Examples
By using classes, you can globally edit basic elements, like shown below.
```lua
    local cobalt = require("@game/path/to/cobalt")
    cobalt:class("Frame", function() 
        return cobalt:new("Frame", {
            Size = UDim2.new(1,0,1,0)
        }, "@base") -- Setting the source to @base prevents infinite loop.
    end)

    cobalt:new("Frame") -- This frame is now sized accordingly
```

Properties inside new Concepts can override the class properties you created.

### Using both
If you would prefer to use both the base class and the user class, without renaming them, you can call `@base` or `@user` in the `Source` parameter.

### Parameters

To send parameters to a class function, you can use the [params](/functions/params) syntax.