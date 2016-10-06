//
//  OfxNodeParser.swift
//  ofx-ledger-sync
//
//  Created by Horner, Stefan (LDN-ARC) on 06/10/2016.
//  Copyright © 2016 tedslittlerobot. All rights reserved.
//

import Foundation

enum OfxNodeParseError: Error {
    var description: String {
        switch self {
            case .unClosedTag(let closing, let stillOpen): return "attempting to close \(closing) when \(stillOpen) is still open"
            case .invalidStructure: return "Invalid Abstract Syntax Tree structure"
            case .astError(let summary): return "AST Error: \(summary)"
        }
    }

    case unClosedTag(closing : String, stillOpen : String)
    case invalidStructure
    case astError(summary : String)
}


class OfxNodeParser {
    var errorDescription : String?
    var ast : OfxAst

    var rootNode : RootNode = RootNode()
    var currentNode : Node

    init(withAst : OfxAst) {
        ast = withAst
        currentNode = rootNode

        parse()
    }

    func parse() {
        do {
            try parseForNodes()
        } catch let e as OfxNodeParseError {
            errorDescription = e.description
        } catch {
            errorDescription = "Impossible error"
        }

        if rootNode.children.isEmpty {
            errorDescription = "There are no valid nodes"
        }
    }

    func parseForNodes() throws {
        guard ast.tree() != nil else {
            throw OfxNodeParseError.astError(summary: ast.errorDescription!)
        }

        for astNode in ast.tree()! {
            guard astNode is OpeningTagAstNode || astNode is ClosingTagAstNode || astNode is TextAstNode else {
                throw OfxNodeParseError.invalidStructure
            }

            if astNode is OpeningTagAstNode {
                let node = ObjectNode(name: astNode.content, parent: currentNode)
                currentNode.children.append(node)
                currentNode = node
            }

            if astNode is ClosingTagAstNode {
                guard astNode.content == currentNode.tag else {
                    throw OfxNodeParseError.unClosedTag(closing: astNode.content, stillOpen: currentNode.tag)
                }

                currentNode = currentNode.parentNode!
            }

            if astNode is TextAstNode {
                let toReplace = currentNode
                currentNode = toReplace.parentNode!
                let node = TextNode.init(name: toReplace.tag, parent: toReplace.parentNode!, contents: astNode.content)

                // remove the objectnode version of this text node
                currentNode.children.remove(at: currentNode.children.count - 1)
                // then add the text node
                currentNode.children.append(node)
                // and make it the current node
                currentNode = node
            }
        }
    }

    func xml()->String {
        let xml = OfxXmlFormatter(rootNode: rootNode)

        return xml.format()
    }

    func tree()->Node? {
        if errorDescription != nil {
            return nil
        }

        return rootNode.children.first
    }
}
