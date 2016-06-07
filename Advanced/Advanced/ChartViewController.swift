//
//  ChartViewController.swift
//  Advanced
//
//  Created by  cxy on 16/5/14.
//  Copyright © 2016年 cxy. All rights reserved.
//

import UIKit
import Charts
import MBProgressHUD

class ChartViewController: UIViewController {
    var xValues:[String]?
    var yValues:[Float]?
    var lineChart:LineChartView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart = ChartDrawer.shareDrawer().drawLineChart(inView: view, withXvalues: xValues!, yValues: yValues!)
        //lineChart?.setVisibleXRangeMaximum(CGFloat(20))
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(tryToSave))
        
        title = "Record"
        
    }
    
    func tryToSave(){
        let alert = UIAlertController(title: "提示", message: "是否保存该图表", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let yesAction = UIAlertAction(title: "是", style: .Default) { (_) in
            self.lineChart?.saveToCameraRoll()
        }
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func simplify(sender: AnyObject) {
        let count = lineChart?.data?.dataSets[0].entryCount
        if count! > 2000{
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.mode = .Indeterminate
            hud.labelText = "请稍等"
            dispatch_async(dispatch_get_global_queue(0, 0), {
                ///每隔factor取一点
                var factor:Int?
            
                switch count!{
                case let count where count > 10000:
                    //若超过10000点，每隔100点取一点
                    factor = 100
                    break
                case let count where count <= 10000:
                    //大于2000点，小于等于10000点，每隔50点取一点
                    factor = 50
                    break
                default:
                    break
                }
                
                for i in 0..<count! {
                    if i % factor! != 0{
                        self.lineChart!.data!.dataSets[0].removeEntry(xIndex: i)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                    self.lineChart?.maxVisibleValueCount = 0
                    self.lineChart?.notifyDataSetChanged()
                    self.lineChart?.invalidateIntrinsicContentSize()
                    self.lineChart?.setVisibleXRangeMinimum(CGFloat(count!))
                    print(self.lineChart?.data?.dataSets[0].entryCount)
                })
            })
        }
    }

}
