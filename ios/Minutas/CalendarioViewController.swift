//
//  CalendarioViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 11/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit


class CalendarioViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance{
    
    
    private let gregorian = Calendar(identifier: .gregorian)
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private weak var calendar: FSCalendar!
    private weak var eventLabel: UILabel!
    
}
