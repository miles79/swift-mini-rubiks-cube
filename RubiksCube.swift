//
//  RubiksCube.swift
//  SceneKitDemo
//
//  Created by Miles McLeod on 2016-04-11.
//  Copyright © 2016 Miles McLeod. All rights reserved.
//

import SceneKit

class RubiksCube : SCNNode {
    
    let cubeWidth:Float = 0.95
    let spaceBetweenCubes:Float = 0.05
    
    override init() {
        
        super.init()
        
        //define material used for making the rubiks cube
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
        
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor.yellow
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.orange
        
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        
        // create the cube
        let cubeOffsetDistance = self.cubeOffsetDistance()
        
        var xPos:Float = -cubeOffsetDistance
        var yPos:Float = -cubeOffsetDistance
        var zPos:Float = -cubeOffsetDistance
        for i in 0..<2 {
            for j in 0..<2 {
                for k in 0..<2 {
                    let cubeGeometry = SCNBox(width: CGFloat(cubeWidth), height: CGFloat(cubeWidth), length: CGFloat(cubeWidth), chamferRadius: 0)
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
                    xPos += cubeWidth + spaceBetweenCubes
                    self.addChildNode(cube)
                }
                xPos = -cubeOffsetDistance
                yPos += cubeWidth + spaceBetweenCubes
            }
            xPos = -cubeOffsetDistance
            yPos = -cubeOffsetDistance
            zPos += cubeWidth + spaceBetweenCubes
        }
    }
    
    private func cubeOffsetDistance()->Float {
        return (cubeWidth + spaceBetweenCubes) / 2
    }
    
    func getSouthWall()->[SCNNode] {
        let southWallNodes = self.childNodes { (child, stop) -> Bool in
            return child.position.z.nearlyEqual(self.cubeOffsetDistance(), epsilon: 0.01)
        }
        return southWallNodes
    }
    
    func getNorthWall()->[SCNNode] {
        let northWallNodes = self.childNodes { (child, stop) -> Bool in
            return child.position.z.nearlyEqual(-self.cubeOffsetDistance(), epsilon: 0.01)
        }
        return northWallNodes
    }
    
    func isNorthWallSolved()->Bool {
        let northWallNodes = getNorthWall()
        let material = northWallNodes[0].geometry?.materials[0]
        for i in 1..<northWallNodes.count {
            if material != northWallNodes[i].geometry?.materials[0] {
                return false
            }
        }
        return true
    }
    
    func isSolved()->Bool {
        // this is a stub
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
