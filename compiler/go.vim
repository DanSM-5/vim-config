let current_compiler = 'go'
CompilerSet makeprg=go\ build\ ./...
" %E: error, %f: filename, %l: line, %c: column, %m message
CompilerSet errorformat=%E%f:%l%c:%m
