-- 用于设置不同文件类型所用注释符号
filetype_format_config = {
    c   = {single = "//", block = {head = "/*", tail = "*/"}},
    cpp = {single = "//", block = {head = "/*", tail = "*/"}},
    lua = {single = "--", block = {head = "--[[", tail = "--]]"}},
}

return filetype_format_config