--[[
定义：
前导空白字符：行首个非空白字符前的所有空白字符
单行注释行：除去前导空白字符，行首内容与该文件类型的 single 注释样式相同的行
多行注释行：连续多行出现的单行注释行
块首注释行：除去前导空白字符，行首内容与该文件类型 'head' 注释样式相同，且与块尾注释行成对出现注释掉一块文本的行
块尾注释行：除去前导空白字符，行首内容与该文件类型 'tail' 注释样式相同，且与块首注释行成对出现注释掉一块文本的行
一对块注释行：一对成对出现注释掉一块文本的的块首注释行和快尾注释行
--]]

local execute_comment = {}

local function trim_pre_space(line)
    --[[
    string.find(), 默认使用 lua 的正则匹配
    返回第一个匹配到的子串的下标
    parameters:
        str 进行搜索的字符串
        substr 要搜索的子串，可为 lua 中的正则表达式
        init 搜索起始位置，默认为 1
        plain 是否使用正则匹配，默认为 false
    lua 中的正则表达式是 lua 自己定义的，与通常所说的正则表达式有不少区别
    具体可查阅 lua 官方文档 Patterns 与 Pattern-Matching Functions 相关小节
    lua 中使用 %s 表示任意空白字符 大写就是取反 %S 表示任意非空白字符
    --]]
    local line_blank_len = line:find("%S") or 1
    --[[
    string.sub()
    返回下标 [i,j] 闭区间范围的子串
    parameters:
        s 进行操作的字符串
        i 提前子串的起始位置，闭区间
        j 提前子串的结束位置，闭区间，可为负数，-1 表示最后一个字符位置，-2 表示倒数第二个字符位置，以此类推
    --]]
    return line:sub(line_blank_len)
end

