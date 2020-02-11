//
//  ViewController.swift
//  ImageTracking
//
//  Created by Chenxi Jia on 11/02/2020.
//  Copyright © 2020 Chenxi Jia. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        sceneView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("Missing expected asset catalog resources.")
        }

        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = refImages
//        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: [.resetTracking, .removeExistingAnchors]))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        // Delegate rendering tasks to our `updateQueue` thread to keep things thread-safe!
        let physicalWidth = imageAnchor.referenceImage.physicalSize.width
        let physicalHeight = imageAnchor.referenceImage.physicalSize.height
     
        // Create a plane geometry to visualize the initial position of the detected image
        let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
        
        // This bit is important. It helps us create occlusion so virtual things stay hidden behind the detected image
        mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
        
        // Create a SceneKit root node with the plane geometry to attach to the scene graph
        // This node will hold the virtual UI in place
        let mainNode = SCNNode(geometry: mainPlane)
        mainNode.eulerAngles.x = -.pi / 2
        mainNode.renderingOrder = -1
        mainNode.opacity = 1
        let sphere = SCNSphere(radius: 1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0,0,4)
        mainNode.addChildNode(sphereNode)
        node.addChildNode(mainNode)
    }
}

