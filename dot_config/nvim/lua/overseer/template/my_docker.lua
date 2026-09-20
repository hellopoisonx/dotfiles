-- Docker Compose 模板: compose up / compose down
return {
	generator = function(search)
		local compose_files = vim.fs.find({
			"compose.yaml",
			"compose.yml",
			"docker-compose.yaml",
			"docker-compose.yml",
		}, { upward = true, type = "file", path = search.dir })

		if #compose_files == 0 then
			return "未找到 docker-compose 配置文件"
		end

		local project_root = vim.fs.dirname(compose_files[1])
		local templates = {}

		-- docker compose up -d --build
		table.insert(templates, {
			name = "Docker: Compose Up",
			desc = "构建并启动容器 (后台运行)",
			builder = function()
				return {
					cmd = { "docker" },
					args = { "compose", "up", "-d", "--build" },
					cwd = project_root,
				}
			end,
		})

		-- docker compose down
		table.insert(templates, {
			name = "Docker: Compose Down",
			desc = "停止并移除容器",
			builder = function()
				return {
					cmd = { "docker" },
					args = { "compose", "down" },
					cwd = project_root,
				}
			end,
		})

		return templates
	end,
}
