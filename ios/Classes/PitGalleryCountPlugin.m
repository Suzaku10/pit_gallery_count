#import "PitGalleryCountPlugin.h"
#import <pit_gallery_count/pit_gallery_count-Swift.h>

@implementation PitGalleryCountPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPitGalleryCountPlugin registerWithRegistrar:registrar];
}
@end
