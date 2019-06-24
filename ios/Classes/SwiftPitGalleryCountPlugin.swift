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
        if call.method.elementsEqual("getGalleryCount"){
            let count = getGalleryCount()
            result(count)
        }
    }
    
    public func getGalleryCount() -> Int {
        let fetchOptions = PHFetchOptions()
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        return allPhotos.count
    }
}
