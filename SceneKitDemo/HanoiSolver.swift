//
//  HanoiSolver.swift
//  SceneKitDemo
//
//  Created by Miles McLeod on 2016-03-11.
//  Copyright © 2016 Miles McLeod. All rights reserved.
//

    struct HanoiMove {
        var diskIndex: Int
        var destinationDiskCount: Int
        var destinationPegIndex: Int
        
        init(diskIndex: Int,destinationPegIndex: Int,destinationDiskCount: Int) {
            self.diskIndex = diskIndex
            self.destinationDiskCount = destinationDiskCount
            self.destinationPegIndex = destinationPegIndex
        }
    }

class HanoiSolver {
    
    var numberOfDisks:Int
    var leftPeg: [Int]
    var middlePeg: [Int]
    var rightPeg: [Int]
    
    var pegs: [[Int]]
    var moves: [HanoiMove]

    
    init(numberOfDisks: Int) {
        self.numberOfDisks = numberOfDisks
        
        self.leftPeg = []
        for i in 0..<numberOfDisks {
            self.leftPeg.append(i)
        }
        
            self.middlePeg = []
            self.rightPeg = []
            self.pegs = [leftPeg, middlePeg, rightPeg]
            self.moves = []
    }
    
    func hanoi(numberOfDisks: Int, from: Int, using: Int, to: Int) {
        if numberOfDisks == 1 {
            move(from, to: to)
        } else {
            hanoi(numberOfDisks - 1, from: from, using: to, to: using)
            move(from, to: to)
            hanoi(numberOfDisks - 1, from: using, using: from, to: to)
        }
    }
    
    func move(from: Int, to: Int) {
        var disk = popDisk(from)
        var diskIndex = disk
        var destinationDiskCount = pegs[to].count
        
        pushDisk(disk, peg: to)
        
        let move = HanoiMove(diskIndex: diskIndex, destinationPegIndex: to, destinationDiskCount: destinationDiskCount)
        moves.append(move)
    }
    
    func popDisk(peg: Int) -> Int {
        return pegs[peg].removeLast()
    }
    
    func pushDisk(disk: Int, peg: Int) {
        pegs[peg].append(disk)
    }
    
    func computeMoves() {
        self.moves = []
        hanoi(numberOfDisks, from: 0, using: 1, to: 2)
    }
}