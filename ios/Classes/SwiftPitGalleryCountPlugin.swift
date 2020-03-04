import Flutter
import UIKit
import Photos

public class SwiftPitGalleryCountPlugin: NSObject, FlutterPlugin {
    var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
           self.messenger = messenger;
           super.init();
    }
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pit_gallery_count", binaryMessenger: registrar.messenger())
        let instance = SwiftPitGalleryCountPlugin(messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method.elementsEqual("getGalleryCount")){
            result(getGalleryCount())
        } else if(call.method.elementsEqual("getImageList")) {
            guard let args = call.arguments as? [String: Any] else {
               return result(FlutterMethodNotImplemented)
            }
            let size: Int = args["countImage"] as! Int
            let sortBy: String =  args["sortBy"] as! String
            let sortType: String = args["sortType"] as! String
            
            result(getImageList(size: size, sortBy: sortBy, sortType: sortType))
            
        } else if(call.method.elementsEqual("getAlbumOriginal")){
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let assetId = arguments["assetId"] as! String
            let maxSize = (arguments["maxSize"] ?? 0 as AnyObject) as! Int
            self.getAlbumOriginal(assetId: assetId, maxSize: maxSize, result: result)
            
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func getSortType(sortType: String)->Bool {
        switch sortType {
        case "ASC":
            return true
        case "DESC":
            return false
        default:
            return true
        }
    }
    
    public func getGalleryCount() -> Int {
        let fetchOptions = PHFetchOptions()
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        return allPhotos.count
    }
    
    public func getAlbumOriginal(assetId: String, maxSize: Int, result: @escaping FlutterResult) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
                
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
        
        assets.enumerateObjects{(object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            print("count => \(count)")
            if object is PHAsset{
                let asset = object as! PHAsset
                let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                let ID: PHImageRequestID =  manager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: {
                    (image: UIImage?, info) in
                    print("info => \(info)")
                    if info != nil {
                        if maxSize != 0 {
                            let initialWidth = image?.size.width ?? 0.0;
                            let initialHeight = image?.size.height ?? 0.0;
                            let floatMaxSize = CGFloat(maxSize);
                            let width: CGFloat = initialHeight.isLess(than: initialWidth) ? floatMaxSize : (initialWidth / initialHeight * floatMaxSize);
                            let height: CGFloat = initialWidth.isLessThanOrEqualTo(initialHeight) ? floatMaxSize : (initialHeight / initialWidth * floatMaxSize);
                            let newSize = CGSize(width: width, height: height);
                            let rect = CGRect(x: 0, y: 0, width: width, height: height)
                            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                            image!.draw(in: rect)
                            let newImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            
                            self.messenger.send(onChannel: "pit_gallery_count/\(assetId)", message: newImage!.jpegData(compressionQuality: CGFloat(1)))
                        } else {
                            self.messenger.send(onChannel: "pit_gallery_count/\(assetId)", message: image!.jpegData(compressionQuality: CGFloat(1)))
                        }
                    } else {
                        print("nilllll")
                    }
                })
                if (PHInvalidImageRequestID != ID) {
                    result(true);
                }
            }
        }
    }
    
    
    public func getImageList(size: Int, sortBy: String, sortType: String) -> [[String: Any]] {
       
        var results: [[String: Any]] = []
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.getSortType(sortType: sortType))]
        let imageRequestOptions = PHImageRequestOptions()
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageCount: Int
       
        
        if(assets.count < size) {
            imageCount = assets.count
        } else {
            imageCount = size
        }
         if #available(iOS 9, *) {
            for i in 0..<imageCount{
                var res: [String: Any] = [:]
                let asset = assets[i]
                let allPhotos = PHAssetResource.assetResources(for: asset)
              
                let dateCreated: Date? = asset.creationDate
            
                let timeInterval = dateCreated!.timeIntervalSince1970
                let dateInt = Int(timeInterval)
            
                res["_display_name"] = allPhotos.first?.originalFilename
                res["_data"] = asset.localIdentifier
                res["_size"] = "\(allPhotos.first?.value(forKey: "fileSize") ?? 0)"
                res["latitude"] = "\(asset.location?.coordinate.latitude ?? 0.0)"
                res["longitude"] = "\(asset.location?.coordinate.longitude ?? 0.0)"
                res["datetaken"] = "\(dateInt)"
                results.append(res)
            }
        }
        
        
        return results
    }
    
//    public func getImageList2(param: [String], fllutterResult: @escaping FlutterResult) -> Void {
//        var results: [[String: Any]] = []
//        let fetchOptions = PHFetchOptions()
//        let imageRequestOptions = PHImageRequestOptions()
//        let test = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//        if test.count > 0 {
//            for i in 0..<test.count {
//                var res: [String: Any] = [:]
//                let asset = test[i]
//                if #available(iOS 9.0, *) {
//                    let allPhotos = PHAssetResource.assetResources(for: asset)
//                    var path: Any?
//
//                    PHImageManager.default().requestImageData(for: asset, options: imageRequestOptions, resultHandler: { imageData, dataUTI, orientation, info in
//                        if info?["PHImageFileURLKey"] != nil {
//                            path = info?["PHImageFileURLKey"] as! URL
//                            let urls: URL = path as! URL
//                            var dateCreated: Date? = asset.creationDate
//                            let formatter = DateFormatter()
//                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//                            var dateString: String = formatter.string(from: dateCreated ?? Date())
//
//                            if(param.count>0){
//                                for index in 0..<param.count{
//                                    switch(param[index]){
//                                    case "imageName":
//                                        res["imageName"] = allPhotos.first?.originalFilename
//                                        break
//                                    case "imagePath":
//                                        res["imagePath"] = urls.absoluteString
//                                        break
//                                    case "dateTaken":
//                                        res["dateTaken"] = dateString
//                                        break
//                                    case "imageSize":
//                                        res["imageSize"] = allPhotos.first?.value(forKey: "fileSize")
//                                        break
//                                    case "imageLatitude":
//                                        res["imageLatitude"] = asset.location?.coordinate.latitude
//                                        break
//                                    case "imageLongitude":
//                                        res["imageLongitude"] = asset.location?.coordinate.longitude
//                                        break
//                                    default:
//                                        break
//                                    }
//                                }
//                            } else {
//                                res["imageName"] = allPhotos.first?.originalFilename
//                                res["imageSize"] = allPhotos.first?.value(forKey: "fileSize")
//                                res["imagePath"] = urls.absoluteString
//                                res["dateTaken"] = dateString
//                                res["imageLatitude"] = asset.location?.coordinate.latitude
//                                res["imageLongitude"] = asset.location?.coordinate.longitude
//                            }
//                            results.append(res)
//                            print(i)
//                            if(i == test.count - 1) {
//                                print(results)
//                                print("Selesai")
//                                fllutterResult(results)
//                            }
//                        }
//                    })
//                }
//            }
//        } else {
//            fllutterResult(results)
//        }
//    }

    
}
