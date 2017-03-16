//
//  Common.swift
//  LiveDemo
//
//  Created by manajay on 2017/3/16.
//  Copyright © 2017年 manajay. All rights reserved.
//

import UIKit

func Log<T>(_ message : T, file : String = #file, methodName: String = #function, lineNumber : Int = #line) {
  
  #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let printMessage = "[\(fileName):line:\(lineNumber):\(methodName)]- \(message)   - : \(Thread.current)"
    print(printMessage)
  #endif
  
}
