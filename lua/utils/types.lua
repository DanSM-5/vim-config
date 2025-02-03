
---@alias config.TermDataCallback fun(channelId: integer, data: string[], name: string) Callback function for stdio functions
---@alias config.TermExitCallback fun(jobId: integer, exitCode: integer, event: 'exit') Callback function for stdio functions

---@class config.TermOpenOpts
---@field clear_env? boolean `env` defines the environment instead of merging it
---@field detach? boolean Detach the job process
---@field pty? boolean Connect to the job to a new pseudo terminal. `on_stdout` receives all output. `on_stderr` is ignored.
---@field rpc? boolean Use msgpack-rpc to communicate with the job over stdio. `on_stdout` is ignored but `on_stderr` can be used.
---@field cwd? string Set the current working directory.
---@field env? table<string, string> Sets the environment.
---@field overlapped? boolean Sets FILE_FLAG_OVERLAPPED for child process in Windows
---@field on_exit? config.TermExitCallback Callback invoked when the job exits.
---@field on_stdout? config.TermDataCallback Callback invoked when the job emits stdout data.
---@field on_stderr? config.TermDataCallback Callback invoked when the job emits stderr data.
---@field stderr_buffered? boolean Collect data until EOF before invoking on_stderr.
---@field stdout_buffered? boolean Collect data until EOF before invoking on_stdout.
---@field stdin? string Either a "pipe" to connect to job's stdin to a channel or "null" to disconnect stdin
---NOTE: the bellow are omitted as it should be controlled
---by the floating buffer
-- -@field height number Height of the pty terminal
-- -@field width number Width of the pty terminal


---@class config.CmdOptions: config.FloatOptions
---@field process_opts? config.ProcessOpts
---@field on_complete? fun(data: string[]) Output of the command. Same content that will be appended on the floating window.

-- -@field float? config.FloatOptions

---@class config.TermOptions: config.FloatOptions
---@field float? config.FloatOptions
---@field term_opts? config.TermOpenOpts Options for the terminal window.
---@field on_exit? fun(data: string[]) Buffer content before being removed. It will include empty lines of the buffer.

