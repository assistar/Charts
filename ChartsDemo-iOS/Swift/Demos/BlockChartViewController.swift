//
//  BlockChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Leonardo BOK on 2019-08-14.
//  Copyright © 2019 BOK. All rights reserved.
//

import UIKit
import Charts

class BlockChartViewController: DemoBaseViewController {
    
    fileprivate let blockWidth: CGFloat = 8
    fileprivate let blockHeight: CGFloat = 8
    fileprivate let blockSpace: CGFloat = 1
    fileprivate let plateSpace: CGFloat = 1
    fileprivate let plateOffset: CGFloat = 10
    fileprivate let blockRadius: CGFloat = 0.5
    fileprivate let xGranularity: Double = 1
    fileprivate let yGranularity: Double = 10
    fileprivate let chartMargin: Double = 0.5
    fileprivate let fontSize: CGFloat = 2.25
    
    fileprivate var maxCount: Int = 0
    fileprivate var maxRange: UInt32 = 0
    
    @IBOutlet var chartView: BlockChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = " $"
        formatter.positiveSuffix = " $"
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Block Chart"
        self.options = [.toggleValues,
                        .toggleIcons,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData,
                        .toggleBarBorders]
        
        sliderX.value = 52
        sliderY.value = 800
        slidersValueChanged(nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateChartData()
        updateCharView()
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(maxCount, range: maxRange)
    }
    
    override func optionTapped(_ option: Option) {
        super.handleOption(option, forChartView: chartView)
    }
    
    @IBAction func slidersValueChanged(_ sender: Any?) {
        maxCount = Int(sliderX.value)
        maxRange = UInt32(sliderY.value)
        
        sliderTextX.text = "\(maxCount)"
        sliderTextY.text = "\(maxRange)"
        
        initChartView()
        updateChartData()
        updateCharView()
    }
    
    fileprivate func initChartView() {
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.rightAxis.enabled = false
        
        chartView.dragEnabled = true
        chartView.scaleXEnabled = true
        chartView.scaleYEnabled = true
        chartView.pinchZoomEnabled = true
        chartView.backgroundColor = NSUIColor.black
        chartView.setViewPortOffsets(left: 55, top: 55, right: 0, bottom: 0)
        
        chartView.plateColor = NSUIColor(red: 19.0/255.0, green: 19.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        chartView.plateSpace = plateSpace
        chartView.blockSpace = blockSpace
        chartView.fontSize = fontSize
    }
    
    fileprivate func setDataCount(_ count: Int, range: UInt32) {
        let values1 = (0 ... count).flatMap { (i) -> [BlockChartDataEntry] in
            let max = (arc4random_uniform((range - 200) / 100) + 2) * 100
            let gap = arc4random_uniform(70) + 30
            return ((max - gap) ..< (max + gap)).map({ (j) -> BlockChartDataEntry in
                var val = j; val /= 10; val *= 10
                let level = arc4random_uniform(10)
                return BlockChartDataEntry(x: (Double(i) - 0.17), y: Double(val - 5), level: Int(level))
            })
        }
        let values2 = (0 ... count).flatMap { (i) -> [BlockChartDataEntry] in
            let max = (arc4random_uniform((range - 200) / 100) + 2) * 100
            let gap = arc4random_uniform(70) + 30
            return ((max - gap) ..< (max + gap)).map({ (j) -> BlockChartDataEntry in
                var val = j; val /= 10; val *= 10
                let level = arc4random_uniform(10)
                return BlockChartDataEntry(x: (Double(i) + 0.17), y: Double(val - 5), level: Int(level))
            })
        }
        
        var value11: [BlockChartDataEntry] = []
        values1.forEach { (entry) in
            if value11.contains(entry) == false {
                value11.append(entry)
            }
        }
        
        var value22: [BlockChartDataEntry] = []
        values2.forEach { (entry) in
            if value22.contains(entry) == false {
                value22.append(entry)
            }
        }
        
        let set1 = BlockChartDataSet(entries: value11, label: "DS 1")
        set1.resetColors()
        for i in stride(from: 20.0, through: 100.0, by: (80.0 / 9.0)).reversed() {
            set1.addColor(NSUIColor(red: 0/255.0, green: 58.0/255.0, blue: 225.0/255.0, alpha: (CGFloat(i) / 100.0)))
        }
        set1.valueTextColor = NSUIColor.white
        set1.blockWidth = blockWidth
        set1.blockHeight = blockHeight
        set1.blockRadius = blockRadius
        
        let set2 = BlockChartDataSet(entries: value22, label: "DS 2")
        set2.resetColors()
        for i in stride(from: 20, through: 100, by: 8).reversed() {
            set2.addColor(NSUIColor(red: 0/255.0, green: 179.0/255.0, blue: 160.0/255.0, alpha: (CGFloat(i) / 100.0)))
        }
        set2.valueTextColor = NSUIColor.white
        set2.blockWidth = blockWidth
        set2.blockHeight = blockHeight
        set2.blockRadius = blockRadius
        
        let data = BlockChartData(dataSets: [set1, set2])
        data.setValueFont(.systemFont(ofSize: fontSize, weight: .bold))
        data.setValueTextColor(NSUIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.96))
        data.plateSpace = plateSpace
        data.blockSpace = blockSpace
        data.highlightEnabled = false
        
        chartView.data = data
    }
    
