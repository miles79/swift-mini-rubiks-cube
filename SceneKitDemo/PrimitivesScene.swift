//
//  PrimitivesScene.swift
//  SceneKitDemo
//
//  Created by Miles McLeod on 2016-03-10.
//  Copyright © 2016 Miles McLeod. All rights reserved.
//

import SceneKit

class PrimitivesScene: SCNScene {
    
    override init() {
        super.init()
        
        let numberOfTori = 6
        var cylinderRadius:CGFloat = 0.5
        var pipeRadius:CGFloat = 0.3
        
        var cylinderHeight:CGFloat = 2.5
        
        let cylinder = SCNCone(topRadius: 0.15, bottomRadius: cylinderRadius, height: cylinderHeight)
        
        let cylinderNode = SCNNode(geometry: cylinder)
        
        cylinderNode.position.y += Float(cylinderHeight) / 2.0 - Float(pipeRadius)
        
        var y:Float = 0.0
        for index in 0..<numberOfTori {
            let torus = SCNTorus(ringRadius: cylinderRadius + pipeRadius, pipeRadius: pipeRadius)
            
            let hue:CGFloat = CGFloat(index) / CGFloat(numberOfTori)
            let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            
            torus.firstMaterial?.diffuse.contents = color
            torus.firstMaterial?.transparency = 0.8
            
            let torusNode = SCNNode(geometry: torus)
            
            torusNode.position = SCNVector3(x: 0.0, y: y, z: 0.0)
            
            self.rootNode.addChildNode(torusNode)
            
            y += Float(pipeRadius)
            
            print(cylinderRadius)
            
            cylinderRadius *= 0.8
            pipeRadius *= 0.8
            
            
            y += Float(pipeRadius)
        }
        
        self.rootNode.addChildNode(cylinderNode)
        /*
        let sphere = SCNSphere(radius: 1.0)
        sphere.firstMaterial?.diffuse.contents = UIColor.redColor()
        let sphereNode = SCNNode(geometry: sphere)
        
        self.rootNode.addChildNode(sphereNode)
        
        let moveUp = SCNAction.moveByX(0.0, y: 1.0, z: 0.0, duration: 1.0)
        let moveDown = SCNAction.moveByX(0.0, y: -1.0, z: 0.0, duration: 1.0)
        let sequence = SCNAction.sequence([moveUp,moveDown])
        let repeatedSequence = SCNAction.repeatActionForever(sequence)
        sphereNode.runAction(repeatedSequence)
        */
        /*
        var geometries = [SCNSphere(radius: 1.0),
        SCNPlane(width: 1.0, height: 1.5),
        SCNBox(width: 1.0, height: 1.5, length: 2.0, chamferRadius: 0.0),
        SCNPyramid(width: 2.0, height: 1.5, length: 1.0),
        SCNCylinder(radius: 1.0, height: 1.5),
        SCNCone(topRadius: 0.5, bottomRadius: 1.0, height: 1.5),
        SCNTorus(ringRadius: 1.0, pipeRadius: 0.2),
        SCNTube(innerRadius: 0.5, outerRadius: 1.0, height: 1.5),
        SCNCapsule(capRadius: 0.5, height: 2.0)]
        
        var angle:Float = 0.0
        let radius:Float = 4.0
        let angleIncrement:Float = Float(M_PI) * 4.0 / Float(geometries.count)
        var y:Float = 0
        
        for index in 0..<geometries.count {
        
        let hue:CGFloat = CGFloat(index) / CGFloat(geometries.count)
        let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        let geometry = geometries[index]
        geometry.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode(geometry: geometry)
        
        let x = radius * cos(angle)
        let z = radius * sin(angle)
        
        node.position = SCNVector3(x: x, y: y, z: z)
        
        self.rootNode.addChildNode(node)
        
        y += 2
        angle += angleIncrement
        }
        */
        /*
        var x:Float = 0
        var y:Float = 0
        var z:Float = 0
        let numberOfSpheres = 6
        let sphereRadius:CGFloat = 1.0
        
        for i in 0...numberOfSpheres {
        for j in 0...numberOfSpheres {
        for k in 0...numberOfSpheres {
        if (k == 0) || (k == numberOfSpheres) || (i == 0) || (i == numberOfSpheres) || (j == 0) || (j == numberOfSpheres) {
        let sphereGeometry = SCNSphere(radius: sphereRadius)
        let sphereColor = j % 2 == 0 ? UIColor.purpleColor() : UIColor.orangeColor()
        sphereGeometry.firstMaterial?.diffuse.contents = sphereColor
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = SCNVector3(x: x, y: y, z: z)
        self.rootNode.addChildNode(sphereNode)
        }
        
        x += Float(2*sphereRadius)
        }
        x = 0
        y += Float(2*sphereRadius)
        }
        x = 0
        y = 0
        z += Float(2*sphereRadius)
        }
        */
        /*
        x = 0
        y = 0
        var n = 20
        for i in 0...numberOfSpheres {
        for j in 0...n {
        let sphereGeometry = SCNSphere(radius: sphereRadius)
        let sphereColor = j % 2 == 0 ? UIColor.purpleColor() : UIColor.orangeColor()
        sphereGeometry.firstMaterial?.diffuse.contents = sphereColor
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = SCNVector3(x: x, y: y, z: z)
        self.rootNode.addChildNode(sphereNode)
        
        x += Float(2*sphereRadius)
        }
        x = Float(i + 1) * Float(sphereRadius)
        y += Float(2*sphereRadius)
        n--
        }
        */
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
