//
//  HanoiScene.swift
//  SceneKitDemo
//
//  Created by Miles McLeod on 2016-03-10.
//  Copyright © 2016 Miles McLeod. All rights reserved.
//

import SceneKit

class HanoiScene : SCNScene {
    
    override init() {
        super.init()
        createBoard()
        createPegs()
        createDisks()
        
        hanoiSolver = HanoiSolver(numberOfDisks: self.numberOfDisks)
        playAnimation()
    }
    
    let diskRadius:CGFloat = 1.0
    var boardWidth:CGFloat = 0.0
    var boardLength:CGFloat = 0.0
    let boardPadding:CGFloat = 0.8
    let boardHeight:CGFloat = 0.2
    
    var numberOfDisks = 4
    
    let diskHeight:CGFloat = 0.2
    
    var pegHeight:CGFloat = 0.0
    let pegRadius:CGFloat = 0.1
    var pegs: [SCNNode] = []
    
    var disks: [SCNNode] = []
    
    var hanoiSolver:HanoiSolver!
    
    func createBoard() {
        boardWidth = diskRadius * 6.0 + boardPadding
        boardLength = diskRadius * 2.0 + boardPadding
        
        let boardColor = UIColor.brownColor()
        
        let boardGeometry = SCNBox(width: boardWidth, height: boardHeight, length: boardLength, chamferRadius: 0.1)
        boardGeometry.firstMaterial?.diffuse.contents = boardColor
        
        let boardNode = SCNNode(geometry: boardGeometry)
        
        rootNode.addChildNode(boardNode)
    }
    
    func createPegs() {
        // Create the 3 Pegs on the board
        
        pegHeight = CGFloat(numberOfDisks + 1) * diskHeight
        
        var x:Float = Float(-boardWidth) / 2.0 + Float(boardPadding) / 2.0 + Float(diskRadius)
        
        for i in 0..<3 {
            let cylinder = SCNCylinder(radius: pegRadius, height: pegHeight)
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinder.firstMaterial?.diffuse.contents = UIColor.brownColor()
            
            cylinderNode.position.x = x
            cylinderNode.position.y = Float(pegHeight / 2.0 + boardHeight / 2.0)
            
            rootNode.addChildNode(cylinderNode)
            pegs.append(cylinderNode)
            
            x += Float(diskRadius * 2)
        }
    }
    
    func createDisks() {
        var firstPeg = pegs[0]
        
        var y:Float = Float(boardHeight / 2.0 + diskHeight / 2.0)
        
        var radius:CGFloat = diskRadius
        for i in 0..<numberOfDisks {
            
            let tube = SCNTube(innerRadius: pegRadius, outerRadius: radius, height: diskHeight)
            
            let hue = CGFloat(i) / CGFloat(numberOfDisks)
            let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            tube.firstMaterial?.diffuse.contents = color
            
            let tubeNode = SCNNode(geometry: tube)
            
            tubeNode.position.x = firstPeg.position.x
            tubeNode.position.y = y
            
            rootNode.addChildNode(tubeNode)
            disks.append(tubeNode)
            
            y += Float(diskHeight)
            radius -= 0.1
        }
    }
    
    func lengthOfVector(v: SCNVector3) -> Float {
        return sqrt(pow(v.x,2.0) + pow(v.y,2.0) + pow(v.z,2.0))
    }
    
    func distanceBetweenVectors(v1 : SCNVector3, v2: SCNVector3) -> Float {
        return lengthOfVector(SCNVector3(x: v1.x - v2.x, y: v1.y - v2.y, z: v1.z - v2.z))
    }
    
    func normalizedDuration(startPosition: SCNVector3, endPosition: SCNVector3) -> Double {
        
        let referenceLength = distanceBetweenVectors(pegs[0].position, v2: pegs[2].position)
        
        let length = distanceBetweenVectors(startPosition, v2: endPosition)
        
        return 0.3 * Double(length / referenceLength)
    }
    
    func animationFromMove(move: HanoiMove) -> SCNAction {
        var duration = 0.0
        
        let node = disks[move.diskIndex]
        let destination = pegs[move.destinationPegIndex]
        
        // Move To Top
        var topPosition = node.position
        topPosition.y = Float(pegHeight + diskHeight * 4.0)
        
        duration = normalizedDuration(node.position, endPosition: topPosition)
        let moveUp = SCNAction.moveTo(topPosition, duration: duration)
        
        // Move Sideways
        var sidePosition = destination.position
        sidePosition.y = topPosition.y
        
        duration = normalizedDuration(topPosition, endPosition: sidePosition)
        let moveSide = SCNAction.moveTo(sidePosition, duration: duration)
        
        // Move To Bottom
        var bottomPosition = sidePosition
        bottomPosition.y = Float(boardHeight / 2.0 + diskHeight / 2.0) + Float(move.destinationDiskCount) * Float(diskHeight)
        
        duration = normalizedDuration(sidePosition, endPosition: bottomPosition)
        let moveDown = SCNAction.moveTo(bottomPosition,duration: duration)
        
        let sequence = SCNAction.sequence([moveUp, moveSide, moveDown])
        
        
        return sequence
    }
    
    func recursiveAnimation(index: Int) {
        
        let move = hanoiSolver.moves[index]
        let node = disks[move.diskIndex]
        let animation = animationFromMove(move)
        
        node.runAction(animation, completionHandler: {
            if (index + 1 < self.hanoiSolver.moves.count) {
                self.recursiveAnimation(index + 1)
            }
        })
    }
    
    func playAnimation() {
        hanoiSolver.computeMoves()
        recursiveAnimation(0)
    }
    
    func resetDisks(N: Int) {
        self.numberOfDisks = N
        
        for peg in pegs {
            peg.removeAllAnimations()
            peg.removeFromParentNode()
        }
        pegs = []
        createPegs()
        
        for disk in disks {
            disk.removeFromParentNode()
        }
        disks = []
        createDisks()
        
        hanoiSolver = HanoiSolver(numberOfDisks: self.numberOfDisks)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}