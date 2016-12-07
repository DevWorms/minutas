//
//  MyFile.swift
//  Minutas
//
//  Created by Emmanuel Valentín Granados López on 06/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

struct MyFile {
    static var url: NSURL = NSURL(fileURLWithPath:" ")
    
    static var Path: String {
        get {
            var pathDoc = ""
            
            if self.url.path != "/ " {
                pathDoc = self.url.path!
            }
            print("Path: " + pathDoc)
            
            return pathDoc
        }
    }
    
    static var Name: String {
        get {
            var nameDoc = ""
            
            if self.url.lastPathComponent != " " {
                nameDoc = self.url.lastPathComponent!.stringByReplacingOccurrencesOfString(" ", withString: "_")
            }
            print("Name: " + nameDoc)
            
            return nameDoc
        }
    }
}
