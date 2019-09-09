//
//  ViewPortHandlerBlockChart.swift
//  Charts
//
//  Copyright 2019 Leonardo BOK
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/assistar/Charts
//

import Foundation

open class ViewPortHandlerBlockChart: ViewPortHandler {
    /// refresh callback
    open var didRefresh: (() -> Void)?
    
    /// call this method to refresh the graph with a given matrix
    @objc @discardableResult open override func refresh(newMatrix: CGAffineTransform, chart: ChartViewBase, invalidate: Bool) -> CGAffineTransform
    {
        let result = super.refresh(newMatrix: newMatrix, chart: chart, invalidate: invalidate)
        didRefresh?()
        return result
    }
}
