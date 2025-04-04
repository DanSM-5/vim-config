" Set correct file type for .jsonc files

autocmd BufNewFile,BufRead *.cjson setlocal filetype=jsonc
autocmd BufNewFile,BufRead coc-settings.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead *.jsonc setfiletype jsonc
autocmd BufNewFile,BufRead .eslintrc.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead .babelrc setlocal filetype=jsonc
autocmd BufNewFile,BufRead .jshintrc setlocal filetype=jsonc
autocmd BufNewFile,BufRead .jslintrc setlocal filetype=jsonc
autocmd BufNewFile,BufRead .mocharc.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead coffeelint.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead tsconfig.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead jsconfig.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead settings.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead keybindings.json setlocal filetype=jsonc

