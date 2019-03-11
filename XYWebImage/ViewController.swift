//
//  ViewController.swift
//  XYWebImage
//
//  Created by MAC005 on 2019/3/11.
//  Copyright © 2019年 MAC005. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let imageView = UIImageView()
    
    @IBAction func imageBtnClicked(_ sender: UIButton) {
        //1，这个方法多次调用url参数不变，就会产生：一个url对应多个operation的场景（通过LoadImageOperation中静态变量）
        //2，这个方法多次调用，每次url参数都不一样，就会产生：一个imageview对应多个url和一个imageview对应多个operation的问题（这个的解决方案就是判断imageview的url和operation的url）
        
        imageView.loadImageWithURL(url: "http://www.pptok.com/wp-content/uploads/2012/08/xunguang-4.jpg")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.frame = CGRect.init(origin: CGPoint.init(x: 20, y: 20), size: CGSize.init(width: 200, height: 250))
        self.view.addSubview(imageView)
    }


}

