//
//  Protein.swift
//  SwiftyProtein
//
//  Created by Lucas BELVALETTE on 11/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
class Protein {
    let name: String?
    var atoms: [Atom]?
    var connection: [Connect]?

    func get_x_average() -> Float {
        var sum: Float = 0
        for x in atoms! {
            sum += x.x!
        }
        sum /= Float((atoms?.count)!)
        return (sum)
    }
    
    func get_y_average() -> Float {
        var sum: Float = 0
        for x in atoms! {
            sum += x.y!
        }
        sum /= Float((atoms?.count)!)
        return (sum)
    }
    
    func get_z_average() -> Float {
        var sum: Float = 0
        for x in atoms! {
            sum += x.z!
        }
        sum /= Float((atoms?.count)!)
        return (sum)
    }


    func addConnect(connect: Connect) {
        self.connection?.append(connect)
    }
    
    func addAtom (atom: Atom) {
        self.atoms?.append(atom)
        
    }
    
    
    init(name: String, atom: Atom) {
        self.name = name
        self.atoms = [atom]
        self.connection = []
    }
}
