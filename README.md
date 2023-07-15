# simple_comment.nvim

用于添加注释 or 取消注释的 neovim 插件

# usage

当在 normal 模式时，会将光标所在当前行使用单行注释添加注释 or 取消注释

```lua
    -- before
    print("hello world")

    -- after
    -- print("hello world")
```

当在 visual 或 visual line 模式时，会将所选范围行的前、后插入多行注释

取消多行注释时，需要选中前后的注释行，否则会认为是添加多行注释

```lua
    -- before
    print("hello world")
    print("byebye world")

    -- after
    --[[
    print("hello world")
    print("byebye world")
    --]]
```

# install

使用 lazy.nvim :

```lua
{
    "whitelies125/simple_comment.nvim",
    config = true,
    -- or
    --[[
    config = function(_, opts)
        require("simple_comment").setup()
    end,
    --]]
}
```

# about

neovim 用着挺舒服的。

最近是在寻找一些插件，完善我所需的一些常用功能

考虑到注释功能比较简单，而且我最近也愿意折腾，抱着顺带熟悉 lua 与 neovim 接口的念头，也就写个这个插件练手。

2023.07.16
