//
//  BubbleDataEntry.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2019 Leonardo BOK
//    Licensed under Apache License 2.0
//
//  https://github.com/assistar/Charts
//

import Foundation

open class BlockChartDataEntry: ChartDataEntry {
    /// The level of the block.
    @objc open var level: Int = 0
    
    public required init()
    {
        super.init()
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - level: The level of the block.
    @objc public init(x: Double, y: Double, level: Int)
    {
        super.init(x: x, y: y)
        
        self.level = level
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - level: The level of the block.
    ///   - data: Spot for additional data this Entry represents.
    @objc public convenience init(x: Double, y: Double, level: Int, data: Any?)
    {
        self.init(x: x, y: y, level: level)
        self.data = data
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The level of the block.
    ///   - icon: icon image
    @objc public convenience init(x: Double, y: Double, level: Int, icon: NSUIImage?)
    {
        self.init(x: x, y: y, level: level)
        self.icon = icon
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The level of the block.
    ///   - icon: icon image
    ///   - data: Spot for additional data this Entry represents.
    @objc public convenience init(x: Double, y: Double, level: Int, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, y: y, level: level)
        self.icon = icon
        self.data = data
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! BlockChartDataEntry
        copy.level = level
        return copy
    }
}
