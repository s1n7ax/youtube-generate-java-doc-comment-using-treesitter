local ts_utils = require("nvim-treesitter.ts_utils")
local ts_locals = require("nvim-treesitter.locals")
local ts_indent = require("nvim-treesitter.indent")

function get_method_node()
    local curr_node = ts_utils.get_node_at_cursor()
    local scope = ts_locals.get_scope_tree(curr_node, 0)
    local method_node = nil

    for _, node in ipairs(scope) do
        if node:type() == "method_declaration" then
            method_node = node
        end
    end

    return method_node
end

function get_method_info()
    local method_node = get_method_node()

    if not method_node then
        return
    end

    local query = vim.treesitter.query.parse_query(
        "java",
        [[
    (method_declaration
      type: (type_identifier) @return_type
      name: (identifier) @name
      parameters: (formal_parameters) @params)
    ]]
    )

    for _, matches, _ in query:iter_matches(method_node, 0) do
        local return_type = vim.treesitter.query.get_node_text(matches[1], 0)
        local name = vim.treesitter.query.get_node_text(matches[2], 0)
        local param_node = matches[3]
        local param_info = {}

        for param in param_node:iter_children() do
            if param:type() == "formal_parameter" then
                table.insert(param_info, {
                    type = vim.treesitter.query.get_node_text(param:field("type")[1], 0),
                    name = vim.treesitter.query.get_node_text(param:field("name")[1], 0),
                })
            end
        end

        return {
            return_type = return_type,
            name = name,
            param_info = param_info,
            start_line = method_node:start(),
        }
    end
end

function get_indent_str(line)
    local indent_count = ts_indent.get_indent(line)

    if indent_count == 0 then
        return ""
    end

    local tabstop = vim.o.tabstop
    local ntabs = (indent_count / tabstop)
    local tab_space = ""

    if vim.o.expandtab then
        tab_space = string.rep(" ", tabstop * ntabs)
    else
        tab_space = string.rep("\t", ntabs)
    end

    return tab_space
end

function get_doc_comment(method_info, tab_space)
    local comment_lines = {}

    local function add_line(line)
        table.insert(comment_lines, tab_space .. line)
    end

    add_line("/**")
    add_line(string.format(" * %s <description>", method_info.name))

    for _, param in ipairs(method_info.param_info) do
        add_line(string.format(" * @param { %s } %s <description>", param.type, param.name))
    end

    add_line(string.format(" * @returns { %s } <description>", method_info.return_type))
    add_line(" */")
    add_line("")

    return comment_lines
end

function add_doc_comment()
    local method_info = get_method_info()

    if not method_info then
        return
    end

    local tab_space = get_indent_str(method_info.start_line)
    local comment_lines = get_doc_comment(method_info, tab_space)

    vim.api.nvim_buf_set_text(0, method_info.start_line, 0, method_info.start_line, 1, comment_lines)
end

add_doc_comment()
