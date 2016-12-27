//
//  GraficasViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 16/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation



class GraficasViewController: UIViewController{
    
    
   // @IBOutlet weak var barView: BarChartView!
    
    var numeros = [Double]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        numeros.append(1)
        numeros.append(2)
        numeros.append(3)
        
    //    updateChartWithData()
        
    }
    
    /*func updateChartWithData() {
        
        
        
        var dataEntries: [BarChartDataEntry] = []
        
        
        //for i in 0..<numeros.count {
        var dataEntry = BarChartDataEntry(value: 5 , xIndex:0 )
        dataEntries.append(dataEntry)
        
        dataEntry = BarChartDataEntry(value: 2 , xIndex:1 )
        dataEntries.append(dataEntry)
        
        dataEntry = BarChartDataEntry(value: 3 , xIndex:2 )
        dataEntries.append(dataEntry)
        //}
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Prueba")
        let chartData = BarChartData(xVals: ["hola", "mundo", "feliz"], dataSet: chartDataSet)
        barView.data = chartData
        
        
        barView.invalidateIntrinsicContentSize()
    }
    */
    
    
}
