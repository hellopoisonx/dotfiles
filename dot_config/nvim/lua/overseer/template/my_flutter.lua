-- Flutter (fvm) 模板: flutter run / flutter build
return {
	generator = function(search)
		local pubspec = vim.fs.find("pubspec.yaml", { upward = true, type = "file", path = search.dir })[1]
		if not pubspec then
			return "未找到 pubspec.yaml"
		end

		local project_root = vim.fs.dirname(pubspec)
		local templates = {}

		-- fvm flutter run
		table.insert(templates, {
			name = "Flutter: Run",
			desc = "运行 Flutter 应用 (fvm)",
			builder = function(params)
				local args = { "flutter", "run" }
				if params.device and params.device ~= "" then
					table.insert(args, "-d")
					table.insert(args, params.device)
				end
				return {
					cmd = { "fvm" },
					args = args,
					cwd = project_root,
				}
			end,
			params = {
				device = { type = "string", optional = true, desc = "设备 ID (留空自动选择)" },
			},
			tags = { require("overseer").TAG.RUN },
		})

		-- fvm flutter build <target>
		table.insert(templates, {
			name = "Flutter: Build",
			desc = "构建 Flutter 应用 (fvm)",
			builder = function(params)
				return {
					cmd = { "fvm" },
					args = { "flutter", "build", params.target },
					cwd = project_root,
				}
			end,
			params = {
				target = {
					type = "enum",
					choices = { "apk", "appbundle", "ios", "ipa", "web", "linux", "macos", "windows" },
					default = "apk",
					desc = "构建目标",
				},
			},
			tags = { require("overseer").TAG.BUILD },
		})

		return templates
	end,
}
