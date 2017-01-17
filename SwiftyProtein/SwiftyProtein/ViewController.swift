//
//  ViewController.swift
//  SwiftyProtein
//
//  Created by Lucas BELVALETTE on 11/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage
import AlamofireSwiftyJSON
import SwiftyJSON
import LocalAuthentication

class ViewController: UIViewController {
    let context = LAContext()

    @IBOutlet weak var loginButton: UIButton!

    
    @IBAction func loginFunc(_ sender: UIButton) {
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "You need to be authenticate") { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goList", sender: "Foo")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg")!)
        loginButton.layer.cornerRadius = 5
        sleep(5)
    }

    

}

