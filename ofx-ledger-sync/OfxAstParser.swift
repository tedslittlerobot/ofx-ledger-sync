//
//  OfxAstParser.swift
//  ofx-ledger-sync
//
//  Created by Horner, Stefan (LDN-ARC) on 06/10/2016.
//  Copyright © 2016 tedslittlerobot. All rights reserved.
//

import Foundation

enum OfxParseError: Error {
    var description: String {
        switch self {
        case .badlyPlacedOpeningTag: return "badly placed opening tag"
        case .badlyPlacedCloseSpecifier: return "badly placed close specifier"
        case .badlyPlacedClosingTag: return "badly placed closing tag"
        case .badlyPlacedTextError: return "badly placed text"
        case .invalidStructureError: return "invalid OFX structure"
        }
    }
    
    case badlyPlacedOpeningTag
    case badlyPlacedCloseSpecifier
    case badlyPlacedClosingTag
    case badlyPlacedTextError
    case invalidStructureError
}


class OfxAst {
    var charactersForParsing : [Character] = []
    var headers : String = ""
    var nodes : [AstNode] = []
    var currentNode : AstNode = NullAstNode()
    var errorDescription : String?
    
    init(xmlContents : String) {
        prepareStringForParsing(xmlContents)
        parse()
    }
    
    func prepareStringForParsing(_ content: String) {
        var workingContent = content
        let startOfOfx = content.range(of: "<")!.lowerBound
        let headerRange = workingContent.startIndex..<startOfOfx
        
        headers = content.substring(with: headerRange)
        workingContent.replaceSubrange(headerRange, with: "") // remove the headers
        
        workingContent = workingContent.replacingOccurrences(of: "\n", with: "")
        workingContent = workingContent.trimmingCharacters(in: [" "])
        
        charactersForParsing = Array(workingContent.characters.reversed())
    }
    
    func parse() {
        do {
            try parseForAstNodes()
        } catch let e as OfxParseError {
            errorDescription = e.description
        } catch {
            errorDescription = "other error"
        }
    }
    
    func debugNode(node : Node) {
        let type = Mirror(reflecting: node).subjectType
        
        dump("\(node.tag) \(type)")
        for child in node.children {
            debugNode(node: child)
        }
    }
    
    func parseForAstNodes() throws {
        while charactersForParsing.count > 0 {
            let char = charactersForParsing.popLast()!
            let stringChar = String(describing: char)
            
            //            print(stringChar)
            
            if stringChar == "<" {
                // @todo - handle errors
                try encounterOpenTag()
                continue
            }
            if stringChar == "/" {
                try encounterCloseSpecifier()
                continue
            }
            if stringChar == ">" {
                try encounterCloseTag()
                continue
            }
            try encounterText(character: char)
        }
    }
    
    func encounterOpenTag() throws {
        guard currentNode is NullAstNode || currentNode is TextAstNode else {
            throw OfxParseError.badlyPlacedOpeningTag
        }
        
        //        print("found an opening tag")
        
        if currentNode is NullAstNode {
            currentNode = OpeningTagAstNode()
        }
        
        if currentNode is TextAstNode {
            nodes.append(currentNode)
            currentNode = OpeningTagAstNode()
        }
    }
    
    func encounterCloseSpecifier() throws {
        guard currentNode is OpeningTagAstNode || currentNode is TextAstNode else {
            throw OfxParseError.badlyPlacedCloseSpecifier
        }
        
        //        print("found a close specifier")
        
        if currentNode is OpeningTagAstNode {
            currentNode = ClosingTagAstNode()
        }
        
        if currentNode is TextAstNode {
            currentNode.content.append("/")
        }
    }
    
    func encounterCloseTag() throws {
        guard currentNode is OpeningTagAstNode || currentNode is ClosingTagAstNode else {
            throw OfxParseError.badlyPlacedClosingTag
        }
        
        //        print("found a closing tag")
        
        if nodes.last is TextAstNode {
            // @todo handle unclosed simple tags - a la http://www.hanselman.com/blog/PostprocessingAutoClosedSGMLTagsWithTheSGMLReader.aspx
            let textNode : TextAstNode = nodes.last as! TextAstNode
            
            if currentNode.content != textNode.parent.content {
                //                print("auto-closing a text node")
                let closingTag = ClosingTagAstNode()
                
                closingTag.content = textNode.parent.content
                
                nodes.append(closingTag)
            }
            
        }
        
        nodes.append(currentNode)
        currentNode = NullAstNode()
    }
    
    func encounterText(character : Character) throws {
        guard currentNode is TagAstNode || currentNode is NullAstNode || currentNode is TextAstNode else {
            throw OfxParseError.badlyPlacedTextError
        }
        
        //        print("found some text")
        
        if currentNode is NullAstNode && nodes.last != nil {
            let lastTag = nodes.last
            
            guard lastTag is OpeningTagAstNode else {
                throw OfxParseError.invalidStructureError
            }
            
            currentNode = TextAstNode(parentTag: lastTag as! OpeningTagAstNode)
        }
        
        currentNode.content.append(character)
    }
}
