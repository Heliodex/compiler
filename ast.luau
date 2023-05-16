export type NodeType =
	-- STATEMENTS	
	"Program"
	| "VarDeclaration"
	| "FunctionDeclaration"
	-- EXPRESSIONS
	| "AssignmentExpression"
	| "MemberExpression"
	| "CallExpression"
	| "ParenExpression"
	-- Literals
	| "Property"
	| "ObjectLiteral"
	| "NumericLiteral"
	| "Identifier"
	| "BinaryExpression"

--[[
	Statements do not result in a value at runtime.
	They contain one or more expressions internally 
]]
export type Statement = {
	kind: NodeType,
}

--[[
	Defines a block which contains many statements.
	- Only one program will be contained in a file.
]]
export type Program = Statement & {
	kind: "Program",
	body: { Statement },
}

export type VarDeclaration = Statement & {
	kind: "VarDeclaration",
	name: string,
	value: Expression?,
}

export type FunctionDeclaration = Statement & {
	kind: "FunctionDeclaration",
	params: { string },
	body: { Statement },
}

--- Expressions result in a value at runtime, unlike statements.
export type Expression = Statement & {}

export type AssignmentExpr = Expression & {
	kind: "AssignmentExpr",
	value: Expression,
	assignee: Expression,
}

--[[
	A operation with two sides seperated by a operator.
	Both sides can be ANY Complex Expression.
	- Supported Operators -> + | - | / | * | %
]]
export type BinaryExpr = Expression & {
	kind: "BinaryExpr",
	left: Expression,
	right: Expression,
	operator: string, -- needs to be of type BinaryOperator
}

export type CallExpr = Expression & {
	kind: "CallExpr",
	args: { Expression },
	caller: Expression,
}

-- export type ParenExpr = Expression & {
-- 	kind: "ParenExpr",
-- 	args: { Expression },
-- }

export type MemberExpr = Expression & {
	kind: "MemberExpr",
	object: Expression,
	property: Expression,
	computed: boolean,
}

-- Literal/primary expression types

--- Represents a user-defined variable or symbol in the source code
export type Identifier = Expression & {
	kind: "Identifier",
	symbol: string,
	subStatements: { Statement },
}

export type Newline = Expression & {
	kind: "Newline",
}

--- Represents a numeric constant in the soure code
export type NumericLiteral = Expression & {
	kind: "NumericLiteral",
	value: number,
}

return nil
