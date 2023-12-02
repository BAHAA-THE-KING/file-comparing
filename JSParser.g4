parser grammar JSParser;

options {
    tokenVocab=JSLexer;
}

program
    : (statement+)? EOF
    ;

statement
    : block                     # BlockChunk
    | variableStatement         # VariableDeclerationChunk
    | importStatement           # ImportChunk
    | exportStatement           # ExportChunk
    | SemiColon                 # EmptyChunk
    | classDeclaration          # ClassDeclarationChunk
    | functionDeclaration       # FunctionDeclarationChunk
    | expressionStatement       # ExpressionChunk
    | ifStatement               # ConditionalChunk
    | iterationStatement        # LoopChunk
    | continueStatement         # ContinueChunk
    | breakStatement            # BreakChunk
    | returnStatement           # ReturnChunk
    | switchStatement           # SwitchChunk
    | throwStatement            # ThrowChunk
    | tryStatement              # TryChunk
    ;

block
    : OpenBrace statementList? CloseBrace
    ;

statementList
    : statement+
    ;

importStatement
    : Import StringLiteral eos                                                      # FileImportBlock
    | Import importNamespace From StringLiteral eos                                 # DeafultAsImportBlock
    | Import (importNamespace Comma)? importModuleItems From StringLiteral eos      # ObjectImportBlock
    ;

importModuleItems
    : OpenBrace (aliasName Comma)* (aliasName Comma?)? CloseBrace
    ;

importNamespace
    : (Multiply | Identifier) (As Identifier)?
    ;

aliasName
    : Identifier (As Identifier)?
    ;

exportStatement
    : Export Default?  declaration eos          # ExportDeclaration
    | Export Default? exportFromBlock  eos      # ExportBlock
    | Export Default singleExpression eos       # ExportDefaultDeclaration
    ;

exportFromBlock
    : exportModuleItems (From StringLiteral)?
    ;

exportModuleItems
    : OpenBrace (exportAliasName Comma)* (exportAliasName Comma?)? CloseBrace
    ;

exportAliasName
    : Identifier (As Identifier)?
    ;

declaration
    : variableStatement     #VariableDeclare
    | classDeclaration      #ClassDeclare
    | functionDeclaration   #FunctionDeclare
    ;

variableStatement
    : variableDeclarationList eos
    ;

variableDeclarationList
    : varModifier variableDeclaration (Comma variableDeclaration)*
    ;

variableDeclaration
    : assignable (Assign singleExpression)?
    ;

expressionStatement
    : expressionSequence eos
    ;

ifStatement
    : If OpenParen expressionSequence CloseParen statement (Else statement)?
    ;

iterationStatement
    : Do statement While OpenParen expressionSequence CloseParen eos                                                                                    # DoWhileStatement
    | While OpenParen expressionSequence CloseParen statement                                                                                           # WhileStatement
    | For OpenParen (expressionSequence | variableDeclarationList)? SemiColon expressionSequence? SemiColon expressionSequence? CloseParen statement    # ForStatement
    | For OpenParen (singleExpression | variableDeclarationList) In expressionSequence CloseParen statement                                             # ForInStatement
    | For OpenParen (singleExpression | variableDeclarationList) Of expressionSequence CloseParen statement                                             # ForOfStatement
    ;

varModifier
    : Var
    | Let
    | Const
    ;

continueStatement
    : Continue eos
    ;

breakStatement
    : Break eos
    ;

returnStatement
    : Return expressionSequence? eos
    ;

switchStatement
    : Switch OpenParen expressionSequence CloseParen caseBlock
    ;

caseBlock
    : OpenBrace caseClauses? (defaultClause caseClauses?)? CloseBrace
    ;

caseClauses
    : caseClause+
    ;

caseClause
    : Case expressionSequence Colon statementList?
    ;

defaultClause
    : Default Colon statementList?
    ;

throwStatement
    : Throw expressionSequence eos
    ;

tryStatement
    : Try block (catchProduction finallyProduction? | finallyProduction)
    ;

catchProduction
    : Catch (OpenParen assignable? CloseParen)? block
    ;

finallyProduction
    : Finally block
    ;

functionDeclaration
    : Function Identifier OpenParen formalParameterList? CloseParen functionBody
    ;

classDeclaration
    : Class Identifier classTail
    ;

classTail
    : (Extends Identifier)? OpenBrace classElements CloseBrace
    ;

classElements:
    classElement*
    ;

classElement
    : Static? methodDefinition                  # ClassMethodDefinition
    | Static? fieldDefinition                   # ClassFieldDefinition
    | SemiColon                                 # ClassEmptyStatement
    ;

methodDefinition
    : propertyName OpenParen formalParameterList? CloseParen functionBody
    ;

fieldDefinition
    : propertyName (Assign singleExpression)?
    ;

formalParameterList
    : formalParameterArg (Comma formalParameterArg)* (Comma lastFormalParameterArg)?
    | lastFormalParameterArg
    ;

formalParameterArg
    : assignable (Assign singleExpression)?
    ;

lastFormalParameterArg
    : Ellipsis singleExpression
    ;

functionBody
    : OpenBrace (statement+)? CloseBrace
    ;

arrayLiteral
    : (OpenBracket elementList CloseBracket)
    ;

elementList
    : Comma* arrayElement? (Comma+ arrayElement)* Comma*
    ;

