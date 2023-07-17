# simple_comment.nvim

用于添加注释 or 取消注释的 neovim 插件

# usage

定义：

- 前导空白字符：行首个非空白字符前的所有空白字符
- 单行注释行：除去前导空白字符，行首内容与该文件类型的 single 注释样式相同的行
- 多行注释行：连续多行出现的单行注释行
- 块首注释行：除去前导空白字符，行首内容与该文件类型 'head' 注释样式相同，且与块尾注释行成对出现注释掉一块文本的行
- 块尾注释行：除去前导空白字符，行首内容与该文件类型 'tail' 注释样式相同，且与块首注释行成对出现注释掉一块文本的行
- 一对块注释行：一对成对出现注释掉一块文本的的块首注释行和快尾注释行

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

当在 visual 模式时，若只选中单行，则与 normal 模式下相同：

~~~lua
    -- before
1   print("hello world")
2   print("byebye world")

    -- only select line 1, press <CTRL-/>, comment line 1, same to normal mode
1   -- print("hello world")
2   print("byebye world")

    -- only select line 1, press <CTRL-/> again, uncomment line 1, same to normal mode
1   print("hello world")
2   print("byebye world")
~~~

若选中多行，则会将所选范围行的前、后插入一对块注释行：


```lua
    -- before
1   print("hello world")
2   print("byebye world")

    -- select line 1,2, press <CTRL-/>, comment this block
1   --[[
2   print("hello world")
3   print("byebye world")
4   --]]
```

取消一对块注释行时，选中一对块注释行，或选中块首注释行其后首行及块尾注释行其前首行，皆可：

```lua
    --before
1   --[[
2   print("hello world")
3   print("byebye world")
4   --]]

    -- case 1: select line 1,2,3,4
    -- case 2: select line 2,3
    -- press <CTRL-/>, uncomment this block
1   print("hello world")
2   print("byebye world")

    -- other case: execute comment
    -- case 3: select line 1,2
    -- press <CTRL-/>, comment line 1,2
1   --[[
2   --[[
3   print("hello world")
4   --]]
5   print("byebye world")
6   --]]
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

考虑到注释功能比较简单，而且我最近也愿意折腾，抱着顺带熟悉 lua 与 neovim 接口的念头，也就写了这个插件练手。
