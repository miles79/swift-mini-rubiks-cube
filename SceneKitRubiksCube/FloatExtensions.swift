//
//  FloatExtensions.swift
//  SceneKitDemo
//
//  Created by Miles McLeod on 2016-04-10.
//  Copyright © 2016 Miles McLeod. All rights reserved.
//

import Darwin

extension Float {
    func nearlyEqual(_ b: Float, epsilon: Float) -> Bool {
        let a = self;
        let absA = abs(a);
        let absB = abs(b);
        let diff = abs(a - b);
    
        if (a == b) { // shortcut, handles infinities
            return true;
        } else if (a == 0 || b == 0 || diff <  Float.leastNormalMagnitude) {
            // a or b is zero or both are extremely close to it
            // relative error is less meaningful here
            return diff < (epsilon * Float.leastNormalMagnitude);
        } else { // use relative error
            return diff / (absA + absB) < epsilon;
        }
    }
}
