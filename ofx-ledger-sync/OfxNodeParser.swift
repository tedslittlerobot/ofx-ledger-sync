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
        case .invalidStructure: return "invalid structure"
        }
    }
    
    case unClosedTag(closing: String, stillOpen: String)
    case invalidStructure
}


class OfxNodeParser {
    var errorDescription : String?
    var ast : OfxAst
    
    var rootNode : RootNode = RootNode()
    var currentNode : Node
    
    init(withAst : OfxAst) {
        ast = withAst
        currentNode = rootNode as ObjectNode
        
        parse()
    }
    
    func parse() {
        
        do {
            try parseForNodes()
        } catch let e as OfxNodeParseError {
            errorDescription = e.description
        } catch {
            errorDescription = "other error"
        }
        
        //        debugNode(node: rootNode)
        //        dump("error: \(errorDescription)")
        //        let dumper = XmlDumper(rootNode: rootNode)
        //        print(dumper.dumpAll())
    }
    
    func parseForNodes() throws {
        for astNode in ast.nodes {
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
}
