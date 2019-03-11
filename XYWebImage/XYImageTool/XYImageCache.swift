//
//  SYImageCache.swift
//  XYWebImage
//
//  Created by MAC005 on 2019/3/1.
//  Copyright © 2019年 MAC005. All rights reserved.
//

import UIKit

class SYImageCache {

    let cacheDocPath:String
    
    static var imageMemberCache = {
        
        return NSCache<NSString, UIImage>()
    }()
    
    fileprivate static let __syimageCache:SYImageCache = {
        return SYImageCache.init()
    }()
    
    static func shareInstance()->SYImageCache{
        
        return __syimageCache
    }
    
    init() {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! as NSString
        
        cacheDocPath = docPath.appendingPathComponent("SYImageCache")
        
        if FileManager.default.fileExists(atPath: cacheDocPath, isDirectory: nil) == false {
            
            do {
                try FileManager.default.createDirectory(atPath: cacheDocPath, withIntermediateDirectories: false, attributes: nil)

                
            }catch{
                print("缓存文件夹创建失败")
            }
        }
        
        
        
    }
    
    //1，查找
    func searchImage(imageKey:String?) -> UIImage? {
        
        if let imageName = imageKey {
            
            //1.1 从 NSCache查找
            if let cacheImage = SYImageCache.imageMemberCache.object(forKey: imageName.syImageFileName() as NSString){
                
                return cacheImage
            }
            
            //1.2 本地SYImageCache文件夹下查找,http://斜杠也是文件路径的一部分
            
            let imagefilePath = cacheDocPath.appending("/\(imageName.syImageFileName())")
            
            return UIImage.init(contentsOfFile: imagefilePath)

        }

        return nil;
    }
}

extension UIImage{
    
    func saveIamgeToSYCache(fileName:String) {
        if let imageData = self.pngData() {
            
            //2.1存cache
            SYImageCache.imageMemberCache.setObject(self, forKey: fileName.syImageFileName() as NSString)
            
            //2.2 存本地文件
            var filePath = SYImageCache.shareInstance().cacheDocPath as NSString
            
            filePath=filePath.appendingPathComponent(fileName.syImageFileName()) as NSString
            let url = URL.init(fileURLWithPath: filePath as String)
            
            do{
                try imageData.write(to: url, options: .atomicWrite)

            }catch{
                print("写入失败")
                
            }
        }
    }
    
    
}

extension String{
    func syImageFileName()-> String {
        if let tmpStr = self as NSString? {
            return tmpStr.replacingOccurrences(of: "/", with: "")
        }else{
            return ""
        }
    }
    
    
}
