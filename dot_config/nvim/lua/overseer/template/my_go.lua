-- Go 模板: go run / go build
return {
	generator = function(search)
		local templates = {}

		-- go run <current file>
		table.insert(templates, {
			name = "Go: Run Current File",
			desc = "运行当前 Go 文件",
			builder = function()
				return {
					cmd = { "go" },
					args = { "run", vim.fn.expand("%:p") },
					cwd = vim.fn.expand("%:p:h"),
				}
			end,
			tags = { require("overseer").TAG.RUN },
			condition = { filetype = { "go" } },
		})

		-- go build <project root>
		local go_mod = vim.fs.find("go.mod", { upward = true, type = "file", path = search.dir })[1]
		if go_mod then
			local project_root = vim.fs.dirname(go_mod)
			table.insert(templates, {
				name = "Go: Build Project",
				desc = "构建 Go 项目",
				builder = function(params)
					local output = params.output or vim.fs.basename(project_root)
					return {
						cmd = { "go" },
						args = { "build", "-o", output, "." },
						cwd = project_root,
					}
				end,
				params = {
					output = { type = "string", optional = true, desc = "输出文件名 (默认: 项目目录名)" },
				},
				tags = { require("overseer").TAG.BUILD },
			})
		end

		return templates
	end,
	condition = { filetype = { "go" } },
}
