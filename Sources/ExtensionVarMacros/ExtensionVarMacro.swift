import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ExtensionVarMacroError: Error {
    case invalidMacroArgument
    case typeError
    case typeMustByOptional
}

public struct ExtensionVarMacro: AccessorMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        /*
         VariableDeclSyntax
     ├─attributes: AttributeListSyntax
     │ ╰─[0]: AttributeSyntax
     │   ├─atSign: atSign
     │   ├─attributeName: IdentifierTypeSyntax
     │   │ ╰─name: identifier("eVar")
     │   ├─leftParen: leftParen
     │   ├─arguments: LabeledExprListSyntax
     │   │ ╰─[0]: LabeledExprSyntax
     │   │   ├─label: identifier("key")
     │   │   ├─colon: colon
     │   │   ╰─expression: StringLiteralExprSyntax
     │   │     ├─openingQuote: stringQuote
     │   │     ├─segments: StringLiteralSegmentListSyntax
     │   │     │ ╰─[0]: StringSegmentSyntax
     │   │     │   ╰─content: stringSegment("test_objc_key")
     │   │     ╰─closingQuote: stringQuote
     │   ╰─rightParen: rightParen
     ├─modifiers: DeclModifierListSyntax
     ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.let)
     ╰─bindings: PatternBindingListSyntax
       ╰─[0]: PatternBindingSyntax
         ├─pattern: IdentifierPatternSyntax
         │ ╰─identifier: identifier("test")
         ╰─typeAnnotation: TypeAnnotationSyntax
           ├─colon: colon
           ╰─type: OptionalTypeSyntax
             ├─wrappedType: IdentifierTypeSyntax
             │ ╰─name: identifier("String")
             ╰─questionMark: postfixQuestionMark
         */
        
        let arguments = try parseNodeArguments(node.arguments)
        let declType = try parseDeclType(declaration)
        guard let objcKeyName = arguments["key"], !objcKeyName.isEmpty else { throw ExtensionVarMacroError.invalidMacroArgument }
        guard let policy = arguments["policy"], !policy.isEmpty else { throw ExtensionVarMacroError.invalidMacroArgument }
        return [
            .init(accessorSpecifier: "get", bodyBuilder: {
                """
                objc_getAssociatedObject(self, &Self.\(raw: objcKeyName)) as? \(raw: declType)
                """
            }),
            .init(accessorSpecifier: "set", bodyBuilder: {
                """
                objc_setAssociatedObject(self, &Self.\(raw: objcKeyName), newValue, .\(raw: policy))
                """
            })
        ]
    }
    
}

func parseNodeArguments(_ arguments: AttributeSyntax.Arguments?) throws -> [String: String] {
    guard let args = arguments?.as(LabeledExprListSyntax.self) else {
        throw ExtensionVarMacroError.invalidMacroArgument
    }
    return args.reduce(into: [String: String]()) { partialResult, argument in
        guard let label = argument.as(LabeledExprSyntax.self)?.label?.text else { return }
        guard let value = argument.expression
            .as(StringLiteralExprSyntax.self)?
            .segments.first?
            .as(StringSegmentSyntax.self)?
            .content.text
        else { return }
        partialResult[label] = value
    }
}

func parseDeclType(_ decl: SwiftSyntax.DeclSyntaxProtocol) throws -> String {
    guard let type = decl.as(VariableDeclSyntax.self)?.bindings.first?.typeAnnotation?.type else { fatalError("!!!!") }
    
    if type.is(IdentifierTypeSyntax.self) {
        throw ExtensionVarMacroError.typeMustByOptional
    }
    
    guard let type = type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text else {
        throw ExtensionVarMacroError.typeError
    }
    return type
}

@main
struct ExtensionVarPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ExtensionVarMacro.self
    ]
}
