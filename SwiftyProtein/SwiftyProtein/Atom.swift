//
//  Atom.swift
//  SwiftyProtein
//
//  Created by Lucas BELVALETTE on 11/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import SceneKit

class Atom {
    let id: Int?
    let x: Float?
    let y: Float?
    let z: Float?
    let mol: String?
    var node: SCNNode?
    
    init(id: Int, x: Float, y: Float, z: Float, mol: String) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
        self.mol = mol
    }
}
