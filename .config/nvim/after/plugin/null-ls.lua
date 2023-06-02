-- local null_ls = require("null-ls")

-- local phpcs_command = vim.fn.systemlist( 'find . -name phpcs -maxdepth 3' )
-- -- ./vendor/bin/phpcs --standard=phpcs.xml

-- local null_sources = {
--     require("null-ls").builtins.formatting.eslint_d,
--     require("null-ls").builtins.diagnostics.eslint_d,
-- 	null_ls.builtins.diagnostics.php,
--   }

-- if ( phpcs_command[1] ~= nil and phpcs_command[1] ~= '' ) then
--    table.insert( null_sources, require("null-ls").builtins.diagnostics.phpcs.with({
-- 	   command = phpcs_command[1],
--    }))
-- end

-- null_ls.setup({
--     sources = null_sources,
-- })

-- print("null ls setup")
