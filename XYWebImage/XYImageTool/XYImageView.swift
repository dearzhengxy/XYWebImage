//
//  SYImageView.swift
//  XYWebImage
//
//  Created by MAC005 on 2019/3/1.
//  Copyright © 2019年 MAC005. All rights reserved.
//

import UIKit

fileprivate let _syOperationQueue:OperationQueue = {
    
    let opQueue = OperationQueue.init()
    opQueue.maxConcurrentOperationCount = 5
    return opQueue
    
}()

fileprivate var __urlStr:String = "urlStr"

extension UIImageView{
    
    var urlStr:String? {
      get{
        return objc_getAssociatedObject(self, &__urlStr) as? String
      }
     set{
          objc_setAssociatedObject(self,&__urlStr,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    
    func loadImageWithURL(url:String) {
        
        self.urlStr = url
        //负责执行图片加载任务
        let loadOperation = LoadImageOperation()
        loadOperation.imageview = self
        loadOperation.urlStr = url
        
        _syOperationQueue.addOperation(loadOperation)

    }
    
}
