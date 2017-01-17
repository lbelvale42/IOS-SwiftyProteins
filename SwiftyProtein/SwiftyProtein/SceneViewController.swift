//
//  SceneViewController.swift
//  SwiftyProtein
//
//  Created by Lucas BELVALETTE on 11/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import SceneKit

class SceneViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rotateButton: UIButton!
    
    var protein: Protein?
    
    var currentAngle: Float = 0.0
    var geometryNode: SCNNode?
    var cameraNode: SCNNode?
    var lastScale: CGFloat = 25
    var isHidden = false
    var flag = false
    var model = true
    var spin: CABasicAnimation?
    
    @IBAction func rotateFunc(_ sender: Any) {
        if flag == true {
            rotateButton.setTitle("Play", for: .normal)
            stopAnimation()
            flag = false
        }
        else {
            rotateButton.setTitle("Stop", for: .normal)
            addAnimation()
            flag = true
        }
    }
    @IBAction func removeHAtom(_ sender: Any) {
        geometryNode?.removeFromParentNode()
        if isHidden == false {
            drawScene(flag: false, model: self.model)
            isHidden = true
        }
        else {
            drawScene(flag: true, model: self.model)
            isHidden = false
        }
        
        
    }
    @IBAction func modelFunc(_ sender: Any) {
        if model == false {
            self.model = true
            drawScene(flag: self.flag, model: self.model)
        }
        else {
            self.model = false
            drawScene(flag: self.flag, model: self.model)
        }
    }

    @IBAction func shareFunc(_ sender: Any) {
        let textToShare = "Swift is awesome!  Check out my Swifty Protein model"

        let image = sceneView.snapshot()
        
        let objectsToShare = [textToShare, image] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    
    }

    func drawScene (flag: Bool, model: Bool) {
        stopAnimation()
        let x = self.protein?.get_x_average()
        let y = self.protein?.get_y_average()
        let z = self.protein?.get_z_average()
        
        let scene = SCNScene()
        sceneView.prepare(scene, shouldAbortBlock: nil)
        sceneView.scene = scene
        
        let camera = SCNCamera()
        cameraNode = SCNNode()
        cameraNode?.camera = camera
        cameraNode?.position = SCNVector3(x: 0, y: 0, z: 25)
        
        scene.rootNode.addChildNode(cameraNode!)
        
        
        let atomsNode = SCNNode()
        for atom in (protein?.atoms)! {
            if flag == true || (flag == false && atom.mol != "H") {
                let obj = SCNSphere(radius: 0.3)
                if model == false {
                    obj.radius = 1.5
                }
                if atom.mol == "C" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                }
                else if atom.mol == "O" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 240/255, green: 0/255, blue: 0/255, alpha: 1)
                }
                else if atom.mol == "N"  {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 143/255, green: 143/255, blue: 255/255, alpha: 1)
                }
                else if atom.mol == "NA" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
                }
                else if atom.mol == "H" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                }
                else if atom.mol == "S" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 200/255, blue: 50/255, alpha: 1)
                }
                else if atom.mol == "P" || atom.mol == "BA" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
                }
                else if atom.mol == "F" || atom.mol == "SI" || atom.mol == "AG"  {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 1)
                }
                else if atom.mol == "CL" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1)
                }
                else if atom.mol == "BR" || atom.mol == "ZN" || atom.mol == "CU" || atom.mol == "NI" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 165/255, green: 42/255, blue: 42/255, alpha: 1)
                }
                else if atom.mol == "FE" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
                }
                else if atom.mol == "MG" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1)
                }
                else if atom.mol == "CA" {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 128/255, green: 128/255, blue: 144/255, alpha: 1)
                }
                else {
                    obj.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 20/255, blue: 147/255, alpha: 1)
                }
                
                let node = SCNNode(geometry: obj)
                node.position = SCNVector3Make(atom.x! - x!, atom.y! - y!, atom.z! - z!)
                atom.node = node
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(sender:)))
                sceneView.addGestureRecognizer(tapRecognizer)
                atomsNode.addChildNode(node)
            }
        }
        if model == true {
            for x in (self.protein?.connection)! {
                 if flag == true || (flag == false && protein?.atoms?[x.from! - 1].mol != "H" && protein?.atoms?[x.to! - 1].mol != "H") {
                    let cyl = Connection(parent: atomsNode, v1: (protein?.atoms?[x.from! - 1].node?.position)!, v2: (protein?.atoms?[x.to! - 1].node?.position)!, radius: 0.1, connectionNumber: x.nbConnect!, radSegmentCount: 180, color: UIColor.lightGray)
                    atomsNode.addChildNode(cyl)
                }
            }
        }
        
        
        geometryNode = atomsNode
        scene.rootNode.addChildNode(geometryNode!)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(sender:)))
        sceneView.addGestureRecognizer(panRecognizer)
        sceneView.addGestureRecognizer(pinchRecognizer)
        if self.flag == true {
            addAnimation()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
//        geometryNode?.removeFromParentNode()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = ""
        drawScene(flag: true, model: self.model)
        

    }

    func stopAnimation() {
        geometryNode?.removeAnimation(forKey: "spin around")
    }
    
    func addAnimation() {
        spin = CABasicAnimation(keyPath: "rotation")
        // Use from-to to explicitly make a full rotation around z
        spin?.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spin?.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(CGFloat(2 * M_PI))))
        spin?.fillMode = kCAFillModeForwards
        spin?.isRemovedOnCompletion = false
        spin?.duration = 10
        spin?.repeatCount = .infinity
        geometryNode?.addAnimation(spin!, forKey: "spin around")
    }
    
    func tapGesture (sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            let index = geometryNode?.childNodes.index(of: node)
            if index != nil {
                nameLabel.text = protein?.atoms?[index!].mol!   
            }
            else {
                nameLabel.text = ""
            }
            
        }
        else {
            nameLabel.text = ""
        }
    }
    
    func zoom(scale: Double){
            self.cameraNode?.camera!.xFov = scale
            self.cameraNode?.camera!.yFov = scale
    }
    
    func pinchGesture(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        switch sender.state {
        case .changed:
             zoom(scale: Double(25/scale))
        default:
            break
        }
        
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            stopAnimation()
        }
        let translation = sender.translation(in: sender.view!)
        
        let x = Float(translation.x)
        let y = Float(-translation.y)
        
        let anglePan = sqrt(pow(x,2)+pow(y,2))*(Float)(M_PI)/180.0
        
        var rotationVector = SCNVector4()
        rotationVector.x = -y
        rotationVector.y = x
        rotationVector.z = 0
        rotationVector.w = anglePan
        
        geometryNode?.rotation = rotationVector
        
        if(sender.state == UIGestureRecognizerState.ended) {
            
            let currentPivot = geometryNode?.pivot
            let changePivot = SCNMatrix4Invert((geometryNode?.transform)!)
            
            geometryNode?.pivot = SCNMatrix4Mult(changePivot, currentPivot!)
            geometryNode?.transform = SCNMatrix4Identity
            if flag == true {
                 addAnimation()
            }
            
        }
    }
}

