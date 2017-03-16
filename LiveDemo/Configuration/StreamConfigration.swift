//
//  StreamConfigration.swift
//  LiveDemo
//
//  Created by manajay on 07/03/2017.
//  Copyright © 2017 manajay. All rights reserved.
//

import UIKit


/**
 帧率均为18，通用模式、高性能，音频码率均为48k。默认选择540P，默认选择横屏。
 */
enum StreamQuality: Int32 {
  case lower = 500;
  case normal = 800;
  case fine = 1000;
  case higher = 1200
  
  /// Request is running
  public var description: String {
    switch self {
    case .lower:
      return "码率500K，较差画质，适用于推流网络状况较差的直播需求"
    case .fine:
      return "码率1000K，良好画质，对用户的网络有一定要求"
    case .higher:
      return "码率1200K，清晰画质，对用户的网络要求较高"
    default:
      return "码率800K，普通画质，适用于互动性较高的直播需求"
    }
  }
  
  /// Request is running
  public var title: String {
    switch self {
    case .lower:
      return "360P"
    case .fine:
      return "540P"
    case .higher:
      return "720P"
    default:
      return "480P"
    }
  }
  
  public var maxKeyInterval: Float {
    switch self {
    case .lower:
      return 3
    case .fine:
      return 3
    case .higher:
      return 3
    default:
      return 3
    }
  }
  
  public var videoMaxBitrate: Int32 {
    switch self {
    case .lower:
      return 800
    case .fine:
      return 1200
    case .higher:
      return 1300
    default:
      return 1000
    }
  }
  
  public var videoMinBitrate: Int32 {
    switch self {
    case .lower:
      return 300
    case .fine:
      return 800
    case .higher:
      return 1000
    default:
      return 500
    }
  }
  
  public var audiokBPS: Int32 {
    switch self {
    case .lower:
      return 48
    case .fine:
      return 48
    case .higher:
      return 48
    default:
      return 48
    }
  }
  
  public var streamDimension: CGSize {
    switch self {
    case .lower:
      return CGSize(width: 640, height: 360)
    case .fine:
      return CGSize(width: 960, height: 540)
    case .higher:
      return CGSize(width: 1280, height: 720)
    default:
      return CGSize(width: 854, height: 480)
    }
  }
  
}

//MARK: enmu
enum ScreenOrientation: Int {
  
  case portrait = 2
  case landscapeRight = 1
  
  var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    switch self {
    case .portrait:
      return .portrait
    case .landscapeRight:
      return .landscapeRight
    }
  }
  
  var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    switch self {
    case .portrait:
      return .portrait
    case .landscapeRight:
      return .landscapeRight
    }
  }
  
  var fullScreenWidth: CGFloat {
    switch self {
    case .portrait:
      return UIScreen.main.bounds.width
    case .landscapeRight:
      return UIScreen.main.bounds.height
    }
  }
  
  var fullScreenHeight: CGFloat {
    switch self {
    case .portrait:
      return UIScreen.main.bounds.height
    case .landscapeRight:
      return UIScreen.main.bounds.width
    }
  }

  
}
