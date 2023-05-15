local ast = require "ast"
local lexer = require "lexer"

type TokenType = lexer.TokenType
type Token = lexer.Token

local parser = {}

parser.tokens = {}

--- Whether we have reached the end of the file
function parser:notEOF()
	return self.tokens[1].type ~= "EOF"
end

--- Get a future token from a specific index
function parser:token(num: number?): Token
	return self.tokens[num or 1]
end

--- Get the next token
function parser:next()
	return table.remove(self.tokens, 1)
end

--[[
	Get the next token if it matches a specific
	type, otherwise throw an error
]]
function parser:expect(type: TokenType, err: any)
	local token = self:next()

	if not token or token.type ~= type then
		error(err or "Unexpected token")
	end
end

--- Parse the source code into an AST
function parser:ast(source: string)
	self.tokens = lexer(source)

	local program: ast.Program = {
		kind = "Program",
		body = {},
	}

	-- Parse until end of file
	while self:notEOF() do
		table.insert(program.body, self:parseExpression())
	end

	return program
end

--- Parse an expression
function parser:parseExpression(): ast.Expression
	local left = self:parseAdditiveExpression()

	if self:token().type == "Equals" then
		self:next()

		return {
			kind = "AssignmentExpression",
			value = self:parseExpression(),
			assignee = left,
		} :: ast.AssignmentExpr
	end

	return left
end

--- Handle Addition & Subtraction Operations
function parser:parseAdditiveExpression(): ast.Expression
	local left = self:parseMultiplicativeExpression()

	while ({ "+", "-" })[self:token().value] do
		left = {
			kind = "BinaryExpression",
			operator = self:next().value,
			left = left,
			right = self:parseMultiplicativeExpression(),
		} :: ast.BinaryExpr
	end

	return left
end

--- Handle Multiplication, Division, and Modulo Operations
function parser:parseMultiplicativeExpression(): ast.Expression
	local left = self:parseMemberExpression()

	while ({ "*", "/", "%" })[self:token().value] do
		left = {
			kind = "BinaryExpression",
			operator = self:token().value,
			left = left,
			right = self:parseMemberExpression(),
		} :: ast.BinaryExpr
	end

	return left
end

function parser:parseMemberExpression(): ast.Expression
	local object = self:parsePrimaryExpression()

	while self:token().type == "Dot" or self:token().type == "OpenBracket" do
		local operator = self:next()

		local property: ast.Expression
		local computed: boolean

		if operator.Type == "Dot" then
			computed = false
			-- get identifier
			property = self:parseIdentifier()
			if property.kind ~= "Identifier" then
				error "Cannonot use dot operator without right hand side being a identifier"
			end
		else -- this allows obj[computedValue]
			computed = true
			property = self:parseExpression()

			self:expect("CloseBracket", "Expected closing bracket in computed value")
		end

		object = {
			kind = "MemberExpression",
			object = object,
			property = property,
			computed = computed,
		} :: ast.MemberExpr
	end

	return object
end

--[[
function parser:parseObjectExpression() --: ast.Expression
	-- if self:token().type != "OpenBrace"
end

function parser:parseCallMemberExpression(): ast.Expression
end
	
function parser:parseCallExpression(caller: ast.Expression) --: ast.Expression
end

function parser:parseFunctionArgs() --: { ast.Expression }
end
function parser:parseArgs() --: { ast.Expression }
end

function parser:parseArgumentsList() --: { ast.Expression }
end
]]

function parser:parsePrimaryExpression(): ast.Expression
	local tokenType = self:token().type

	if tokenType == "Identifier" then
		return {
			kind = "Identifier",
			symbol = self:next().value,
		} :: ast.Identifier
	elseif tokenType == "Number" then
		return {
			kind = "NumberLiteral",
			value = tonumber(self:next().value),
		} :: ast.NumericLiteral
	elseif tokenType == "OpenParen" then
		self:next() -- Skip opening parenthesis
		self:expect(
			"CloseParen",
			"Unexpected token found inside parenthesised expression, expected closing parenthesis"
		)
		return self:parseExpression()
	else
		error("Unexpected token found during parsing:", self:token())
	end
end

return parser
