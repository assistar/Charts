//
//  BlockChartView.swift
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

/// The BlockChart. Draws dots, triangles, squares and custom shapes into the chartview.
open class BlockChartView: BarLineChartViewBase
{
    /// contains the current scale factor of the x-axis
    fileprivate var _scaleX: CGFloat = 0
    
    /// contains the current scale factor of the y-axis
    fileprivate var _scaleY: CGFloat = 0
    
    /// contains the current translate factor of the x-axis
    fileprivate var _transX: CGFloat = 0
    
    /// contains the current translate factor of the y-axis
    fileprivate var _transY: CGFloat = 0
    
    lazy var blockAxisTransformer: Transformer = TransformerBlockChart(viewPortHandler: _viewPortHandler)
    
    /// the color that is used for Plate.
    open var plateColor = NSUIColor.clear
    
    /// The width the Block will have
    fileprivate var _blockWidth = CGFloat(10.0)
    
    /// The height the Block will have
    fileprivate var _blockHeight = CGFloat(10.0)
    
    /// - Returns: The radius of the Block
    /// **default**: 0.0
    fileprivate var _blockRadius: CGFloat = 0.0
    
    /// The space the Plate will have
    open var plateSpace = CGFloat(1.0)
    
    /// The space the Block will have
    open var blockSpace = CGFloat(1.0)
    
    /// The font size the Block will have
    open var fontSize: CGFloat = 2.25
    
    /// The current x-scale factor
    @objc open override var scaleX: CGFloat
    {
        return _scaleX
    }
    
    /// The current y-scale factor
    @objc open override var scaleY: CGFloat
    {
        return _scaleY
    }
    
    open override var data: ChartData? {
        get
        {
            return super.data
        }
        set
        {
            super.data = newValue
            
            let values0 = (0 ... Int(xAxis.axisMaximum)).flatMap { (i) -> [ChartDataEntry] in
                return (0 ..< Int(leftAxis.axisMaximum)).map({ (j) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(j * 10 - 5))
                })
            }
            
            guard let dataSet = data?.dataSets.first as? BlockChartDataSet else { return }
            
            _blockWidth = dataSet.blockWidth
            _blockHeight = dataSet.blockHeight
            _blockRadius = dataSet.blockRadius
            
            let set0 = BlockChartDataSet(entries: values0)
            set0.setColor(plateColor)
            set0.blockWidth = dataSet.blockWidth
            set0.blockHeight = dataSet.blockHeight
            
            guard let data = data as? BlockChartData else { return }
            
            data.plateDataSet = set0
        }
    }
    
    open override func initialize()
    {
        super.initialize()
        
        _xAxis = XAxisBlockChart()
        
        let viewPortHandler = ViewPortHandlerBlockChart(width: bounds.width, height: bounds.height)
        viewPortHandler.didRefresh = {
            guard
                let dataSets = self.data?.dataSets,
                let blockData = self.data as? BlockChartData,
                let plateDataSet = blockData.plateDataSet as? BlockChartDataSet
                else { return }
            
            let transX: CGFloat = viewPortHandler.scaleX / self._scaleX
            let transY: CGFloat = viewPortHandler.scaleY / self._scaleY
            
            guard self._transX != transX, self._transY != transY else { return }
            
            if #available(iOS 8.2, *) {
                blockData.setValueFont(.systemFont(ofSize: (self.fontSize * transY), weight: .bold))
            }
            
            blockData.blockSpace = self.blockSpace * transX
            
            plateDataSet.blockWidth = self._blockWidth * transX
            plateDataSet.blockHeight = self._blockHeight * transY
            
            for dataSet in dataSets.enumerated() {
                guard let blockDataSet = dataSet.element as? BlockChartDataSet else { continue }
                
                blockDataSet.blockWidth = self._blockWidth * transX
                blockDataSet.blockHeight = self._blockHeight * transY
                blockDataSet.blockRadius = self._blockRadius * transX
            }
            
            self._transX = transX
            self._transY = transY
        }
        _viewPortHandler = viewPortHandler
        
        renderer = BlockChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        xAxisRenderer = XAxisRendererBlockChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: blockAxisTransformer)
        leftYAxisRenderer = YAxisRendererBlockChart(viewPortHandler: _viewPortHandler, yAxis: leftAxis, transformer: blockAxisTransformer)
        _legendRenderer = LegendRendererBlockChart(viewPortHandler: _viewPortHandler, legend: _legend)
        
        xAxis.spaceMin = 0.5
        xAxis.spaceMax = 0.5
    }
    
    override func prepareValuePxMatrix() {
        super.prepareValuePxMatrix()
        
        blockAxisTransformer.prepareMatrixValuePx(chartXMin: xAxis._axisMinimum, deltaX: CGFloat(xAxis.axisRange * 1/*1.009*/), deltaY: CGFloat(leftAxis.axisRange * 1.0), chartYMin: leftAxis._axisMinimum)
    }
    
    override func prepareOffsetMatrix() {
        super.prepareOffsetMatrix()
        
        blockAxisTransformer.prepareMatrixOffset(inverted: leftAxis.isInverted)
    }
    
    open override func getTransformer(forAxis axis: YAxis.AxisDependency) -> Transformer {
        return blockAxisTransformer
    }
}

// MARK: - BlockChartDataProvider
extension BlockChartView: BlockChartDataProvider {
    open var blockData: BlockChartData? { return _data as? BlockChartData }
    
    open func updateScale() {
        _scaleX = viewPortHandler.scaleX
        _scaleY = viewPortHandler.scaleY
    }
}
