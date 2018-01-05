//
//  YYPraiseEmitterButton.swift
//  YYPraiseEmitterButtonSwift
//
//  Created by 赵天旭 on 2018/1/3.
//  Copyright © 2018年 ZTX. All rights reserved.
//

import UIKit

class YYPraiseEmitterButton: UIButton {
    
    var count = NSInteger()
    var timer = Timer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    fileprivate func initView() {
        self.count = 1
        self.addSubview(self.countLabel)
        
        self.setImage(UIImage(named: "feed_like"), for: .normal)
        self.setImage(UIImage(named: "feed_like_press"), for: .selected)
        
        /// 单点
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapEven(_ :)))
        self.addGestureRecognizer(tap)
        
        /// 添加长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressEven(_ :)))
        self.addGestureRecognizer(longPress)
    }
    
    /// 点赞label
    fileprivate lazy var countLabel : UILabel = {
        let countLabel = UILabel(frame: CGRect(x: -50, y: -100, width: 200, height: 40))
        countLabel.isHidden = true
        return countLabel
    }()
    
    
    /// 发射源
    fileprivate lazy var emitterLayer : CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayer.emitterSize = CGSize(width: 30, height: 30)
        emitterLayer.masksToBounds = false
        return emitterLayer
    }()
    
    fileprivate lazy var imagesArr : NSMutableArray = {
        let imagesArr = NSMutableArray()
        return imagesArr
    }()
}

extension YYPraiseEmitterButton {
    @objc fileprivate func tapEven(_ tap : UIGestureRecognizer) {
        let button = tap.view as? UIButton
        button?.isSelected = !(button?.isSelected)!
    }
    
