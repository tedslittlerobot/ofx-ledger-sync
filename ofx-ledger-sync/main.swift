//
//  main.swift
//  ofx-ledger-sync
//
//  Created by Horner, Stefan (LDN-ARC) on 19/09/2016.
//  Copyright © 2016 tedslittlerobot. All rights reserved.
//

import Foundation

print("Hello, World!")

// For now, arg 1 is the ofx file
dump(CommandLine.arguments);

let location = Bundle.main.path(forResource: "sample-file", ofType: "ofx")

let fileContent = try String.init(contentsOfFile: location!, encoding: String.Encoding.utf8)

let parser = OFXParser(xmlContents: fileContent.data(using: String.Encoding.utf8)!)

dump(parser.transactions())

// @todo - get file to read from / stdin
// @todo - get ledger file to output to / stdout
// @todo - yaml settings file (for default options)
// @todo - search ledger file to see if the transaction is already in there - ignore if it is
// @todo - search ledger file to see if the payee or transaction is already in there - guess the account, etc. from the existing
// @todo - construct ledger entry - add transaction id to it
// @todo - config for account guessing
// @todo - util - get all accounts from ledgerfile
// @todo - interactivity - which accounts to put things that it can't guess in (config to set deaults)



// Create a FileManager instance
// let fileManager = FileManager.default

// Get current directory path
// let path = fileManager.currentDirectoryPath
// print(path)
