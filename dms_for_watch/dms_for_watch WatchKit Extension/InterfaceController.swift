//
//  InterfaceController.swift
//  dms_for_watch WatchKit Extension
//
//  Created by DohyunKim on 2020/07/01.
//  Copyright © 2020 DohyunKim. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    
    @IBOutlet weak var lblMealKind: WKInterfaceLabel!
    
    @IBOutlet weak var lblMenu: WKInterfaceLabel!
    
    
    @IBOutlet weak var lblTime: WKInterfaceLabel!
    let formatter = DateFormatter()
    
    var date: Date!
    let aDay = TimeInterval(86400)
    var breakfastMenu = ""
    var lunchMenu = ""
    var dinnerMenu = ""
    
    var currentTime = 0
    
    var currentDate: String = ""
    
    var swifeDirection = WKSwipeGestureRecognizer()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        date = Date()
        setInit()
        connect()
        mealKindInit()
        lblTime.setText(currentDate)
        swifeRecognizer()
        adjustDate()
        
       
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func swifeRecognizer() {
        
        while true {
            if swifeDirection.direction == .left {
                currentTime -= 1
            }
            if swifeDirection.direction == .right {
                currentTime += 1
            }
        }
    }
    
    func setInit(){
        formatter.dateFormat = "H"
        guard let curIntTime = Int(formatter.string(from: date)) else{ return }
        switch curIntTime {
        case 0...8:
            currentTime = 0
        case 9...12:
            currentTime = 1
            lblMealKind.setText("점심")
        case 13...17:
            currentTime = 2
            lblMealKind.setText("저녁")
        default:
            date! += aDay
            currentTime = 0
        }
    }
    
    
    
    func mealKindInit() {
        switch currentTime {
        case 0:
            self.lblMealKind.setText("아침")
        case 1:
            self.lblMealKind.setText("점심")
        case 2:
            self.lblMealKind.setText("저녁")
        default:
            return
        }
    }

    
    
    func connect(){
        var breakfastData = ""
        var lunchData = ""
        var dinnerData = ""
        
        formatter.dateFormat = "YYYY-MM-dd"
        var dateStr = formatter.string(from: date)
        print(dateStr)
        currentDate = dateStr
        let url = "https://api.dsm-dms.com/meal/" + dateStr
        let request  = URLRequest(url: URL(string: url)!)
        
        URLSession.shared.dataTask(with: request){
            [weak self] data, res, err in

            if let err = err { print(err.localizedDescription); return }
            print((res as! HTTPURLResponse).statusCode)
            switch (res as! HTTPURLResponse).statusCode{
            case 200:
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: [String: [String]]]
                let list = jsonSerialization["\(dateStr)"]
                if jsonSerialization["breakfast"]?.count != 0 {
                    self!.breakfastMenu = ""
                    var i = 0
                    while true {
                        if list == nil {
                            return
                        }
                        if list!["breakfast"] == nil {
                            breakfastData = "급식이 없습니다"
                            break
                        }
                        if i < (list!["breakfast"]?.count)! {
                            if self!.breakfastMenu == "" {  }
                            else { self!.breakfastMenu += ", " }
                            self!.breakfastMenu += list!["breakfast"]![i]
                        } else {
                            break
                        }
                        i += 1
                    }
                    if self!.breakfastMenu != "" {
                        breakfastData = self!.breakfastMenu
                    }
                }
                if self!.currentTime == 0 {
                    self!.lblMenu.setText(breakfastData)
                }
                if jsonSerialization["lunch"]?.count != 0 {
                    self!.lunchMenu = ""
                    var i = 0
                    while true {
                        if list == nil {
                            return
                        }
                        if list!["lunch"] == nil {
                            breakfastData = "급식이 없습니다"
                            break
                        }
                        if i < (list!["lunch"]?.count)! {
                            if self!.lunchMenu == "" {  }
                            else { self!.lunchMenu += ", " }
                            self!.lunchMenu += list!["lunch"]![i]
                        } else {
                            break
                        }
                        i += 1
                    }
                    if self!.lunchMenu != "" {
                        lunchData = self!.lunchMenu
                    }
                }
                if self!.currentTime == 1 {
                    self!.lblMenu.setText(lunchData)
                }
                if jsonSerialization["dinner"]?.count != 0 {
                    self!.dinnerMenu = ""
                    var i = 0
                    while true {
                        if list == nil {
                            return
                        }
                        if list!["dinner"] == nil {
                            breakfastData = "급식이 없습니다"
                            break
                        }
                        if i < (list!["dinner"]?.count)! {
                            if self!.dinnerMenu == "" {  }
                            else { self!.dinnerMenu += ", " }
                            self!.dinnerMenu += list!["dinner"]![i]
                        } else {
                            break
                        }
                        i += 1
                    }
                    if self!.breakfastMenu != "" {
                        dinnerData = self!.dinnerMenu
                    }
                }
                if self!.currentTime == 2 {
                    self!.lblMenu.setText(dinnerData)
                }
                
                print("\(jsonSerialization)")
                
                
            case 204: self!.lblMenu.setText("급식이 없습니다")
            
            default:
                return
            }
           
            }.resume()
    }
    
    func adjustDate(){
    switch currentTime {
    case -1:
        date! -= aDay
        currentTime = 2
        
    case 3:
        date! += aDay
        currentTime = 0
        
    default:
        return
    }
    }
    
}


    
    

    


