//
//  UIButton+Extension.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/7.
//  Copyright © 2016年 manajay. All rights reserved.
//


// MARK: - 初始化
extension UIButton {
    
    class func buttonWith(title normalTitle: String?,
                     titleColor: UIColor?,
                     fontSize: CGFloat = 14.0,
                     backGroundColor backColor: UIColor?,
                     cornerRadius: CGFloat = 0.0,
                     borderWidth: CGFloat = 0.0,
                     borderColor boderColor: UIColor?,
                     buttonType: UIButtonType)
        -> UIButton
    {
        let btn = UIButton(type: buttonType)
        
        if backColor != nil {
            btn.backgroundColor = backColor
        }
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        
        btn.layer.cornerRadius = cornerRadius
        btn.layer.borderWidth = borderWidth
        
        if cornerRadius > 0.0 {
            btn.clipsToBounds = true
        }
        
        if boderColor != nil {
            btn.layer.borderColor = boderColor?.cgColor
        }
        
        if normalTitle != nil {
            btn.setTitle(normalTitle, for: .normal)
        }
        
        if titleColor != nil {
            btn.setTitleColor(titleColor, for: .normal)
        }
        
        return btn
    }
    
    class func buttonWith(image:UIImage?,
                          backGroundColor backColor: UIColor?,
                          cornerRadius: CGFloat = 0.0,
                          borderWidth: CGFloat = 0.0,
                          borderColor boderColor: UIColor?,
                          buttonType: UIButtonType)
        -> UIButton
    {
        let btn = UIButton(type: buttonType)
        
        if backColor != nil {
            btn.backgroundColor = backColor
        }
        
        btn.layer.cornerRadius = cornerRadius
        btn.layer.borderWidth = borderWidth
        
        if cornerRadius > 0.0 {
            btn.clipsToBounds = true
        }
        
        if boderColor != nil {
            btn.layer.borderColor = boderColor?.cgColor
        }
        
        if (image != nil){
            btn.setImage(image, for: .normal)
        }
        btn.imageView?.contentMode = .scaleAspectFill
        
        return btn
    }
    
    func set(title normalTitle: String?,
                  titleColor: UIColor?,
                  fontSize: CGFloat?,
                  backGroundColor backColor: UIColor?,
                  cornerRadius: CGFloat?) {
        
        if normalTitle != nil {
            self.setTitle(normalTitle, for: .normal)
        }
        if titleColor != nil{
            self.setTitleColor(titleColor, for: .normal)
        }
        if fontSize != nil {
            self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize!)
        }
        
        if backColor != nil{
            self.backgroundColor = backColor
        }
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
    }
}


/// 图片与标题的 相对位置
///
/// - top:    图片在上
/// - left:   图片在左
/// - bottom: 图片在下
/// - right:  图片在右
enum MKButtonEdgeInsetsStyle {
    case top , left , bottom, right
}

// MARK: - 设置图片与标题的 相对位置
extension UIButton {
    
    func layoutButton(with style: MKButtonEdgeInsetsStyle, imageTitleSpace space: CGFloat) {
        //    self.backgroundColor = [UIColor cyanColor];
        /**
         *  前置知识点：titleEdgeInsets是title相对于其上下左右的inset，跟tableView的contentInset是类似的，
         *  如果只有title，那它上下左右都是相对于button的，image也是一样；
         *  如果同时有image和label，那这时候image的上左下是相对于button，右边是相对于label的；title的上右下是相对于button，左边是相对于image的。
         */
        // 1. 得到imageView和titleLabel的宽、高
        let imageWith: CGFloat = self.imageView!.frame.size.width
        let imageHeight: CGFloat = self.imageView!.frame.size.height
        
        let labelWidth = self.titleLabel!.intrinsicContentSize.width
        let labelHeight = self.titleLabel!.intrinsicContentSize.height
        
        // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch style {
        case .top:
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - space / 2.0, 0, 0, -labelWidth)
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight - space / 2.0, 0)
            
        case .left:
            imageEdgeInsets = UIEdgeInsetsMake(0, -space / 2.0, 0, space / 2.0)
            labelEdgeInsets = UIEdgeInsetsMake(0, space / 2.0, 0, -space / 2.0)
            
        case .bottom:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight - space / 2.0, -labelWidth)
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight - space / 2.0, -imageWith, 0, 0)
            
        case .right:
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + space / 2.0, 0, -labelWidth - space / 2.0)
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith - space / 2.0, 0, imageWith + space / 2.0)
   
        }
        
        // 4. 赋值
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}



