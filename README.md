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
    let orientationValue = orientation.rawValue
    UIDevice.current.setValue(orientationValue, forKey: "orientation")
  }

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



