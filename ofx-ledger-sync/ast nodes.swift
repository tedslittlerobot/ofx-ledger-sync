//
//  AstNodes.swift
//  ofx-ledger-sync
//
//  Created by Horner, Stefan (LDN-ARC) on 06/10/2016.
//  Copyright © 2016 tedslittlerobot. All rights reserved.
//

import Foundation

class AstNode : NSObject {
    var content : String = ""
}
class TagAstNode : AstNode {}

class OpeningTagAstNode : TagAstNode {
    override var description : String {
        return "<\(content)>"
    }
}

class ClosingTagAstNode : TagAstNode {
    override var description : String {
        return "</\(content)>"
    }
}

class TextAstNode : AstNode {
    var parent : OpeningTagAstNode
    init(parentTag : OpeningTagAstNode) {
        parent = parentTag
    }
    override var description : String {
        return "TEXT: \(content)"
    }
}

class NullAstNode : AstNode {
    override var description : String {
        return "---"
    }
}
