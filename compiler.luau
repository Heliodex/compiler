local ast = require "ast"

return function(astNode: ast.Program)
	-- local body = astNode.body
	local index = 0
	local function iter()
		index += 1
		if astNode.body[index] then
			return astNode.body[index]
		end
		return
	end

	local program = ""

	local function evaluateIdentifier(node: ast.Identifier)
		program ..= node.symbol
		-- print(node)
		local arg = iter()

		if node.subStatements then
			local count = -1
			for _, subStatement in ipairs(node.subStatements) do
				count += 1
				if count == 0 then
					program ..= (subStatement.symbol or subStatement.value)
				else
					program ..= "(" .. (subStatement.symbol or subStatement.value)
				end
			end
			for _ = 1, count do
				program ..= ")"
			end
		end

		if not arg or arg.kind == "Newline" then
			return
		else
			-- print(arg)
			program ..= "("
			if arg.kind == "NumericLiteral" then
				program ..= arg.value
			elseif arg.kind == "Identifier" then
				evaluateIdentifier(arg)
			end
			program ..= ")"
		end
	end

	for i in iter do
		if i.kind == "Identifier" then
			evaluateIdentifier(i)
			program ..= "\n"
		end
	end

	return program
end
