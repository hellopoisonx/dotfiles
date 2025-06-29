return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            c = { "clang-format" },
            cpp = { "clang-format" },
            hpp = { "clang-format" },
            h = { "clang-format" },
            cmake = { "cmake_format" },
            lua = { "stylua" },
            zsh = { "shfmt" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            python = { "autopep8" },
            json = { "jq" },
            jsonc = { "fixjson" },
            yaml = { "yq" },
            go = { "gofmt" },
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
    },
}
