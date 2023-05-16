local fs = require "@lune/fs"
local stdio = require "@lune/stdio"
local process = require "@lune/process"
local filename = process.args[1]

if not filename then
	print(stdio.color "cyan")
	print "Usage: <command> <file>"
	print(stdio.color "reset")
	process.exit(1)
end

local file

pcall(function()
	file = fs.readFile(filename)
end)

if not file then
	error(`{filename} not found or failed to read`)
end

local parse = require "parser"
local ast = parse:ast(file)

local compile = require "compiler"
local code = compile(ast)
print(code)
