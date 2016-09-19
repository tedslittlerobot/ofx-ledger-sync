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

class OFXParser : NSObject, XMLParserDelegate {
    
    var xmlData : Data
    var cachedTransactions : Array<Transaction>
    var parser : XMLParser
    
    init(xmlContents : Data) {
        xmlData = xmlContents
        parser = XMLParser(data: xmlContents)
        cachedTransactions = []
        super.init()
    }
    
    func transactions()->Array<Transaction> {
        if !cachedTransactions.isEmpty {
            return cachedTransactions
        }
        parser.delegate = self
        parser.parse()
        dump(parser.parserError)
        
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