local function is_commented_single(filetype_format)
    --[[
    vim.api.nvim_get_current_line()
    以字符串返回当前行的内容
    --]]
    local line = trim_pre_space(vim.api.nvim_get_current_line())
    return line:sub(1, #filetype_format['single']) == filetype_format['single']
end

--  同时满足下列所有条件，则当前 visual 模式下选中行是已注释状态：
--  1. 选中行的首行为块首注释行，或块首注释行的后一行
--  2. 选中行的尾行为块尾注释行，或块尾注释行的前一行
local function is_commented_block(filetype_format, start_line_number, end_line_number)
    local start_line = trim_pre_space(vim.api.nvim_buf_get_lines(0, start_line_number-1, start_line_number, true)[1])
    local end_line = trim_pre_space(vim.api.nvim_buf_get_lines(0, end_line_number-1, end_line_number, true)[1])
    local condition_1 = start_line:sub(1, #filetype_format.block['head']) == filetype_format.block['head']
    local condition_2 = end_line:sub(1, #filetype_format.block['tail']) == filetype_format.block['tail']
    if condition_1 and condition_2 then
        -- 选中行首行为快首注释行，尾行为块尾注释行
        return {start_line_number, end_line_number}
    end
    if condition_1 and end_line_number ~= vim.fn.line("$") then
        -- vim.fn.line("$") 返回当前缓冲区尾行行号
        local after_end_line = trim_pre_space(vim.api.nvim_buf_get_lines(0, end_line_number, end_line_number+1, true)[1])
        if after_end_line:sub(1, #filetype_format.block['tail']) == filetype_format.block['tail'] then
            return {start_line_number, end_line_number+1}
        end
        return nil
    end
    if condition_2 and start_line_number ~= 1 then
        -- vim 中 buffer 首行行号为 1
        local before_start_line = trim_pre_space(vim.api.nvim_buf_get_lines(0, start_line_number-2, start_line_number-1, true)[1])
        if before_start_line:sub(1, #filetype_format.block['head']) == filetype_format.block['head'] then
            return {start_line_number-1, end_line_number}
        end
        return nil
    end
    if start_line_number == 1 or end_line_number == vim.fn.line("$") then
        return nil
    end
    local before_start_line = trim_pre_space(vim.api.nvim_buf_get_lines(0, start_line_number-2, start_line_number-1, true)[1])
    local after_end_line = trim_pre_space(vim.api.nvim_buf_get_lines(0, end_line_number, end_line_number+1, true)[1])
    if before_start_line:sub(1, #filetype_format.block['head']) == filetype_format.block['head'] and
       after_end_line:sub(1, #filetype_format.block['tail']) == filetype_format.block['tail'] then
        return {start_line_number-1, end_line_number+1}
    end
    return nil
end

--  同时满足下列所有条件，则当前 visual 模式下选中行是已注释状态：
--  1. 非空行都处于单行注释状态
--  注意辨析，除空白字符外仅有单行注释字符的行，并不是空行
local function is_commented_multiple_single(filetype_format, start_line_number, end_line_number)
    local lines = vim.api.nvim_buf_get_lines(0, start_line_number-1, end_line_number, true)
    for _,line in pairs(lines) do
        if line:find("%S") ~= nil then
            local line = trim_pre_space(line)
            if line:sub(1, #filetype_format['single']) ~= filetype_format["single"] then
                return false
            end
        end
    end
    return true
end

function execute_comment.toggle_single(filetype_format)
    if filetype_format['single'] == nil then
        return nil
    end

    if is_commented_single(filetype_format) then
        vim.cmd('norm ^'..#filetype_format['single'] + 1 ..'x')
    else
        vim.cmd('normal ^i'..filetype_format['single']..' ')
    end
end

function execute_comment.toggle_block(filetype_format, start_line_number, end_line_number)
    if filetype_format['block'] == nil or
       filetype_format.block['head'] == nil or
       filetype_format.block['tail'] == nil then
        -- 对无多行注释的语言如 python，采用每行使用单行注释
        local is_commented = is_commented_multiple_single(filetype_format, start_line_number, end_line_number)
        local lines = vim.api.nvim_buf_get_lines(0, start_line_number-1, end_line_number, true)
        if is_commented then
            for count,line in ipairs(lines) do
                local line_blank_len =  line:find("%S")
                if line_blank_len ~= nil then
                    line = line:sub(1,line_blank_len-1) .. line:sub(line_blank_len+2)
                    vim.api.nvim_buf_set_lines(0, start_line_number+count-2, start_line_number+count-1, true, {line})
                end
            end
        else
            local min_blank = 999
            for _,line in pairs(lines) do
                local line_blank_len =  line:find("%S") or 0
                min_blank = math.min(min_blank, line_blank_len)
                if min_blank == 0 then break end
            end

            for count,line in ipairs(lines) do
                if line:find("%S") ~= nil then
                    -- 只对非空行添加注释
                    if min_blank == 0 then
                        line = filetype_format["single"] .. " " .. line
                    else
                        line = line:sub(1,min_blank-1) .. filetype_format['single'] .. " " .. line:sub(min_blank)
                    end
                    vim.api.nvim_buf_set_lines(0, start_line_number+count-2, start_line_number+count-1, true, {line})
                end
            end
        end
        return
    end
    --[[
    vim.api.nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
    以数组返回缓冲区 buffer 中 (start, end] 左开右闭行号范围内的行内容
    Parameters
        {buffer} Buffer handle, or 0 for current buffer
        {start} First line index
        {end} Last line index, exclusive
        {strict_indexing} Whether out-of-bounds should be an error.
    --]]
    local ret = is_commented_block(filetype_format, start_line_number, end_line_number)
    if ret ~= nil then
        -- 因为先删除块首注释行会导致块尾注释行行号 - 1，所以应先删除块尾注释行，再删除块首注释行
        vim.api.nvim_buf_set_lines(0, ret[2]-1, ret[2], true, {})
        vim.api.nvim_buf_set_lines(0, ret[1]-1, ret[1], true, {})
    else
        local selected_lines = vim.api.nvim_buf_get_lines(0, start_line_number-1, end_line_number, true)
        local min_blank = 999
        for _,line in pairs(selected_lines) do
            local line_blank_len =  line:find("%S") or 0
            min_blank = math.min(min_blank, line_blank_len)
            if min_blank == 0 then
                break;
            end
        end
        local prefix = ""
        if min_blank ~= 0 then
            prefix = string.format("%" .. min_blank-1 .. "s", "")
        end
        local insert_start_line = prefix..filetype_format.block['head']
        local insert_end_line = prefix..filetype_format.block['tail']
        --[[
        nvim_buf_set_lines()
        Parameters:
            {buffer} 0 表示当前 buffer
            {start} 进行操作的起始行行号，闭区间
            {end} 进行操作的结束行行号，开区间
            {strict_indexing} 超出范围是否报错
            {replacement} 用于替换的行内容
        Note:
            [start,end) 左闭右开
            如果 start == end 则在该行之后插入 replacement 内容
        --]]
        vim.api.nvim_buf_set_lines(0, end_line_number, end_line_number, true, {insert_end_line})
        vim.api.nvim_buf_set_lines(0, start_line_number-1, start_line_number-1, true, {insert_start_line})
    end
end

return execute_comment
