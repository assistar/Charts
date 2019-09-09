//
//  BlockChartRenderer.swift
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

open class BlockChartRenderer: LineScatterCandleRadarRenderer
{
    @objc open weak var dataProvider: BlockChartDataProvider?
    
    @objc public init(dataProvider: BlockChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }

    open override func drawData(context: CGContext)
    {
        guard let blockData = dataProvider?.blockData else { return }

        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()
        
        if let chart = dataProvider as? BlockChartView {
            // Make the chart header the first element in the accessible elements array
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: blockData,
                                                 withDefaultDescription: "Block Chart")
            accessibleChartElements.append(element)
        }

        // TODO: Due to the potential complexity of data presented in Block charts, a more usable way
        // for VO accessibility would be to use axis based traversal rather than by dataset.
        // Hence, accessibleChartElements is not populated below. (Individual renderers guard against dataSource being their respective views)
        
        drawPlates(context: context)
        
        for i in 0 ..< blockData.dataSetCount
        {
            guard let set = blockData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible
            {
                if !(set is IBlockChartDataSet)
                {
                    fatalError("Datasets for BlockChartRenderer must conform to IBlockChartDataSet")
                }
                
                drawDataSet(context: context, dataSet: set as! IBlockChartDataSet)
            }
        }
    }
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: IBlockChartDataSet)
    {
        guard
            let dataProvider = dataProvider,
            let blockData = dataProvider.blockData
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        do {
            context.saveGState()
            
            for i in 0 ..< Int(min(ceil(Double(entryCount) * animator.phaseX), Double(entryCount)))
            {
                guard let entry = dataSet.entryForIndex(i) as? BlockChartDataEntry else { continue }
                
                point.x = CGFloat(entry.x)
                point.y = CGFloat(entry.y * phaseY)
                point = point.applying(valueToPixelMatrix)
                
                if !viewPortHandler.isInBoundsRight(point.x)
                {
                    break
                }
                
                if !viewPortHandler.isInBoundsLeft(point.x) ||
                    !viewPortHandler.isInBoundsY(point.y)
                {
                    continue
                }
                
                let color = (isDrawingValuesAllowed(dataProvider: dataProvider) == true) ? dataSet.color(atIndex: 0) : dataSet.color(atIndex: entry.level)
                
                renderBlock(context: context, data: blockData, dataSet: dataSet, point: point, color: color)
            }
            
            context.restoreGState()
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let blockData = dataProvider.blockData
            else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            guard let dataSets = blockData.dataSets as? [IBlockChartDataSet] else { return }
            
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< blockData.dataSetCount
            {
                let dataSet = dataSets[i]
                guard let
                    formatter = dataSet.valueFormatter,
                    shouldDrawValues(forDataSet: dataSet)
                    else { continue }
                
                let valueFont = dataSet.valueFont
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                let lineHeight = valueFont.lineHeight / 2
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in _xBounds
                {
                    guard let etry = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(etry.x)
                    pt.y = CGFloat(etry.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    // make sure the lines don't do shitty things outside bounds
                    if (!viewPortHandler.isInBoundsLeft(pt.x)
                        || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    let text = formatter.stringForValue(
                        etry.y,
                        entry: etry,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler)
                    
                    if dataSet.isDrawValuesEnabled
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: text,
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - lineHeight),
                            align: .center,
                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: dataSet.valueTextColorAt(j)]
                        )
                    }
                    
                    if let icon = etry.icon, dataSet.isDrawIconsEnabled
                    {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let blockData = dataProvider.blockData
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = blockData.getDataSetByIndex(high.dataSetIndex) as? IBlockChartDataSet,
                set.isHighlightEnabled
                else { continue }
            
            guard let entry = set.entryForXValue(high.x, closestToY: high.y) else { continue }
            
            if !isInBoundsX(entry: entry, dataSet: set) { continue }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let x = entry.x // get the x-position
            let y = entry.y * Double(animator.phaseY)
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            let pt = trans.pixelForValues(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        context.restoreGState()
    }
    
    open override func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool
    {
        guard
            let chart = dataProvider as? BlockChartView
            else { return false }
        
        return (chart.viewPortHandler.scaleX / chart.scaleX) > 4
    }
}

fileprivate extension BlockChartRenderer {
    
    func drawPlates(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let blockData = dataProvider.blockData,
            let dataSet = blockData.plateDataSet,
            let dataSets = blockData.dataSets as? [IBlockChartDataSet]
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        do {
            context.saveGState()
            
            for i in 0 ..< Int(min(ceil(Double(entryCount) * animator.phaseX), Double(entryCount)))
            {
                guard let entry = dataSet.entryForIndex(i) else { continue }
                
                point.x = CGFloat(entry.x)
                point.y = CGFloat(entry.y * phaseY)
                point = point.applying(valueToPixelMatrix)
                
                if !viewPortHandler.isInBoundsRight(point.x)
                {
                    break
                }
                
                if !viewPortHandler.isInBoundsLeft(point.x) ||
                    !viewPortHandler.isInBoundsY(point.y)
                {
                    continue
                }
                
                renderBlock(context: context, data: blockData, dataSet: dataSet, dataSets: dataSets, point: point, color: dataSet.color(atIndex: i))
            }
            
            context.restoreGState()
        }
    }
    
    func renderBlock(
        context: CGContext,
        data: BlockChartData,
        dataSet: IBlockChartDataSet,
        dataSets: [IBlockChartDataSet]? = nil,
        point: CGPoint,
        color: NSUIColor)
    {
        let width = (dataSet.blockWidth * CGFloat(dataSets?.count ?? 1)) + (data.blockSpace * (CGFloat(dataSets?.count ?? 1) - 1))
        let widthHalf = width / 2.0
        let height = dataSet.blockHeight
        let heightHalf = height / 2.0
        
        context.setFillColor(color.cgColor)
        context.setShouldAntialias(false)
        
        var rect = CGRect()
        rect.origin.x = point.x - widthHalf
        rect.origin.y = point.y - heightHalf
        rect.size.width = width
        rect.size.height = height
        
        if dataSet.blockRadius == 0 {
            context.fill(rect)
        } else {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: dataSet.blockRadius)
            path.fill()
        }
    }
}


extension NSUIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}
