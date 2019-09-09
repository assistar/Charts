//
//  LegendRendererBlockChart.swift
//  Charts
//
//  Copyright 2019 Leonardo BOK
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/assistar/Charts
//

import Foundation

class LegendRendererBlockChart: LegendRenderer {
    
    @objc public override init(viewPortHandler: ViewPortHandler, legend: Legend?)
    {
        super.init(viewPortHandler: viewPortHandler, legend: legend)
    }
    
    /// Prepares the legend and calculates all needed forms, labels and colors.
    @objc open override func computeLegend(data: ChartData)
    {
        guard let legend = legend else { return }
        
        if !legend.isLegendCustom
        {
            var entries: [LegendEntry] = []
            
            // loop for building up the colors and labels used in the legend
            for i in 0..<data.dataSetCount
            {
                guard let dataSet = data.getDataSetByIndex(i) else { continue }
                
                var clrs: [NSUIColor] = dataSet.colors
                let entryCount = dataSet.entryCount
                
                // if we have a barchart with stacked bars
                if dataSet is IBarChartDataSet &&
                    (dataSet as! IBarChartDataSet).isStacked
                {
                    let bds = dataSet as! IBarChartDataSet
                    var sLabels = bds.stackLabels
                    let minEntries = min(clrs.count, bds.stackSize)
                    
                    for j in 0..<minEntries
                    {
                        let label: String?
                        if (sLabels.count > 0 && minEntries > 0) {
                            let labelIndex = j % minEntries
                            label = sLabels.indices.contains(labelIndex) ? sLabels[labelIndex] : nil
                        } else {
                            label = nil
                        }
                        
                        entries.append(
                            LegendEntry(
                                label: label,
                                form: dataSet.form,
                                formSize: dataSet.formSize,
                                formLineWidth: dataSet.formLineWidth,
                                formLineDashPhase: dataSet.formLineDashPhase,
                                formLineDashLengths: dataSet.formLineDashLengths,
                                formColor: clrs[j]
                            )
                        )
                    }
                    
                    if dataSet.label != nil
                    {
                        // add the legend description label
                        
                        entries.append(
                            LegendEntry(
                                label: dataSet.label,
                                form: .none,
                                formSize: CGFloat.nan,
                                formLineWidth: CGFloat.nan,
                                formLineDashPhase: 0.0,
                                formLineDashLengths: nil,
                                formColor: nil
                            )
                        )
                    }
                }
                else if dataSet is IPieChartDataSet
                {
                    let pds = dataSet as! IPieChartDataSet
                    
                    for j in 0..<min(clrs.count, entryCount)
                    {
                        entries.append(
                            LegendEntry(
                                label: (pds.entryForIndex(j) as? PieChartDataEntry)?.label,
                                form: dataSet.form,
                                formSize: dataSet.formSize,
                                formLineWidth: dataSet.formLineWidth,
                                formLineDashPhase: dataSet.formLineDashPhase,
                                formLineDashLengths: dataSet.formLineDashLengths,
                                formColor: clrs[j]
                            )
                        )
                    }
                    
                    if dataSet.label != nil
                    {
                        // add the legend description label
                        
                        entries.append(
                            LegendEntry(
                                label: dataSet.label,
                                form: .none,
                                formSize: CGFloat.nan,
                                formLineWidth: CGFloat.nan,
                                formLineDashPhase: 0.0,
                                formLineDashLengths: nil,
                                formColor: nil
                            )
                        )
                    }
                }
                else if dataSet is ICandleChartDataSet &&
                    (dataSet as! ICandleChartDataSet).decreasingColor != nil
                {
                    let candleDataSet = dataSet as! ICandleChartDataSet
                    
                    entries.append(
                        LegendEntry(
                            label: nil,
                            form: dataSet.form,
                            formSize: dataSet.formSize,
                            formLineWidth: dataSet.formLineWidth,
                            formLineDashPhase: dataSet.formLineDashPhase,
                            formLineDashLengths: dataSet.formLineDashLengths,
                            formColor: candleDataSet.decreasingColor
                        )
                    )
                    
                    entries.append(
                        LegendEntry(
                            label: dataSet.label,
                            form: dataSet.form,
                            formSize: dataSet.formSize,
                            formLineWidth: dataSet.formLineWidth,
                            formLineDashPhase: dataSet.formLineDashPhase,
                            formLineDashLengths: dataSet.formLineDashLengths,
                            formColor: candleDataSet.increasingColor
                        )
                    )
                }
                else
                { // all others
                    
                    for j in 0..<min(clrs.count, entryCount)
                    {
                        let label: String?
                        
                        // if multiple colors are set for a DataSet, group them
                        if j < clrs.count - 1 && j < entryCount - 1
                        {
                            label = nil
                        }
                        else
                        { // add label to the last entry
                            label = dataSet.label
                        }
                        
                        entries.append(
                            LegendEntry(
                                label: label,
                                form: dataSet.form,
                                formSize: dataSet.formSize,
                                formLineWidth: dataSet.formLineWidth,
                                formLineDashPhase: dataSet.formLineDashPhase,
                                formLineDashLengths: dataSet.formLineDashLengths,
                                formColor: clrs[j]
                            )
                        )
                    }
                }
            }
            
            legend.entries = entries + legend.extraEntries
        }
        
        // calculate all dimensions of the legend
        legend.calculateDimensions(labelFont: legend.font, viewPortHandler: viewPortHandler)
    }
    
