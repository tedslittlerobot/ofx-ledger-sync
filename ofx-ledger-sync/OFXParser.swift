//
//  OFXParser.swift
//  ofx-ledger-sync
//
//  Created by Horner, Stefan (LDN-ARC) on 19/09/2016.
//  Copyright © 2016 tedslittlerobot. All rights reserved.
//
// @todo - xml parser
// @todo - parse ofx files for transactions

import Foundation

struct Transaction {}

class OFXParser : NSObject {
    
    var xmlData : String
    
    init(xmlContents : String) {
        xmlData = xmlContents
        super.init()
    }
    
    func transactions()->[Transaction] {
        let parser = OfxToNodeParser(xmlContents: xmlData)
        
        parser.parse()
        
        dump(parser)
        
        return [];
    }
    
    func forEach(action : (Transaction)->()) {
        for transaction in transactions() {
            action(transaction)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        dump("start element \(elementName)")
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        dump("  found chars: \(string)")
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        dump("end element \(elementName)")
    }
}

class Node {
    var content : String = ""
}
class TagNode : Node {}
class OpeningTagNode : TagNode {}
class ClosingTagNode : TagNode {}
class TextNode : Node {
    var parent : OpeningTagNode
    init(parentTag : OpeningTagNode) {
        parent = parentTag
    }
}
class NullNode : Node {}

enum OfxParseError: Error {
    var description: String {
        switch self {
            case .badlyPlacedOpeningTag: return "badlyPlacedOpeningTag"
            case .badlyPlacedCloseSpecifier: return "badlyPlacedCloseSpecifier"
            case .badlyPlacedClosingTag: return "badlyPlacedClosingTag"
            case .badlyPlacedTextError: return "badlyPlacedTextError"
            case .invalidStructureError: return "invalidStructureError"
        }
    }
    case badlyPlacedOpeningTag
    case badlyPlacedCloseSpecifier
    case badlyPlacedClosingTag
    case badlyPlacedTextError
    case invalidStructureError
}

class OfxToNodeParser {
    var charactersForParsing : [Character]
    var nodes : [Node]
    var currentNode : Node
    var errorDescription : String?
    
    init(xmlContents : String) {
        currentNode = NullNode()
        nodes = []
        charactersForParsing = []
        charactersForParsing = prepareStringForParsing(xmlContents)
    }
    
    func prepareStringForParsing(_ content: String)->[Character] {
        var workingContent = ""
        
        workingContent = content.replacingOccurrences(of: "\n", with: "")
        workingContent = workingContent.trimmingCharacters(in: [" "])
        
        return Array(workingContent.characters.reversed())
    }
    
    func parse() {
        do {
            try parseForNodes()
        } catch let e as OfxParseError {
            errorDescription = e.description
        } catch {
            errorDescription = "other error"
        }
    }

    func parseForNodes() throws {
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
        guard currentNode is NullNode || currentNode is TextNode else {
            throw OfxParseError.badlyPlacedOpeningTag
        }
        
//        print("found an opening tag")
        
        if currentNode is NullNode {
            currentNode = OpeningTagNode()
        }
        
        if currentNode is TextNode {
            nodes.append(currentNode)
            currentNode = OpeningTagNode()
        }
    }
    
    func encounterCloseSpecifier() throws {
        guard currentNode is OpeningTagNode || currentNode is TextNode else {
            throw OfxParseError.badlyPlacedCloseSpecifier
        }
        
//        print("found a close specifier")
        
        if currentNode is OpeningTagNode {
            currentNode = ClosingTagNode()
        }
        
        if currentNode is TextNode {
            currentNode.content.append("/")
        }
    }
    
    func encounterCloseTag() throws {
        guard currentNode is OpeningTagNode || currentNode is ClosingTagNode else {
            throw OfxParseError.badlyPlacedClosingTag
        }
        
//        print("found a closing tag")
        
        if nodes.last is TextNode {
            // @todo handle unclosed simple tags - a la http://www.hanselman.com/blog/PostprocessingAutoClosedSGMLTagsWithTheSGMLReader.aspx
            let textNode : TextNode = nodes.last as! TextNode
            
            if currentNode.content != textNode.parent.content {
//                print("auto-closing a text node")
                let closingTag = ClosingTagNode()
                
                closingTag.content = textNode.parent.content
                
                nodes.append(closingTag)
            }
            
        }
        
        nodes.append(currentNode)
        currentNode = NullNode()
    }
    
    func encounterText(character : Character) throws {
        guard currentNode is TagNode || currentNode is NullNode || currentNode is TextNode else {
            throw OfxParseError.badlyPlacedTextError
        }
        
//        print("found some text")
        
        if currentNode is NullNode && nodes.last != nil {
            let lastTag = nodes.last
            
            guard lastTag is OpeningTagNode else {
                throw OfxParseError.invalidStructureError
            }

            currentNode = TextNode(parentTag: lastTag as! OpeningTagNode)
        }

        currentNode.content.append(character)
    }
}
