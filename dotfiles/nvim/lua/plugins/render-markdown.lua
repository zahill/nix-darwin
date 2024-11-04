return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {},
		opts = {},
		config = function()
			require("render-markdown").setup({
				render_modes = true,
				pipe_table = {
					enabled = true,
					preset = "none",
					style = "full",
					cell = "padded",
					padding = 1,
					min_width = 0,
				},
				heading = {
					border = false,
				},
				indent = {
					enabled = true,
					per_level = 2,
					skip_level = 1,
					skip_heading = true,
				},
				checkbox = {
					enabled = true,
					position = "inline",
					unchecked = {},
					checked = {
						scope_highlight = "@markup.strikethrough",
					},
					custom = {},
				},
			})
		end,
	},
}
