local execute_comment = {}

local function trim_pre_space(line)
    return (line:gsub("^%s*(.-)%s*$", "%1"))
end

--  根据当前行去除前导空格后，最前面的字串是否与单行注释相同来判断
local function is_commented_single(filetype_format)
    --[[
    vim.api.nvim_get_current_line()
    以字符串返回得到当前行的内容
    --]]
    local line = trim_pre_space(vim.api.nvim_get_current_line())
    return line:sub(1, #filetype_format['single']) == filetype_format['single']
end

--  根据当前行去除前导空格后，最前面的字串是否与注释样式相同来判断
local function is_commented_block(filetype_format)
    --[[
    vim.api.nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
    以数组返回缓冲区 buffer 中 (start, end] 左开右闭行号范围内的行内容
    Parameters
        {buffer} Buffer handle, or 0 for current buffer
        {start} First line index
        {end} Last line index, exclusive
        {strict_indexing} Whether out-of-bounds should be an error.
    --]]
    local start_line = vim.api.nvim_buf_get_lines(0, vim.fn.line("'<")-1, vim.fn.line("'<"), true)[1]
    local end_line = vim.api.nvim_buf_get_lines(0, vim.fn.line("'>")-1, vim.fn.line("'>"), true)[1]
    local line_1 = trim_pre_space(start_line)
    local line_2 = trim_pre_space(end_line)
    return line_1:sub(1, #filetype_format.block['head']) == filetype_format.block['head'] and
           line_2:sub(1, #filetype_format.block['tail']) == filetype_format.block['tail']
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

function execute_comment.toggle_block(filetype_format)
    if filetype_format['block'] == nil or
       filetype_format.block['head'] == nil or
       filetype_format.block['tail'] == nil then
        return nil
    end

    if is_commented_block(filetype_format) then
        vim.cmd('\'<normal dd')
        vim.cmd('\'>normal dd')
    else
        vim.cmd('\'<normal O'..filetype_format.block['head'])
        vim.cmd('\'>normal o'..filetype_format.block['tail'])
    end
end

return execute_comment
