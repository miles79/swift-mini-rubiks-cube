//
//  ViewController.swift
//  SceneKitDemo
//
//  Created by Miles McLeod on 2016-03-10.
//  Copyright © 2016 Miles McLeod. All rights reserved.
//

import UIKit
import SceneKit
import OpenGLES

class ViewController: UIViewController {
    
    // REVISE THIS FOR DEVICE ORIENTATION
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var lightNode: SCNNode!
    var cubeWall: SCNNode!

    var beganPanHitResult: SCNHitTestResult!
    var beganPanNode: SCNNode!
    
    var rotationAxis:SCNVector3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /////////////////////////////////////
        screenWidth = Float(screenSize.width)
        screenHeight = Float(screenSize.height)
        /////////////////////////////////////
        
        // set up the scene
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = UIColor(red: 0.3, green: 0.72, blue: 0.65, alpha: 1)
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
        
        //define material used for making the rubiks cube
        let cubeWidth:CGFloat = 0.95
        
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.greenColor()
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.redColor()
        
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blueColor()
        
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor.yellowColor()
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.whiteColor()
        
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.orangeColor()
        
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.blackColor()
        
        // create rubiks cube and add it to the scene
        cubeWall = SCNNode()
        
        var xPos:Float = -0.5
        var yPos:Float = -0.5
        var zPos:Float = -0.5
        for i in 0..<2 {
            for j in 0..<2 {
                for k in 0..<2 {
                    let cubeGeometry = SCNBox(width: cubeWidth, height: cubeWidth, length: cubeWidth, chamferRadius: 0)
                    if i == 0 && j == 0 {
                    cubeGeometry.materials = (k % 2 == 0) ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, blackMaterial, whiteMaterial] : [blackMaterial, redMaterial, blueMaterial, blackMaterial, blackMaterial, whiteMaterial]
                    }
                    if i == 0 && j == 1 {
                        cubeGeometry.materials = (k % 2 == 0) ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, yellowMaterial, blackMaterial] : [blackMaterial, redMaterial, blueMaterial, blackMaterial, yellowMaterial, blackMaterial]
                    }
                    if i == 1 && j == 0 {
                        cubeGeometry.materials = (k % 2 == 0) ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, blackMaterial, whiteMaterial] : [greenMaterial, redMaterial, blackMaterial, blackMaterial, blackMaterial, whiteMaterial]
                    }
                    if i == 1 && j == 1 {
                        cubeGeometry.materials = (k % 2 == 0) ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, yellowMaterial, blackMaterial] : [greenMaterial, redMaterial, blackMaterial, blackMaterial, yellowMaterial, blackMaterial]
                    }
 

                    let cube = SCNNode(geometry: cubeGeometry)
                    cube.position = SCNVector3(x: xPos, y: yPos, z: zPos)
                    xPos += Float(cubeWidth) + 0.05
                    cubeWall.addChildNode(cube)
                }
                xPos = -0.5
                yPos += Float(cubeWidth) + 0.05
            }
            xPos = -0.5
            yPos = -0.5
            zPos += Float(cubeWidth) + 0.05
        }
        rootNode.addChildNode(cubeWall)
        
        // create and add camera to the scene
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true;
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3Make(0, 0, 0);
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -15); //the -15 here will become the rotation radius
        
        // set gesture recognizers
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: "scenePanned:")
        sceneView.gestureRecognizers = [panRecognizer]
    }
    
    // gesture handlers
    func scenePanned(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        // two fingers: camera rotation
        if recognizer.numberOfTouches() == 2 {
            let xVelocity = Float(recognizer.velocityInView(sceneView).x) * 0.1
            let yVelocity = Float(recognizer.velocityInView(sceneView).y) * 0.1
            
            let oldRot = cameraNode.rotation as SCNQuaternion;
            var rot = GLKQuaternionMakeWithAngleAndAxis(oldRot.w, oldRot.x, oldRot.y, oldRot.z)
            
            let rotX = GLKQuaternionMakeWithAngleAndAxis(-xVelocity/screenWidth, 0, 1, 0)
            let rotY = GLKQuaternionMakeWithAngleAndAxis(-yVelocity/screenHeight, 1, 0, 0)
            let netRot = GLKQuaternionMultiply(rotX, rotY)
            rot = GLKQuaternionMultiply(rot, netRot)
            
            let axis = GLKQuaternionAxis(rot)
            let angle = GLKQuaternionAngle(rot)
            
            cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
        }
        
        // 1 finger on cube: rotate cube section
        if recognizer.numberOfTouches() == 1 && hitResults.count > 0 && recognizer.state == UIGestureRecognizerState.Began {
            beganPanHitResult = hitResults[0]
            print(beganPanHitResult.worldCoordinates)
            beganPanNode = hitResults[0].node
                        print(beganPanNode.position);
        }
        
        else if recognizer.state == UIGestureRecognizerState.Ended && beganPanNode != nil {
            let locationView = recognizer.locationInView(sceneView);
            let projectedOrigin = sceneView.projectPoint(beganPanHitResult.worldCoordinates);
            
            let estimatedPoint = sceneView.unprojectPoint(SCNVector3( Float(locationView.x), Float(locationView.y), projectedOrigin.z) );
            var plane = "?";
            var direction = 1;
            
            let xDiff = estimatedPoint.x - beganPanHitResult.worldCoordinates.x;
            let yDiff = estimatedPoint.y - beganPanHitResult.worldCoordinates.y;
            let zDiff = estimatedPoint.z - beganPanHitResult.worldCoordinates.z;
            
            let absXDiff = abs(xDiff)
            let absYDiff = abs(yDiff)
            let absZDiff = abs(zDiff)
            
            var side = "?";
            
            if beganPanHitResult.worldCoordinates.x.nearlyEqual(0.975, epsilon: 0.025) {
                side = "EAST";
            }
            else if beganPanHitResult.worldCoordinates.x.nearlyEqual(-0.975, epsilon: 0.025) {
                side = "WEST";
            }
            else if beganPanHitResult.worldCoordinates.y.nearlyEqual(0.975, epsilon: 0.025) {
                side = "TOP";
            }
            else if beganPanHitResult.worldCoordinates.y.nearlyEqual(-0.975, epsilon: 0.025) {
                side = "BOTTOM";
            }
            else if beganPanHitResult.worldCoordinates.z.nearlyEqual(0.975, epsilon: 0.025) {
                side = "SOUTH";
            }
            else if beganPanHitResult.worldCoordinates.z.nearlyEqual(-0.975, epsilon: 0.025) {
                side = "NORTH";
            }
            
            if side == "EAST" || side == "WEST" {
                if absYDiff > absZDiff {
                    plane = "Y";
                    if side == "EAST" {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Z";
                    if side == "EAST" {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                }
            }
            else if side == "TOP" || side == "BOTTOM" {
                if absXDiff > absZDiff {
                    plane = "X";
                    if side == "TOP" {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                }
                else {
                    plane = "Z"
                    if side == "TOP" {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                }
            }
            else if side == "SOUTH" || side == "NORTH" {
                if absXDiff > absYDiff {
                    plane = "X";
                    if side == "SOUTH" {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Y"
                    if side == "SOUTH" {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            //
            // START ANIMATING
            //

            // get the nodes we want to rotate
            let nodesToRotate =  cubeWall.childNodesPassingTest { (child, stop) -> Bool in
                if ((side == "EAST" || side == "WEST") && plane == "Z")
                    || ((side == "NORTH" || side == "SOUTH") && plane == "X") {
                        self.rotationAxis = SCNVector3(0,1,0);
                    return child.position.y.nearlyEqual(self.beganPanNode.position.y, epsilon: 0.025)
                }
                if ((side == "EAST" || side == "WEST") && plane == "Y")
                    || ((side == "TOP" || side == "BOTTOM") && plane == "X") {
                        self.rotationAxis = SCNVector3(0,0,1);
                        return child.position.z.nearlyEqual(self.beganPanNode.position.z, epsilon: 0.025)
                }
                if ((side == "NORTH" || side == "SOUTH") && plane == "Y")
                    || ((side == "TOP" || side == "BOTTOM") && plane == "Z") {
                        self.rotationAxis = SCNVector3(1,0,0);
                        return child.position.x.nearlyEqual(self.beganPanNode.position.x, epsilon: 0.025)
                }
                return false;
            }
            
            // this shouldnt happen, so bounce out
            if nodesToRotate.count <= 0 {
                return
            }
            // add nodes we want to rotate to a parent node so that we can rotate relative to the root
            let container = SCNNode()
            rootNode.addChildNode(container)
            for nodeToRotate in nodesToRotate {
                container.addChildNode(nodeToRotate)
            }
            
            let rotationAngle = CGFloat(direction) * CGFloat(M_PI_2);
            print(rotationAngle);
            // create action
            let actionTest = SCNAction.rotateByAngle(rotationAngle, aroundAxis: self.rotationAxis, duration: 1)
            
            // apply action and remove nodes from container and add back to root
            container.runAction(actionTest, completionHandler: { () -> Void in
                for node: SCNNode in nodesToRotate {
                    let transform = node.parentNode!.convertTransform(node.transform, toNode: self.cubeWall)
                    node.removeFromParentNode()
                    node.transform = transform
                    self.cubeWall.addChildNode(node)
                }
            })
            beganPanNode = nil;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

