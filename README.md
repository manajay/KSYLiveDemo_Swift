# KSYLiveDemo_Swift
That's a RTMP test demo
##  技术点
### 1. 横竖屏的切换
主要注意点有

* 当前视图是否能够横竖屏旋转 前提是取决于其根控制器
* 自动横竖屏还取决于 当前控制器的 

``` 
override var shouldAutorotate: Bool {
    return false
}
```

* 当前视图的 屏幕方向 即使支持自动转屏,仍然需要指名支持的方向

```
// Returns the default set of interface orientations to use for the view controllers in the specified window.
// This method returns the default interface orientations for the app. These orientations are used only for view controllers that do not specify their own. If your app delegate implements the application(_:supportedInterfaceOrientationsFor:) method, the system does not call this method.
 override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
  }
  
  // Returns the interface orientation to use when presenting the view controller. 即 当你 modal出来一个控制器的时候,询问支持的方向走的是该方法
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
     return .portrait
  }
```
这里 `application(_:supportedInterfaceOrientationsFor:) `如果有实现的话,就不会调用`supportedInterfaceOrientations`方法.

*  利用KVC强制横屏 

```
fileprivate func orientationTo(_ orientation: UIInterfaceOrientation) {
      // 先自己给一个值0，然后再修改为其他屏幕方向就能顺利调起 KVO 来进入屏幕旋转流程
    UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
    UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
  }
/**
   1.当当前设备方向属性 orientation 发生变化时候，会调用 Controller 的 shouldAutorotate 属性。
   2.如果 shouldAutorotate 为 true 则会进一步调用 supportedInterfaceOrientations 来查询支持的屏幕方向。
   3.当 Controller 支持的方向和设备方向一致时候就进行旋转操作。
   
   神 Bug 就出在第一步。UIDevice 的 orientation 属性并不是指的屏幕的方向，而是设备的方向。我们屏幕旋转的实现就是通过手动修改 orientation 属性来欺骗设备告诉他设备方向发生了变化，从而开始屏幕旋转流程。
   
   如果当屏幕 UI 处于横屏且 shouldAutorotate = false 时候，我们旋转手机设备 orientation 属性会持续变化并开始屏幕旋转流程调用 shouldAutorotate。但是因为 shouldAutorotate 为 false 所以不会有任何反应。
   
   当屏幕 UI 处于横屏且我们旋转手机设备至竖屏状态时， orientation 属性已经为 UIInterfaceOrientation.portrait.rawValue 了，所以此时再次设置为 UIInterfaceOrientation.portrait.rawValue 并不会调用被系统认为屏幕方向发生了变化。所以就不会有任何变化。
   
   */

```

注意的是 如果上一个控制器只支持竖屏,则当前的控制器要在 `viewWillDisappear`的时候强制转回 竖屏.

### 2. 金山云SDK的使用
* 前后台的时候 监测 调用金山云的API 去除从后台返回时 推流中断的bug.
* 聚焦与 缩放效果
* 美颜与手电筒
* 如果使用自动布局,要注意设置预览图层`kit.preview`的布局问题,防止`size`为零时不出现画面的bug

### 3. 小技巧
* 利用运行时,使导航控制器边缘侧滑改为 全局右滑退出当前视图的手势
* 聚焦的点击效果

### 4.分支 Share 添加了 微信的分享的Demo

### 5. 这里在使用金山云SDK的时候 出现的一个超级大的BUG

金山云的推流streamerKit 要求最好只实例化一个对象,也就是做成单例处理.而我因为功能需要,添加了一个Timer来做推流的计时功能,结果造成了循环应用当前控制器,导致控制器以及其持有的streamerKit 都没有释放, 导致 重复进入控制器的时候,创建了多个对象,造成经常性的推流卡死屏幕的现象,以及摄像头采集初始化缓慢,这都是因为循环引用造成的.
