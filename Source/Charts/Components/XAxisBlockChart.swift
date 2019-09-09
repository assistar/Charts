//
//  XAxisBlockChart.swift
//  Charts
//
//  Copyright 2019 Leonardo BOK
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/assistar/Charts
//

import Foundation

open class XAxisBlockChart: XAxis {
    /// Custom formatter that is used instead of the auto-formatter if set
    private var _axisOptionalValueFormatter: IAxisValueFormatter?
    
    @objc open var optionalLabelFont = NSUIFont.systemFont(ofSize: 10.0)
    @objc open var optionalLabelTextColor = NSUIColor.black
    
    /// Sets the formatter to be used for formatting the axis labels.
    /// If no formatter is set, the chart will automatically determine a reasonable formatting (concerning decimals) for all the values that are drawn inside the chart.
    /// Use `nil` to use the formatter calculated by the chart.
    @objc open var optionalValueFormatter: IAxisValueFormatter?
        {
        get
        {
            if _axisOptionalValueFormatter == nil ||
                (_axisOptionalValueFormatter is DefaultAxisValueFormatter &&
                    (_axisOptionalValueFormatter as! DefaultAxisValueFormatter).hasAutoDecimals &&
                    (_axisOptionalValueFormatter as! DefaultAxisValueFormatter).decimals != decimals)
            {
                _axisOptionalValueFormatter = DefaultAxisValueFormatter(decimals: decimals)
            }
            
            return _axisOptionalValueFormatter
        }
        set
        {
            _axisOptionalValueFormatter = newValue ?? DefaultAxisValueFormatter(decimals: decimals)
        }
    }
}
