#import "WallPaperSWiftUI-Swift.h"
#import "LivePhotoUtil.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

/**
 * LivePhotoUtil
 * 
 * Utility class for converting regular videos into Apple Live Photos.
 * Handles the complete conversion workflow including video duration adjustment,
 * frame rate conversion, and proper metadata embedding required for Live Photos.
 */
@implementation LivePhotoUtil

+ (void)convertVideo:(NSString*)path complete:(void(^)(BOOL, NSString*))complete {

    // MARK: Metadata File
    NSURL *metaURL = [[NSBundle mainBundle] URLForResource:@"metadata" withExtension:@"mov"];
    
    if (!metaURL) {
        NSLog(@"❌ metadata.mov not found in bundle");
        complete(NO, @"metadata.mov missing from bundle");
        return;
    }

    CGSize livePhotoSize = CGSizeMake(1080, 1920);
    CMTime livePhotoDuration = CMTimeMake(550, 600);
    NSString *assetIdentifier = NSUUID.UUID.UUIDString;

    // MARK: Temp Paths
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;

    NSString *durationPath = [documentPath stringByAppendingPathComponent:@"duration.mp4"];
    NSString *acceleratePath = [documentPath stringByAppendingPathComponent:@"accelerate.mp4"];
    NSString *resizePath = [documentPath stringByAppendingPathComponent:@"resize.mp4"];

    [[NSFileManager defaultManager] removeItemAtPath:durationPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:acceleratePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:resizePath error:nil];

    NSString *finalPath = resizePath;

    Converter4Video *converter = [[Converter4Video alloc] initWithPath:finalPath];

    // MARK: Step 1 - Duration Fix
    [converter durationVideoAt:path
                    outputPath:durationPath
                targetDuration:3
                    completion:^(BOOL success, NSError *error) {

        if (!success) {
            complete(NO, error.localizedDescription);
            return;
        }

        // MARK: Step 2 - Speed Adjust
        [converter accelerateVideoAt:durationPath
                                   to:livePhotoDuration
                           outputPath:acceleratePath
                           completion:^(BOOL success, NSError *error) {

            if (!success) {
                complete(NO, error.localizedDescription);
                return;
            }

            // MARK: Step 3 - Resize
            [converter resizeVideoAt:acceleratePath
                           outputPath:resizePath
                           outputSize:livePhotoSize
                           completion:^(BOOL success, NSError *error) {

                if (!success) {
                    complete(NO, error.localizedDescription);
                    return;
                }

                // MARK: Step 4 - Extract Frame
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:finalPath] options:nil];

                AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                generator.appliesPreferredTrackTransform = YES;
                generator.requestedTimeToleranceAfter = kCMTimeZero;
                generator.requestedTimeToleranceBefore = kCMTimeZero;
                generator.maximumSize = CGSizeMake(1080, 1920);

                CMTime time = CMTimeMakeWithSeconds(0.5, asset.duration.timescale);
                NSArray *times = @[[NSValue valueWithCMTime:time]];

                dispatch_queue_t q = dispatch_queue_create("image", DISPATCH_QUEUE_SERIAL);

                [generator generateCGImagesAsynchronouslyForTimes:times
                                                 completionHandler:^(CMTime requestedTime,
                                                                     CGImageRef image,
                                                                     CMTime actualTime,
                                                                     AVAssetImageGeneratorResult result,
                                                                     NSError *error) {

                    if (!image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(NO, @"Failed to extract image frame");
                        });
                        return;
                    }

                    NSString *picturePath = [documentPath stringByAppendingPathComponent:@"live.heic"];
                    NSString *videoPath = [documentPath stringByAppendingPathComponent:@"live.mov"];

                    [[NSFileManager defaultManager] removeItemAtPath:picturePath error:nil];
                    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];

                    Converter4Image *converter4Image =
                    [[Converter4Image alloc] initWithImage:[UIImage imageWithCGImage:image]];

                    dispatch_async(q, ^{

                        // MARK: Write Image
                        [converter4Image writeWithDest:picturePath assetIdentifier:assetIdentifier];

                        // MARK: Write Video
                        [converter writeWithDest:videoPath
                                 assetIdentifier:assetIdentifier
                                         metaURL:metaURL
                                      completion:^(BOOL success, NSError *error) {

                            if (!success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    complete(NO, error.localizedDescription);
                                });
                                return;
                            }

                            // MARK: Save Live Photo
                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

                                PHAssetCreationRequest *request =
                                [PHAssetCreationRequest creationRequestForAsset];

                                NSURL *photoURL = [NSURL fileURLWithPath:picturePath];
                                NSURL *pairedVideoURL = [NSURL fileURLWithPath:videoPath];

                                PHAssetResourceCreationOptions *photoOptions =
                                [[PHAssetResourceCreationOptions alloc] init];

                                PHAssetResourceCreationOptions *videoOptions =
                                [[PHAssetResourceCreationOptions alloc] init];

                                [request addResourceWithType:PHAssetResourceTypePhoto
                                                     fileURL:photoURL
                                                     options:photoOptions];

                                [request addResourceWithType:PHAssetResourceTypePairedVideo
                                                     fileURL:pairedVideoURL
                                                     options:videoOptions];

                            } completionHandler:^(BOOL success, NSError *error) {

                                dispatch_async(dispatch_get_main_queue(), ^{

                                    if (success) {
                                        complete(YES, @"Live Photo saved successfully");
                                    } else {
                                        complete(NO, error.localizedDescription);
                                    }

                                });

                            }];

                        }];

                    });

                }];

            }];

        }];

    }];

}

@end
