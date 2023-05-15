--- Tokens
export type TokenType =
	"Number"
	| "Identifier"
	| "BinaryOperator"
	| "Equals"
	| "Comma"
	| "Dot"
	| "Colon"
	| "Semicolon"
	| "Bang" -- !
	| "OpenParen" -- (
	| "CloseParen" -- )
	| "OpenBrace" -- {
	| "CloseBrace" -- }
	| "OpenBracket" -- [
	| "CloseBracket" --]
	| "EOF"

--- A single token in the source code
export type Token = {
	value: string,
	type: TokenType,
	line: number,
	column: number,
}

--- Replace some characters with others for easier lexing
local function cleanup(str: string): string
	return str:gsub("\r\n", "\n")
end

--- Split the source code into characters,
--- then combine characters into tokens
return function(source: string)
	local src = cleanup(source):split ""
	local tokens: { Token } = {}

	local line = 1
	local column = 1

	local function newLine()
		line += 1
		column = 0
	end

	while #src > 0 do
		local char = table.remove(src, 1)

		if char:match "%d" then
			-- If character is integer
			local startColumn = column
			local number = char

			while #src > 0 and src[1]:match "%d" do
				number ..= table.remove(src, 1)
				column += 1
			end

			table.insert(tokens, {
				value = number,
				type = "Number",
				line = line,
				column = startColumn,
			})
		elseif char:match "%a" then
			-- If character is letter
			local startColumn = column
			local identifier = char

			while #src > 0 and src[1]:match "%w" do
				identifier ..= table.remove(src, 1)
				column += 1
			end

			table.insert(tokens, {
				value = identifier,
				type = "Identifier",
				line = line,
				column = startColumn,
			})
		elseif char == "\n" then
			newLine()
			-- else
			-- 	print(`Could not parse {char}`)
		end

		column += 1
	end

	table.insert(tokens, {
		value = "EOF",
		type = "EOF",
		line = line,
		column = column,
	})
	return tokens
end