    override func renderLegend(context: CGContext) {
        guard
            let legend = legend,
            let entry = legend.entries.first,
            let label = entry.label
            else { return }
        
        if !legend.enabled
        {
            return
        }
        
        let labelFont = legend.font
        let labelTextColor = legend.textColor
        
        drawLabel(context: context, x: legend.xOffset, y: legend.yOffset, label: label, font: labelFont, textColor: labelTextColor)
    }
    
    private var _formLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    /// Draws the Legend-form at the given position with the color at the given index.
    @objc open override func drawForm(
        context: CGContext,
        x: CGFloat,
        y: CGFloat,
        entry: LegendEntry,
        legend: Legend)
    {
        guard
            let formColor = entry.formColor,
            formColor != NSUIColor.clear
            else { return }
        
        var form = entry.form
        if form == .default
        {
            form = legend.form
        }
        
        let formSize = entry.formSize.isNaN ? legend.formSize : entry.formSize
        
        context.saveGState()
        defer { context.restoreGState() }
        
        switch form
        {
        case .none:
            // Do nothing
            break
            
        case .empty:
            // Do not draw, but keep space for the form
            break
            
        case .default: fallthrough
        case .circle:
            
            context.setFillColor(formColor.cgColor)
            context.fillEllipse(in: CGRect(x: x, y: y - formSize / 2.0, width: formSize, height: formSize))
            
        case .square:
            
            context.setFillColor(formColor.cgColor)
            context.fill(CGRect(x: x, y: y - formSize / 2.0, width: formSize, height: formSize))
            
        case .line:
            
            let formLineWidth = entry.formLineWidth.isNaN ? legend.formLineWidth : entry.formLineWidth
            let formLineDashPhase = entry.formLineDashPhase.isNaN ? legend.formLineDashPhase : entry.formLineDashPhase
            let formLineDashLengths = entry.formLineDashLengths == nil ? legend.formLineDashLengths : entry.formLineDashLengths
            
            context.setLineWidth(formLineWidth)
            
            if formLineDashLengths != nil && formLineDashLengths!.count > 0
            {
                context.setLineDash(phase: formLineDashPhase, lengths: formLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.setStrokeColor(formColor.cgColor)
            
            _formLineSegmentsBuffer[0].x = x
            _formLineSegmentsBuffer[0].y = y
            _formLineSegmentsBuffer[1].x = x + formSize
            _formLineSegmentsBuffer[1].y = y
            context.strokeLineSegments(between: _formLineSegmentsBuffer)
        }
    }
    
    /// Draws the provided label at the given position.
    @objc open override func drawLabel(context: CGContext, x: CGFloat, y: CGFloat, label: String, font: NSUIFont, textColor: NSUIColor)
    {
        ChartUtils.drawText(context: context, text: label, point: CGPoint(x: x, y: y), align: .left, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor])
    }
}
