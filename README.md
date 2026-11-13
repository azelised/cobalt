<img width="2000" alt="Cobalt" src="./docs/images/cobaltinfo.png" />

# What is Cobalt?

Cobalt is a hand-built, intuitive UI framework for Luau, made as an beginner-friendly alternative to Fusion.

<a href="https://wally.run/package/azelised/cobalt">
    <img width="100" alt="wally" src="https://github.com/user-attachments/assets/9d7a3aa1-38dd-4b43-ac6c-68fcb28e544b" />
  </a>
<a href="https://github.com/azelised/cobalt/releases">
    <img width="100" alt="rbxm" src="https://github.com/user-attachments/assets/6ebbbbd6-a111-4cc4-9dd8-6e4b7b7e338f" />
  </a>
<a href="https://docs.azelised.dev/cobalt">
    <img width="100" alt="docs" src="https://github.com/user-attachments/assets/70eb9348-d7cd-49de-b785-87a7059bdb49" />
  </a>

# Who is this for?

The Cobalt framework is meant for people starting out and existing users of other frameworks who want a simpler syntax.

Cobalt is very easy to change to your needs, with it being only a couple hundred lines long, while maintaining core features of more complex frameworks.

# Using it in your code

Put the file into your codebase's utility folder, require it, and your set!

You can use this code below to generate a simple `TextLabel` to say `"Hello World!"` in Roblox.

```lua
    local cobalt = require("@game/path/to/cobalt")
    local player = game.Players.LocalPlayer

    cobalt:new("ScreenGui", {
        cobalt:new("TextLabel", {
            Text = "Hello World!",
            Size = UDim2.new(1,0,1,0),
        }),
    }):render(player.PlayerGui)
```
