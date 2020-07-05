//
//  InterfaceController.swift
//  dms_for_watch WatchKit Extension
//
//  Created by DohyunKim on 2020/07/01.
//  Copyright © 2020 DohyunKim. All rights reserved.
//

import WatchKit
import Foundation


// MARK: InterfaceController

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var lblMealKind: WKInterfaceLabel!
    @IBOutlet weak var lblMenu: WKInterfaceLabel!
    @IBOutlet weak var lblTime: WKInterfaceLabel!
    
    let formatter = DateFormatter()
    var date: Date!
    let aDay = TimeInterval(86400)
    var menu = ""
    var currentTime = 0
    var currentDate: String = ""
    var swipeDirection = WKSwipeGestureRecognizer()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        date = Date()
        setInit()
        connect()
        mealKindInit()
        lblTime.setText(currentDate)
        adjustDate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func btnSwipeRight() {
        currentTime += 1
        adjustDate()
        connect()
        mealKindInit()
        lblTime.setText(currentDate)
    }
    
    @IBAction func btnSwipeLeft() {
        currentTime -= 1
        adjustDate()
        connect()
        mealKindInit()
        lblTime.setText(currentDate)
    }
    
    func setInit(){
        formatter.dateFormat = "H"
        guard let intTime = Int(formatter.string(from: date)) else{ return }
        switch intTime {
        case 0...8:
            currentTime = 0
        case 9...12:
            currentTime = 1
        case 13...17:
            currentTime = 2
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
        formatter.dateFormat = "YYYY-MM-dd"
        currentDate = formatter.string(from: date)
        let url = "https://api.dsm-dms.com/meal/" + currentDate
        let request  = URLRequest(url: URL(string: url)!)
        
        URLSession.shared.dataTask(with: request){
            [weak self] data, res, err in
            if let err = err { print(err.localizedDescription); return }
            switch (res as! HTTPURLResponse).statusCode{
            case 200:
                switch self!.currentTime {
                case 0: self!.sessionJson(data: data!, eatTime: "breakfast")
                case 1: self!.sessionJson(data: data!, eatTime: "lunch")
                case 2: self!.sessionJson(data: data!, eatTime: "dinner")
                default: return
                }
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
    
    func sessionJson(data: Data, eatTime: String) {
        let jsonSerialization = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: [String: [String]]]
        let list = jsonSerialization[self.currentDate]
        var menuData = ""
        self.menu = ""
        var i = 0
        if list == nil { return }
        if list![eatTime] == nil {self.lblMenu.setText("급식이 없습니다"); return }
        while true {
            if i < (list![eatTime]?.count)! {
                if self.menu == "" {  }
                else { self.menu += ", " }
                self.menu += list![eatTime]![i]
            } else {
                break
            }
            i += 1
        }
        if self.menu != "" {
            menuData = self.menu.replacingOccurrences(of: " ", with: "\n").replacingOccurrences(of: ",", with: " ")
        }
        if self.currentTime == currentTime {
            self.lblMenu.setText(menu)
        }
    }
}
