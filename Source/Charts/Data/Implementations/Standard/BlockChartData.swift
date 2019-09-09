//
//  BlockChartData.swift
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

open class BlockChartData: BarLineScatterCandleBubbleChartData
{
    /// The Plate Data Set
    open var plateDataSet: IBlockChartDataSet?
    
    /// The space the Plate will have
    open var plateSpace = CGFloat(1.0)
    
    /// The space the Block will have
    open var blockSpace = CGFloat(1.0)
    
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [IChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
}
