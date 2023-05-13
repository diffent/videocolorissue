# videocolorissue
demonstrates video color issue w/ HDR "dolby" videos created on apple devices (extracting images from)

extracts video frames one at a time from a pre-packaged mp4 file that was created w/ HDR dolby video mode on

if you just extract images the old way from this video file, the colors are washed out

if you flip the segmented control to HDR, it uses the proper flags in the video exporter
to export better colors from the video file.  are they 100% accurate?  not sure.  but they
are much better.

search for this bit of code in the ViewController.m file:

self.segCtrl.selectedSegmentIndex == 1

when the above is true,
the required flags are set for AVAssetReaderTrackOutput

this is just a demo for color matching, image orientations and video
orientations are not handled.  