class   Connection: SCNNode
{
    init( parent: SCNNode,
        v1: SCNVector3,
        v2: SCNVector3,
        radius: CGFloat,
        connectionNumber: Int = 1,
        radSegmentCount: Int,
        color: UIColor )
    {
        super.init()
        

        let height = v1.distance(v2)
        

        position = v1
        

        let nodeV2 = SCNNode()

        nodeV2.position = v2

        parent.addChildNode(nodeV2)
        

        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(CGFloat(M_PI_2))
        

        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        cyl.firstMaterial?.diffuse.contents = color
        
        let nodeCyl = SCNNode(geometry: cyl)
        nodeCyl.position.y = -height/2
        
        if (connectionNumber == 2) {
            nodeCyl.position.x = -0.2
            
            let nodeCyl2 = SCNNode(geometry: cyl)
            nodeCyl2.position.y = -height/2
            nodeCyl2.position.x = 0.2
            zAlign.addChildNode(nodeCyl2)
        } else if (connectionNumber == 3) {
            nodeCyl.position.x = -0.07
            nodeCyl.position.z = -0.07
            
            let nodeCyl2 = SCNNode(geometry: cyl)
            nodeCyl2.position.y = -height/2
            nodeCyl2.position.x = 0.07
            nodeCyl2.position.z = -0.07
            let nodeCyl3 = SCNNode(geometry: cyl)
            nodeCyl3.position.y = -height/2
            nodeCyl3.position.z = 0.07
            
            zAlign.addChildNode(nodeCyl2)
            zAlign.addChildNode(nodeCyl3)
        }
        
        zAlign.addChildNode(nodeCyl)
        
        addChildNode(zAlign)
        
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


private extension SCNVector3{
    func distance(_ receiver:SCNVector3) -> Float{
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
}