    @objc fileprivate func longPressEven(_ tap : UIGestureRecognizer) {
        let button = tap.view as? UIButton
        button?.isSelected = true
        if tap.state == .began {
            ///开始动画
            self.beginAnimation()
        }
        else if tap.state == .ended {
            self.stopAnimation()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
    }
    
    /// 开始动画
    fileprivate func beginAnimation() {
        
        /// button动画
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        if self.isSelected {
            keyFrameAnimation.values = [1.5,0.8,1.0,1.2,1.0]
            keyFrameAnimation.duration = 0.5
            ///喷射动画
            self.startAnimation()
        }
        else {
            keyFrameAnimation.values = [0.8,1.0]
            keyFrameAnimation.duration = 0.4
        }
        keyFrameAnimation.calculationMode = kCAAnimationCubic
        self.layer.add(keyFrameAnimation, forKey: "transform.scale")
    }
    
    
    /// 开始喷射动画
    fileprivate func startAnimation() {
        ///添加图片
        for _ in 0...9 {
            let x = arc4random() % 77 + 1;
            let imageStr = String(format: "emoji_%d", x);
            imagesArr.add(imageStr)
        }

        self.countLabel.isHidden = false
        
        /// 点赞label的动画
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyframeAnimation.values = [0.8, 1.0]
        keyframeAnimation.duration = 4.0
        self.countLabel.layer.add(keyframeAnimation, forKey: "transform.scale")
        
        timer = Timer(timeInterval: 0.15, target: self, selector: #selector(changeText), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
        
        //设置展示的cell
        self.emitterLayer.emitterCells = self.emitterCells()
        self.emitterLayer.beginTime = CACurrentMediaTime()
        self.layer.addSublayer(emitterLayer)
    }
    
    fileprivate func stopAnimation() {
        emitterLayer.emitterCells?.removeAll()
        imagesArr.removeAllObjects()
        self.layer.sublayers?.filter({ $0.isKind(of: CAEmitterLayer.self)}).first?.removeFromSuperlayer()
        countLabel.isHidden = true
        timer.invalidate()
    }
    
    fileprivate func emitterCells() -> [CAEmitterCell] {
        var cells = [CAEmitterCell]()
        for imageStr in imagesArr {
            let image = UIImage(named: imageStr as! String)
            let cell = CAEmitterCell()
            cell.birthRate = 2//每秒出现多少粒子
            cell.lifetime = 2//每个粒子存活的时间
            cell.lifetimeRange = 2// 粒子生命周期的范围
            cell.scale = 0.35//粒子的缩放比例
            
            cell.alphaRange = 1 //粒子颜色alpha能改变的范围
            cell.alphaSpeed = -1.0//粒子alpha改变的速度
            cell.yAcceleration = 450//下落的加速度
            
            //设置粒子包含的内容
            let cgimage = image?.cgImage
            cell.contents = cgimage
            cell.name = imageStr as? String//设置name是展示喷射动画和隐藏的
            
            cell.velocity = 450//设置粒子的喷射速度
            cell.velocityRange = 30//设置粒子的平均速度
            cell.emissionRange = CGFloat(Double.pi/2)//设置弹射范围
            cell.spin = CGFloat(Double.pi * 2) // 粒子的平均旋转速度
            cell.spinRange = CGFloat(Double.pi * 2)// 粒子的旋转速度调整范围
            cell.emissionLongitude = CGFloat(3 * Double.pi / 2)
            cells.append(cell)
        }
        return cells
    }
    
    
    /// 改变label文本
    @objc fileprivate func changeText() {
        count = count + 1
        self.countLabel.attributedText = self.getAttributedString(num: count)
        self.countLabel.textAlignment = .center
    }
    
    func getAttributedString(num : NSInteger) -> NSMutableAttributedString? {
        
        //先把num拆分成个位，十位，百位
        let ge = num % 10
        let shi = num % 100 / 10
        let bai = num % 1000 / 100
        
        if num>1000 {
            return nil
        }
        
        let mutStr = NSMutableAttributedString()
        
        ///创建百位显示图
        if bai != 0 {
            let b_attachment = NSTextAttachment()
            b_attachment.image = UIImage(named: String(format: "multi_digg_num_%ld",bai))
            b_attachment.bounds = CGRect(x: 0, y: 0, width: (b_attachment.image?.size.width)!, height: (b_attachment.image?.size.height)!)
            let b_str = NSAttributedString(attachment: b_attachment)
            mutStr.append(b_str)
        }
        
        ///创建十位显示图
        if !(bai == 0 && shi == 0) {
            let s_attachment = NSTextAttachment()
            s_attachment.image = UIImage(named: String(format: "multi_digg_num_%ld",shi))
            s_attachment.bounds = CGRect(x: 0, y: 0, width: (s_attachment.image?.size.width)!, height: (s_attachment.image?.size.height)!)
            let s_str = NSAttributedString(attachment: s_attachment)
            mutStr.append(s_str)
        }
        
        ///创建个位显示图
        if ge >= 0 {
            let g_attachment = NSTextAttachment()
            g_attachment.image = UIImage(named: String(format: "multi_digg_num_%ld",ge))
            g_attachment.bounds = CGRect(x: 0, y: 0, width: (g_attachment.image?.size.width)!, height: (g_attachment.image?.size.height)!)
            let g_str = NSAttributedString(attachment: g_attachment)
            mutStr.append(g_str)
        }
        
        if num<=10 {
            ///鼓励
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "multi_digg_word_level_1")
            attachment.bounds = CGRect(x: 0, y: 0, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
            let attachmentStr = NSAttributedString(attachment: attachment)
            mutStr.append(attachmentStr)
        }
        else if num<=20 {
            ///加油
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "multi_digg_word_level_2")
            attachment.bounds = CGRect(x: 0, y: 0, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
            let attachmentStr = NSAttributedString(attachment: attachment)
            mutStr.append(attachmentStr)
        }
        else {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "multi_digg_word_level_3")
            attachment.bounds = CGRect(x: 0, y: 0, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
            let attachmentStr = NSAttributedString(attachment: attachment)
            mutStr.append(attachmentStr)
        }
        
        return mutStr
    }
}