    fileprivate func updateCharView() {
        guard
            let data = chartView.data as? BlockChartData,
            let dataSets = chartView.data?.dataSets
            else { return }
        
        let visible = Double(chartView.viewPortHandler.contentWidth / (blockWidth * CGFloat(dataSets.count) + blockSpace + plateOffset))
        let leftHeight: Double = Double(chartView.viewPortHandler.contentHeight / (blockHeight + plateSpace)) * yGranularity
        let leftMax = (leftHeight < data.yMax) ? (data.yMax * 1.1) : leftHeight
        
        let leftAxis = chartView.leftAxis
        leftAxis.xOffset = 20
        leftAxis.labelTextColor = NSUIColor(red: 191.0/255.0, green: 191.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        leftAxis.labelFont = .systemFont(ofSize: 13, weight: .bold)
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = leftMax
        leftAxis.granularity = yGranularity
        
        guard let xAxis = chartView.xAxis as? XAxisBlockChart else { return }
        xAxis.labelTextColor = NSUIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        xAxis.labelFont = .systemFont(ofSize: 13, weight: .bold)
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.axisMinimum = -chartMargin
        xAxis.axisMaximum = Double(maxCount) + chartMargin
        xAxis.granularity = xGranularity
        xAxis.valueFormatter = BlockChartWeekFormatter()
        xAxis.optionalValueFormatter = BlockChartOptionalWeekFormatter()
        xAxis.optionalLabelTextColor = NSUIColor(red: 162.0/255.0, green: 162.0/255.0, blue: 162.0/255.0, alpha: 1.0)
        xAxis.optionalLabelFont = .systemFont(ofSize: 10, weight: .semibold)
        
        let legend = chartView.legend
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.font = .systemFont(ofSize: 13, weight: .bold)
        legend.xOffset = 10
        legend.yOffset = 15
        legend.textColor = NSUIColor.white
        legend.setCustom(entries: [LegendEntry(label: "USD", form: Legend.Form.default, formSize: 0, formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: nil)])
        
        chartView.setVisibleXRangeMaximum(visible)
        chartView.setVisibleYRangeMaximum(leftHeight, axis: .left)
        
        chartView.updateScale()
    }
}

class BlockChartWeekFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        dateFormatter.dateFormat = "YY"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(format: "W%02d", Int(value))
    }
}

class BlockChartOptionalWeekFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        dateFormatter.dateFormat = "yy-MM-dd"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date: Date = Date(timeIntervalSinceNow: (value * 60 * 60 * 24 * 7))
        return dateFormatter.string(from: date)
    }
}
