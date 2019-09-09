//
//  IBlockChartDataSet.swift
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
public protocol IBlockChartDataSet: ILineScatterCandleRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The width the Block will have
    var blockWidth: CGFloat { get }
    
    /// The height the Block will have
    var blockHeight: CGFloat { get }
    
    /// - Returns: The radius of the Block
    /// **default**: 0.0
    var blockRadius: CGFloat { get }
}
