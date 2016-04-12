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
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    @IBOutlet var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var lightNode: SCNNode!
    var rubiksCube: RubiksCube!

    var beganPanHitResult: SCNHitTestResult!
    var beganPanNode: SCNNode!
    
    var animationLock = false
    
    enum CubeSide {
        case North
        case South
        case East
        case West
        case Top
        case Bottom
        case None
    }
    
    var rotationAxis:SCNVector3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidth = Float(screenSize.width)
        screenHeight = Float(screenSize.height)
        
        // set up the scene
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = UIColor(red: 0.3, green: 0.72, blue: 0.65, alpha: 1)
        
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
 
        // create and add rubiks cube to the scene
        rubiksCube = RubiksCube()
        rootNode.addChildNode(rubiksCube)
        
        // create and add camera to the scene
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true;
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3Make(0, 0, 0);
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -8); //-8 here will become the rotation radius
        
        // set gesture recognizers
        let pinchRecognizer = UIPinchGestureRecognizer()
        pinchRecognizer.addTarget(self, action: "scenePinched")
        
        let rotationRecognizer = UIRotationGestureRecognizer()
        rotationRecognizer.addTarget(self, action: "sceneRotated:")
        
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: "scenePanned:")
        
        sceneView.gestureRecognizers = [rotationRecognizer, panRecognizer]
    }
    
    // gesture handlers
    func scenePinched(recognizer: UIPinchGestureRecognizer) {
        //print(recognizer.velocity)
        //cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, recognizer.scale);
    }
    
    func sceneRotated(recognizer: UIRotationGestureRecognizer) {
        let oldRot = cameraNode.rotation as SCNQuaternion;
        var rot = GLKQuaternionMakeWithAngleAndAxis(oldRot.w, oldRot.x, oldRot.y, oldRot.z)
        
        let MAX_ROTATION_SPEED:CGFloat = 1
        var velocity = recognizer.velocity
        if recognizer.velocity > 1 {
            velocity = MAX_ROTATION_SPEED
        }
        else if recognizer.velocity < -1 {
            velocity = -MAX_ROTATION_SPEED
        }

        let rotZ = GLKQuaternionMakeWithAngleAndAxis(0.1*Float(velocity), 0, 0, 1)
        
        rot = GLKQuaternionMultiply(rot, rotZ)
        
        let axis = GLKQuaternionAxis(rot)
        let angle = GLKQuaternionAngle(rot)
        
        cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
    }
    
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
        if recognizer.numberOfTouches() == 1
            && hitResults.count > 0
            && recognizer.state == UIGestureRecognizerState.Began
            && beganPanNode == nil {

            beganPanHitResult = hitResults[0]
            beganPanNode = hitResults[0].node
        }
        
        else if recognizer.state == UIGestureRecognizerState.Ended && beganPanNode != nil && animationLock == false {
            animationLock = true
            
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
            
            var side:CubeSide!;
            
            side = resolveCubeSize(beganPanHitResult, edgeDistanceFromOrigin: 0.975)
            
            if side == CubeSide.None {
                self.animationLock = false;
                self.beganPanNode = nil;
                return
            }
            
            if side == CubeSide.East || side == CubeSide.West {
                if absYDiff > absZDiff {
                    plane = "Y";
                    if side == CubeSide.East {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Z";
                    if side == CubeSide.East {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                }
            }
            else if side == CubeSide.Top || side == CubeSide.Bottom {
                if absXDiff > absZDiff {
                    plane = "X";
                    if side == CubeSide.Top {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                }
                else {
                    plane = "Z"
                    if side == CubeSide.Top {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                }
            }
            else if side == CubeSide.South || side == CubeSide.North {
                if absXDiff > absYDiff {
                    plane = "X";
                    if side == CubeSide.South {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Y"
                    if side == CubeSide.South {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            // get the nodes we want to rotate
            let nodesToRotate =  rubiksCube.childNodesPassingTest { (child, stop) -> Bool in
                if ((side == CubeSide.East || side == CubeSide.West) && plane == "Z")
                    || ((side == CubeSide.North || side == CubeSide.South) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,1,0);
                    return child.position.y.nearlyEqual(self.beganPanNode.position.y, epsilon: 0.025)
                }
                if ((side == CubeSide.East || side == CubeSide.West) && plane == "Y")
                    || ((side == CubeSide.Top || side == CubeSide.Bottom) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,0,1);
                        return child.position.z.nearlyEqual(self.beganPanNode.position.z, epsilon: 0.025)
                }
                if ((side == CubeSide.North || side == CubeSide.South) && plane == "Y")
                    || ((side == CubeSide.Top || side == CubeSide.Bottom) && plane == "Z") {
                        self.rotationAxis = SCNVector3(1,0,0);
                        return child.position.x.nearlyEqual(self.beganPanNode.position.x, epsilon: 0.025)
                }
                return false;
            }
            
            // this shouldnt happen, so exit
            if nodesToRotate.count <= 0 {
                self.animationLock = false;
                self.beganPanNode = nil;
                return
            }
            // add nodes we want to rotate to a parent node so that we can rotate relative to the root
            let container = SCNNode()
            rootNode.addChildNode(container)
            for nodeToRotate in nodesToRotate {
                container.addChildNode(nodeToRotate)
            }
            
            let rotationAngle = CGFloat(direction) * CGFloat(M_PI_2);

            // create action
            let actionTest = SCNAction.rotateByAngle(rotationAngle, aroundAxis: self.rotationAxis, duration: 0.5)
            
            // apply action and remove nodes from container and add back to root
            container.runAction(actionTest, completionHandler: { () -> Void in
                for node: SCNNode in nodesToRotate {
                    let transform = node.parentNode!.convertTransform(node.transform, toNode: self.rubiksCube)
                    node.removeFromParentNode()
                    node.transform = transform
                    self.rubiksCube.addChildNode(node)
                }
                print(self.rubiksCube.isNorthWallSolved())
                self.animationLock = false
                self.beganPanNode = nil
            })
        }
    }
    
    private func resolveCubeSize(hitResult: SCNHitTestResult, edgeDistanceFromOrigin:Float)->CubeSide {
        
        if beganPanHitResult.worldCoordinates.x.nearlyEqual(edgeDistanceFromOrigin, epsilon: 0.025) {
            return CubeSide.East
        }
        else if beganPanHitResult.worldCoordinates.x.nearlyEqual(-edgeDistanceFromOrigin, epsilon: 0.025) {
            return CubeSide.West
        }
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(edgeDistanceFromOrigin, epsilon: 0.025) {
            return CubeSide.Top
        }
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(-edgeDistanceFromOrigin, epsilon: 0.025) {
            return CubeSide.Bottom
        }
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(edgeDistanceFromOrigin, epsilon: 0.025) {
            return CubeSide.South
        }
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(-edgeDistanceFromOrigin, epsilon: 0.025) {
            return CubeSide.North
        }
        return CubeSide.None
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

