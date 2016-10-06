//
//  Nodes.swift
//  ofx-ledger-sync
//
//  Created by Horner, Stefan (LDN-ARC) on 06/10/2016.
//  Copyright © 2016 tedslittlerobot. All rights reserved.
//

import Foundation

class Node {
    var tag : String

    var parentNode : Node?

    var children : [Node] = []

    init(name : String, parent : Node?) {
        tag = name
        parentNode = parent
    }
}

class ObjectNode : Node {}

class RootNode : ObjectNode {
    init() {
        super.init(name: "root", parent: nil)
    }
}

class TextNode : Node {
    var content : String

    init(name : String, parent : Node , contents : String) {
        content = contents
        super.init(name: name, parent: parent)
    }
}

