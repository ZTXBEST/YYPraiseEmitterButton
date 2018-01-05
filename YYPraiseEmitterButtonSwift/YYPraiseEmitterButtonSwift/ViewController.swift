//
//  ViewController.swift
//  YYPraiseEmitterButtonSwift
//
//  Created by 赵天旭 on 2018/1/3.
//  Copyright © 2018年 ZTX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let praiseEmitterButton = YYPraiseEmitterButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        praiseEmitterButton.center = self.view.center
        self.view.addSubview(praiseEmitterButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

