-- 用于设置不同文件类型所用注释符号
-- 若仅有单行注释 single，则在 visual 模式下以对所有选中行进行单行注释的形式完成多行注释
local default_filetype_format_config = {
    c   = {single = "//", block = {head = "/*", tail = "*/"}},
    cpp = {single = "//", block = {head = "/*", tail = "*/"}},
    lua = {single = "--", block = {head = "--[[", tail = "--]]"}},
    python = {single = "#"},
}

return default_filetype_format_config
