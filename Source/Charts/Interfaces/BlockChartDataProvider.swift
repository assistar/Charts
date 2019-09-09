//
//  BlockChartDataProvider.swift
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

@objc
public protocol BlockChartDataProvider: BarLineScatterCandleBubbleChartDataProvider
{
    var blockData: BlockChartData? { get }
    
    /// contains the current scale factor of the x-axis
    var scaleX: CGFloat { get }
    
    /// contains the current scale factor of the y-axis
    var scaleY: CGFloat { get }
    
    func updateScale()
}
