//
//  DateFormatHelp.swift
//  LiveDemo
//
//  Created by manajay on 2017/3/16.
//  Copyright © 2017年 manajay. All rights reserved.
//

import UIKit

class DateFormatHelp:DateFormatter {
  
  private static let shareInstance = DateFormatHelp()
  
  class var share:DateFormatHelp {
    
    shareInstance.timeZone = TimeZone.current
    shareInstance.locale = Locale.current
    
    return shareInstance
  }
}

