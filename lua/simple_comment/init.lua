local M = {}

-- 注意 M 的函数不能为 local，需要是全局
function M.comment(mode)
    local filetype_format_config = require("simple_comment.filetype_format_config")
    -- vim.bo.filetype 获得当前 buffer 的文件类型
    local filetype_format = filetype_format_config[vim.bo.filetype]
    if filetype_format == nil then
        print('filetype_format not defined')
        return nil
    end

    local is_single = false
    local start_line_number = 0
    local end_line_number = 0
    if mode == "n" then
        is_single = true
    elseif mode == "v" then
        --[[
        vim.vn.line()
        vim.fn.line("'<") : 得到最近一次 visual mode 下选择区域的首行行号，若该标记不存在则返回 0
        vim.fn.line("'>") : 得到最近一次 visual mode 下选择区域的尾行行号，若该标记不存在则返回 0
        --]]
        start_line_number = vim.fn.line("'<")
        end_line_number = vim.fn.line("'>")
        is_single = start_line_number == end_line_number
    else
        return nil
    end

    local execute_comment = require("simple_comment.execute_comment")
    if is_single then
        execute_comment.toggle_single(filetype_format)
    else
        execute_comment.toggle_block(filetype_format, {start_line_number, end_line_number})
    end
end

function M.setup(opts)
    --  由于一些原因，在 vim/neovim 中是使用的 <C-_> 表示 CTRL-/，而不是 <C-/>

    --  另外，虽然不知道为什么，但是使用 :lua require(\"simple_comment\").comment()<CR>
    --  这种映射，才能在 visual line 模式下，vim.fn.line("'<") 和 vim.fn.line("'>") 返回的是当前选中行的范围
    --  如果使用 funciton require("simple_comment").comment() 则返回的是是前一次选中行的范围

    -- 另2，在 visual line 模式下，使用 vim.api.nvin_get_mode() 返回的总是 'n' 而非我预期的 'V'
    -- 所以这里通过分别在 'n'，'v' 模式下写映射，把当前处于模式作为参数传进来，由此避开这个问题
    vim.keymap.set({"n"}, "<C-_>", ":lua require(\"simple_comment\").comment(\"n\")<CR>", {noremap = true, silent = true})
    vim.keymap.set({"v"}, "<C-_>", ":lua require(\"simple_comment\").comment(\"v\")<CR>", {noremap = true, silent = true})
end

return M
