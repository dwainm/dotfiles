return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.sources = opts.sources or {}
    opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
    table.insert(opts.sources.default, "blog_links")
    opts.sources.providers = opts.sources.providers or {}
    opts.sources.providers["blog_links"] = {
      module = "blog_links",
      name = "Blog Links",
      min_keyword_length = 2,
    }
  end,
}
