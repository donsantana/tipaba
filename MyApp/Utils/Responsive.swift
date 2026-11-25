//
//  Responsive.swift
//  Tipaba
//
//  Created by Done Santana on 10/25/26.
//

import CoreGraphics


class Responsive{
    
    private(set) static var width = 0.0
    private(set) static var height = 0.0
    private(set) static var inch = 0.0
    
    init(size: CGSize){
        Self.width = Double(size.width)
        Self.height = Double(size.height)
        
        // c2 = a2+b2
        Self.inch = sqrt(pow(Self.width, 2) + pow(Self.height, 2))
    }
    
    
    //width percent value
    static func widthPercent(percent: Double) -> Double{
        return Double(width * percent / 100)
    }
    
    //height percent value
    static func heightPercent(percent: Double) -> Double{
        return Double(height * percent / 100)
    }
    
    //inch percent value
    static func inchPercent(percent: Double) -> Double{
        return Double(inch * percent / 100)
    }
    
    //width percent value
    static func widthFloatPercent(percent: Double) -> CGFloat{
        return CGFloat(width * percent / 100)
    }
    
    //height percent value
    static func heightFloatPercent(percent: Double) -> CGFloat{
        return CGFloat(height * percent / 100)
    }
    
    static func distanceBtwElement(elementWidth: Double, elementCount: Int)->CGFloat{
        return CGFloat(width - (elementWidth * Double(elementCount))) / (CGFloat(elementCount) + 1.0)
    }
    
}
