//
//  LoadImageOperation.swift
//  SDWebImage
//
//  Created by MAC005 on 2019/3/1.
//  Copyright © 2019年 MAC005. All rights reserved.
//

/*
问题：1 imageView去加载A图片的时候，网速很慢，m那么还没加载完，然后imageView切换任务，去加载B图片，最终imageView要展示的是B图片
 
 当imageView切换任务的时候取消上一任务，添加取消节点,节点越多取消的准确性越高
 
 2,去重，当两个imageview去加载同一个url图片，如果不做处理，会同时开启两个同样的网络操作
 
 */

import UIKit

class LoadImageOperation: Operation {
    
    fileprivate static var __reTaskInfo = {
        
       return Dictionary<String,Array<UIImageView>>()
    }()

    var urlStr : String?
    weak var imageview:UIImageView?
    let syCache = SYImageCache()
    
    
    override func main() {
        print("开始执行任务")
        
        //1 去缓存查找是否有缓存
        if let cacheImage = syCache.searchImage(imageKey: urlStr){
            
            //1.1如果图片已经存在，那么就直接加载出来
            loadImageInMain(bitmap: cacheImage)
            return
        }
        
        //1.2判断是否已经开启了同一个任务
        if var arry = LoadImageOperation.__reTaskInfo[self.urlStr ?? ""]{
            
            arry.append(self.imageview!)
            return
            
        }
        else{
            var array = Array<UIImageView>()
            array.append(self.imageview!)
            LoadImageOperation.__reTaskInfo[self.urlStr ?? ""] = array
       }
        
        //2网络下载图片
        if let imageData = syLoadImageNet() {
            //3bitmap处理
            if let bitmap = createBitmapImage(image: UIImage.init(data: imageData)){
                
                //4把图片存入缓存                
                bitmap.saveIamgeToSYCache(fileName: urlStr!)
                
                //5加载图片（主线程上加载）
                loadImageInMain(bitmap: bitmap)
                
                //6去重
                reloadSameTask(bitmap: bitmap)
            }
        }
    }
    
    //2，下载图片数据,同步操作
    func syLoadImageNet() -> Data? {
        
        let url = URL.init(string: urlStr ?? "")
        let urlSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
        
        let sem = DispatchSemaphore.init(value: 0)
        
        var imageData:Data?
        let netTask = urlSession.dataTask(with: url!) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            
            if httpResponse?.statusCode==404 || error != nil{
                
                print("图片下载失败")
            }else{
                
                imageData=data
            }
            
            sem.signal()
        }
        
        netTask.resume()
        
        sem.wait()
        
        return imageData
    }
    
    //3，bitmap处理
    func createBitmapImage(image:UIImage?) -> UIImage? {
        
        if image==nil {
            return nil
        }
        let imageRef = (image!.cgImage)!
        
        var colorSpace = imageRef.colorSpace
        if colorSpace == nil {
            colorSpace = CGColorSpaceCreateDeviceRGB()
        }
        
        
        //1,准备好一个上下文,场景一个bitmap上下文
        let context = CGContext.init(data: nil, width: imageRef.width, height: imageRef.height, bitsPerComponent: imageRef.bitsPerComponent, bytesPerRow: imageRef.bytesPerRow, space: colorSpace!, bitmapInfo: imageRef.bitmapInfo.rawValue)
        
        //2,图片绘制到上下文
        context?.draw(imageRef, in: CGRect.init(x: 0, y: 0, width: imageRef.width, height: imageRef.height))
        
        //3，生成bitmap
        if let cgBitmapImage = context?.makeImage() {
            let bitmapImage = UIImage.init(cgImage: cgBitmapImage)
            return bitmapImage
        }
        return nil
    }
    
    func loadImageInMain(bitmap:UIImage) {
        
        //5加载图片（在主线程上加载）
        DispatchQueue.main.async {
            
            if self.imageview?.urlStr != self.urlStr{
                return
            }

            self.imageview?.image=bitmap
        }
    }
    
    func reloadSameTask(bitmap:UIImage) {
        if let arr = LoadImageOperation.__reTaskInfo[self.urlStr ?? ""] {
            
                for imageView in arr{
                    
                    if imageView == self.imageview{
                        continue
                    }
                    
                    if(imageView.urlStr == self.urlStr){
                        DispatchQueue.main.async {
                            imageView.image=bitmap
                        }
                    }
                }
            LoadImageOperation.__reTaskInfo[self.urlStr!]=nil
        }
    }
}


//一个operation对应多个imageview
