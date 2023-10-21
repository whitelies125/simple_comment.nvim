# simple_comment.nvim

用于添加注释 or 取消注释的 neovim 插件

# usage

## example

### normal mode

当在 normal 模式时，按下 `ctrl-/` 会将光标所在当前行使用单行注释添加注释 or 取消注释：

```lua
    -- before
    print("hello world")

    -- <CTRL-/>, comment this line
    -- print("hello world")

    -- <CTRL-/> again, uncomment this line
    print("hello world")
```

### visual mode

当在 visual 模式时，会将所选范围行的前、后插入一对注释：


```lua
    -- before
1   print("hello world")

    -- select line 1, press <CTRL-/>, comment this block
1   --[[
2   print("hello world")
3   --]]

    -- before
1   print("hello world")
2   print("byebye world")

    -- select line 1,2, press <CTRL-/>, comment this block
1   --[[
2   print("hello world")
3   print("byebye world")
4   --]]
```

取消多行注释时，选中首注释行或其后一行，及尾注释行或其前一行，皆可：

```lua
    --before
1   --[[
2   print("hello world")
3   print("byebye world")
4   --]]

    -- case 1: select line 1,2,3,4
    -- case 2: select line 2,3
    -- case 3: select line 1,2,3
    -- case 4: select line 2,3,4
    -- press <CTRL-/>, uncomment this block
1   print("hello world")
2   print("byebye world")
    -- other case: execute comment
```

对于仅配置了 single 注释样式的文件类型（如 python）：

1. 采用对每行使用单行注释的方式，达到多行注释的效果

2. 取消注释，不再具有上述 "选中首注释行或其后一行，及尾注释行或其前一行" 的功能，仅对选中行有效


```python
    --before
1   print("hello world")
2        a = 1
3   print("byebye world")

    -- press <CTRL-/>, comment this block
1   # print("hello world")
2   #     a = 1
3   # print("byebye world")

    -- only case 1: select line 1,2,3
    -- press <CTRL-/> again, uncomment this block
1   print("hello world")
2       a = 1
3   print("byebye world")
```

# install

使用 lazy.nvim :

```lua
{
    "whitelies125/simple_comment.nvim",
    opts = {
            filetype_format_config = {
                c   = {single = "//", block = {head = "/*", tail = "*/"}},
                cpp = {single = "//", block = {head = "/*", tail = "*/"}},
                lua = {single = "--", block = {head = "--[[", tail = "--]]"}},
                python = {single = "#"},
            }
    },
    config = function(_, opts)
        local sc = require("simple_comment")
        sc.setup(opts)
        --  由于一些原因，在 vim/neovim 中是使用的 <C-_> 表示 CTRL-/，而非 <C-/>
        vim.keymap.set({"n"}, "<C-_>", ":lua require(\"simple_comment\").comment(\"n\")<CR>", {noremap = true, silent = true})
        vim.keymap.set({"v"}, "<C-_>", ":lua require(\"simple_comment\").comment(\"v\")<CR>", {noremap = true, silent = true})
    end,
}
```

# about

neovim 用着挺舒服的。

最近是在寻找一些插件，完善我所需的一些常用功能

考虑到注释功能比较简单，而且我最近也愿意折腾，抱着顺带熟悉 lua 与 neovim 接口的念头，也就写了这个插件练手。