arrayElement
    : Ellipsis? singleExpression
    ;

propertyAssignment
    : propertyName Colon singleExpression                                       # PropertyExpressionAssignment
    | OpenBracket singleExpression CloseBracket Colon singleExpression          # ComputedPropertyExpressionAssignment
    | propertyName OpenParen formalParameterList?  CloseParen  functionBody     # FunctionProperty
    | Ellipsis? singleExpression                                                # PropertyShorthand
    ;

propertyName
    : Identifier                                    #PropertyByName
    | StringLiteral                                 #PropertyByString
    | DecimalLiteral                                #PropertyByNumber
    | OpenBracket singleExpression CloseBracket     #PropertyByExpression
    ;

arguments
    : OpenParen(argument (Comma argument)* Comma?)?CloseParen
    ;

argument
    : Ellipsis? (singleExpression | Identifier)
    ;

expressionSequence
    : singleExpression (Comma singleExpression)*
    ;

singleExpression
    : anonymousFunction                                                                                 # FunctionExpression
    | Class Identifier? classTail                                                                       # ClassExpression
    | singleExpression QuestionMarkDot singleExpression                                                 # OptionalChainExpression
    | singleExpression QuestionMarkDot? OpenBracket expressionSequence CloseBracket                     # MemberIndexExpression
    | singleExpression QuestionMark? Dot Identifier                                                     # MemberDotExpression
    | New Identifier arguments                                                                          # NewExpression
    | singleExpression arguments                                                                        # ArgumentsExpression
    | singleExpression PlusPlus                                                                         # PostIncrementExpression
    | singleExpression MinusMinus                                                                       # PostDecreaseExpression
    | Delete singleExpression                                                                           # DeleteExpression
    | Typeof singleExpression                                                                           # TypeofExpression
    | PlusPlus singleExpression                                                                         # PreIncrementExpression
    | MinusMinus singleExpression                                                                       # PreDecreaseExpression
    | Plus singleExpression                                                                             # UnaryPlusExpression
    | Minus singleExpression                                                                            # UnaryMinusExpression
    | Not singleExpression                                                                              # NotExpression
    | <assoc=right> singleExpression Power singleExpression                                             # PowerExpression
    | singleExpression (Multiply | Divide | Modulus) singleExpression                                   # MultiplicativeExpression
    | singleExpression (Plus | Minus) singleExpression                                                  # AdditiveExpression
    | singleExpression NullCoalesce singleExpression                                                    # CoalesceExpression
    | singleExpression (LessThan | MoreThan | LessThanEquals | GreaterThanEquals) singleExpression      # RelationalExpression
    | singleExpression (Equals | NotEquals | IdentityEquals | IdentityNotEquals) singleExpression       # EqualityExpression
    | singleExpression And singleExpression                                                             # LogicalAndExpression
    | singleExpression Or singleExpression                                                              # LogicalOrExpression
    | singleExpression QuestionMark singleExpression Colon singleExpression                             # TernaryExpression
    | <assoc=right> singleExpression Assign singleExpression                                            # AssignmentExpression
    | <assoc=right> singleExpression assignmentOperator singleExpression                                # AssignmentOperatorExpression
    | singleExpression templateStringLiteral                                                            # TemplateStringExpression
    | This                                                                                              # ThisExpression
    | Identifier                                                                                        # IdentifierExpression
    | Super                                                                                             # SuperExpression
    | literal                                                                                           # LiteralExpression
    | arrayLiteral                                                                                      # ArrayLiteralExpression
    | objectLiteral                                                                                     # ObjectLiteralExpression
    | OpenParen expressionSequence CloseParen                                                           # ParenthesizedExpression
    ;

assignable
    : Identifier        # VariableByName
    | arrayLiteral      # VariableByArray
    | objectLiteral     # VariableByObject
    ;

objectLiteral
    : OpenBrace (propertyAssignment (Comma propertyAssignment)* Comma?)? CloseBrace
    ;

anonymousFunction
    : Function OpenParen formalParameterList? CloseParen functionBody       # AnonymousFunctionDecl
    | arrowFunctionParameters ARROW arrowFunctionBody                       # ArrowFunction
    ;

arrowFunctionParameters
    : Identifier
    | OpenParen formalParameterList? CloseParen
    ;

arrowFunctionBody
    : singleExpression
    | functionBody
    ;

assignmentOperator
    : MultiplyAssign            # MultiplyOperator
    | DivideAssign              # DivideOperator
    | ModulusAssign             # ModulusOperator
    | PlusAssign                # PlusOperator
    | MinusAssign               # MinusOperator
    | PowerAssign               # PowerOperator
    | NullishCoalescingAssign   # NullishOperator
    ;

literal
    : NullLiteral               # Null
    | BooleanLiteral            # Boolean
    | StringLiteral             # String
    | templateStringLiteral     # TemplateString
    | DecimalLiteral            # Number
    ;

templateStringLiteral
    : BackTick templateStringAtom* BackTick
    ;

templateStringAtom
    : TemplateStringAtom                                            # TemplateStringCharacter
    | TemplateStringStartExpression singleExpression CloseBrace     # TemplateStringJSExpression
    ;

eos
    : SemiColon
    | EOF
    | {this.lineTerminatorAhead()}?
    | {this.closeBrace()}?
    ;
