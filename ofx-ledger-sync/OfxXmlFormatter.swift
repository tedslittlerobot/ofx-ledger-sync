//
//  OfxXmlDumper.swift
//  ofx-ledger-sync
//
//  Created by Horner, Stefan (LDN-ARC) on 06/10/2016.
//  Copyright © 2016 tedslittlerobot. All rights reserved.
//

import Foundation

class OfxXmlFormatter {
    var tabStop : String = "    "
    var root : RootNode
    
    init(rootNode : RootNode) {
        root = rootNode
    }
    
    func tab(times: Int)->String {
        return String(repeating: tabStop, count: times)
    }
    
    func format()->String {
        return dumpNode(node: root.children.first!, depth: 0)
    }
    
    func dumpNode(node : Node, depth : Int)->String {
        //        dump(node.tag)
        //        dump(Mirror(reflecting: node).subjectType)
        if node is TextNode {
            return dumpTextNode(node: node as! TextNode, depth: depth)
        }
        
        if node.children.isEmpty {
            return dumpEmptyNode(node: node, depth: depth)
        }
        
        return dumpNodeWithChildren(node: node, depth: depth)
    }
    
    func dumpTextNode(node: TextNode, depth: Int)->String {
        return "\(tab(times: depth))<\(node.tag)>\(node.content)</\(node.tag)>\n"
    }
    
    func dumpEmptyNode(node: Node, depth: Int)->String {
        return "\(tab(times: depth))<\(node.tag) />\n"
    }
    
    func dumpNodeWithChildren(node: Node, depth: Int)->String {
        var buffer = "\(tab(times: depth))<\(node.tag)>\n"
        
        for child : Node in node.children {
            buffer.append(dumpNode(node: child, depth: depth + 1))
        }
        
        buffer.append("\(tab(times: depth))</\(node.tag)>\n")
        
        return buffer
    }
}
