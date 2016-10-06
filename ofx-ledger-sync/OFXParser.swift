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
        
        let ast = OfxAst.init(xmlContents: xmlData)
        
        let parser = OfxNodeParser(withAst: ast)
        
        print(parser.xml())
        
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
