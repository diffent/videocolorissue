//
//  ViewController.m
//  videcolorissue
//
//  Created by bk on 10/12/22.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property(strong) IBOutlet UIImageView * outputImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)anim {
   [self showVideo];
}

- (CGImageRef)CGImageFromCIImageDemo:(CIImage *)img scale:(CGFloat)scale orientation:(UIImageOrientation)orientation
{
            
            CGRect r = [img extent];

            static CIContext * context = nil;
            
            if (!context) {
                NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
                context = [CIContext contextWithOptions:options];
            }

            CGImageRef cgout = [context createCGImage:img fromRect:[img extent]];

            return cgout;
     
}

// read video a frame at a time and show on a UIImage

-(void)showVideo {

    NSBundle* bundle = [NSBundle mainBundle];
    NSString* vidpath = [bundle pathForResource:@"DDQeYM8vZy2Ec7" ofType:@"mp4"];

    NSString * vidurl = [@"file://" stringByAppendingString:vidpath];
    
    NSURL * url = [NSURL URLWithString:vidurl];

    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:@{
      AVURLAssetAllowsCellularAccessKey : @YES,
      AVURLAssetAllowsExpensiveNetworkAccessKey : @YES
    }];

    NSError * error = nil;

    AVAssetReader * asset_reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];

    if (error == nil)
    {
        NSArray* video_tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        
        AVAssetTrack* video_track = [video_tracks firstObject];
        
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        // kCVPixelFormatType_32BGRA
        // 420YpCbCr8BiPlanarFullRange
        
        [dictionary setObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    
        ] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
        
        if (self.segCtrl.selectedSegmentIndex == 1)
        dictionary[AVVideoColorPropertiesKey] =
        
            @{AVVideoColorPrimariesKey:
                AVVideoColorPrimaries_ITU_R_709_2,
            AVVideoTransferFunctionKey:
                AVVideoTransferFunction_ITU_R_709_2,
            AVVideoYCbCrMatrixKey:
                AVVideoYCbCrMatrix_ITU_R_709_2};
        
        AVAssetReaderTrackOutput* asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:video_track outputSettings:dictionary];
        
        [asset_reader addOutput:asset_reader_output];
        
        [asset_reader startReading];
        

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            while ( [asset_reader status] == AVAssetReaderStatusReading )
            {
                usleep(20000);
                
                CMSampleBufferRef buffer;

                buffer = [asset_reader_output copyNextSampleBuffer];
                
                CVPixelBufferRef inputPixelBuffer = CMSampleBufferGetImageBuffer(buffer);
                
                CIImage* ciImage = [CIImage imageWithCVPixelBuffer:inputPixelBuffer]; // one vid frame?
                
                CVPixelBufferRelease(inputPixelBuffer);
                
                CGImageRef inimg = NULL;
                
                inimg = [self CGImageFromCIImageDemo:ciImage scale:1.0 orientation:0]; // ignore orientation for now
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    UIImage * toshow = [UIImage imageWithCGImage:inimg];
                    
                    CGImageRelease(inimg);

                    self.outputImageView.image = toshow;
                    
                
                });
                
            }
            
            [self showVideo]; // restart
        });
        
    }
    
}
@end
