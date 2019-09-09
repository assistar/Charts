//
//  BlockChartDataSet.swift
//  Charts
//
//  Copyright 2019 Leonardo BOK
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/assistar/Charts
//

import Foundation
import CoreGraphics

open class BlockChartDataSet: LineScatterCandleRadarChartDataSet, IBlockChartDataSet
{
    /// The width the Block will have
    open var blockWidth = CGFloat(10.0)
    
    /// The height the Block will have
    open var blockHeight = CGFloat(10.0)
    
    /// - Returns: The radius of the Block
    /// **default**: 0.0
    open var blockRadius: CGFloat = 0.0
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! BlockChartDataSet
        copy.blockWidth = blockWidth
        copy.blockHeight = blockHeight
        copy.blockRadius = blockRadius
        return copy
    }
}
