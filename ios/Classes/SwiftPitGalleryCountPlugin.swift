import Flutter
import UIKit
import Photos

public class SwiftPitGalleryCountPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pit_gallery_count", binaryMessenger: registrar.messenger())
        let instance = SwiftPitGalleryCountPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    public func getGalleryCount() -> Int {
        let fetchOptions = PHFetchOptions()
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        return allPhotos.count
    }
    
    public func getImageList(param: [String], fllutterResult: @escaping FlutterResult) -> Void {
        var results: [[String: Any]] = []
        let fetchOptions = PHFetchOptions()
        let imageRequestOptions = PHImageRequestOptions()
        let test = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if test.count > 0 {
            for i in 0..<test.count {
                var res: [String: Any] = [:]
                let asset = test[i]
                if #available(iOS 9.0, *) {
                    let allPhotos = PHAssetResource.assetResources(for: asset)
                    var path: Any?
                    
                    PHImageManager.default().requestImageData(for: asset, options: imageRequestOptions, resultHandler: { imageData, dataUTI, orientation, info in
                        if info?["PHImageFileURLKey"] != nil {
                            path = info?["PHImageFileURLKey"] as! URL
                            let urls: URL = path as! URL
                            var dateCreated: Date? = asset.creationDate
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            
                            var dateString: String = formatter.string(from: dateCreated ?? Date())
        
                            if(param.count>0){
                                for index in 0..<param.count{
                                    switch(param[index]){
                                    case "imageName":
                                        res["imageName"] = allPhotos.first?.originalFilename
                                        break
                                    case "imagePath":
                                        res["imagePath"] = urls.absoluteString
                                        break
                                    case "dateTaken":
                                        res["dateTaken"] = dateString
                                        break
                                    case "imageSize":
                                        res["imageSize"] = allPhotos.first?.value(forKey: "fileSize")
                                        break
                                    case "imageLatitude":
                                        res["imageLatitude"] = asset.location?.coordinate.latitude
                                        break
                                    case "imageLongitude":
                                        res["imageLongitude"] = asset.location?.coordinate.longitude
                                        break
                                    default:
                                        break
                                    }
                                }
                            } else {
                                res["imageName"] = allPhotos.first?.originalFilename
                                res["imageSize"] = allPhotos.first?.value(forKey: "fileSize")
                                res["imagePath"] = urls.absoluteString
                                res["dateTaken"] = dateString
                                res["imageLatitude"] = asset.location?.coordinate.latitude
                                res["imageLongitude"] = asset.location?.coordinate.longitude
                            }
                            results.append(res)
                            print(i)
                            if(i == test.count - 1) {
                                print(results)
                                print("Selesai")
                                fllutterResult(results)
                            }
                        }
                    })
                }
            }
        } else {
            fllutterResult(results)
        }
    }
    
    
}
