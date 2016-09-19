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

class OFXParser {
    
    var stringData : String
    var cachedTransactions : Array<Transaction>
    var parser : XMLParser
    
    init(xmlContents : String) {
        stringData = xmlContents
        parser = XMLParser()
        cachedTransactions = []
    }
    
    func transactions()->Array<Transaction> {
        if !cachedTransactions.isEmpty {
            return cachedTransactions
        }
        
        return [];
    }
    
    func forEach(action : (Transaction)->()) {
        for transaction in transactions() {
            action(transaction)
        }
    }
}
