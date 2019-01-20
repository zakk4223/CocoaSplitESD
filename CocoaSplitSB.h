/*
 * CocoaSplit.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class CocoaSplitApplication, CocoaSplitOutput, CocoaSplitInputSource, CocoaSplitAudioInput, CocoaSplitTransition, CocoaSplitLayoutscript, CocoaSplitLayout;



/*
 * CocoaSplit Scripting Suite
 */

@interface CocoaSplitApplication : SBApplication

- (SBElementArray<CocoaSplitLayout *> *) layouts;
- (SBElementArray<CocoaSplitLayoutscript *> *) layoutscripts;
- (SBElementArray<CocoaSplitAudioInput *> *) audioInputs;
- (SBElementArray<CocoaSplitOutput *> *) outputs;
- (SBElementArray<CocoaSplitTransition *> *) transitions;

@property (copy, readonly) CocoaSplitLayout *activelayout;
@property (copy, readonly) CocoaSplitLayout *staginglayout;
@property (copy, readonly) CocoaSplitLayout *livelayout;
@property BOOL useTransitions;
@property (readonly) BOOL stagingEnabled;

@property (copy, readonly) CocoaSplitAudioInput *streamAudio;
@property (copy, readonly) CocoaSplitAudioInput *previewAudio;
@property BOOL streamRunning;

- (void) goLive;
- (void) swapLayouts;
- (void) startStream;
- (void) stopStream;
- (void) instantRecord;
- (void) toggleStagingView;
- (void) hideStagingView;
- (void) showStagingView;

@end

@interface CocoaSplitOutput : SBObject

- (NSString *) id;
@property (copy) NSString *name;
@property BOOL active;
@property (copy) CocoaSplitLayout *layout;
@property (readonly) BOOL running;
@property (readonly) BOOL errored;
@property (readonly) BOOL isDraining;
@property (readonly) double inputFramerate;
@property (readonly) double bitrateOut;
@property (readonly) NSInteger bufferedFrames;
@property (readonly) NSInteger bufferedSize;
@property (readonly) NSInteger droppedFrames;
@property (readonly) double outputFrameRate;
@property (copy, readonly) NSString *compressor;



@end

@interface CocoaSplitInputSource : SBObject

@property (copy) NSString *name;
@property double opacity;
@property (copy) NSString *uuid;


@end

@interface CocoaSplitAudioInput : SBObject

- (NSString *) id;
@property (copy, readonly) NSString *name;
@property double soundVolume;
@property BOOL enabled;
@property BOOL muted;

- (void) mute;
- (void) unmute;

@end

@interface CocoaSplitTransition : SBObject

@property (copy) NSString *name;
- (NSString *) id;
@property double duration;
@property BOOL active;
@property (readonly) BOOL isToggle;
@property (readonly) BOOL canToggle;

- (void) deactivate;
- (void) activate;
- (void) toggle;
- (void) toggleLive;

@end

@interface CocoaSplitLayoutscript : SBObject

@property (copy) NSString *name;

- (void) runIn:(CocoaSplitLayout *)in_;
- (void) stop;

@end

@interface CocoaSplitLayout : SBObject

- (SBElementArray<CocoaSplitInputSource *> *) inputSources;

- (NSString *) id;
@property (copy) NSString *name;
@property BOOL hasSources;
@property NSInteger width;
@property NSInteger height;
@property NSInteger frameRate;
@property BOOL inStaging;
@property BOOL inLive;

- (void) record;
- (void) stopRecord;
- (void) toggleUsing:(CocoaSplitLayout *)using_ order:(NSString *)order;
- (void) replaceWithUsing:(CocoaSplitLayout *)using_;
- (void) activate;
- (void) mergeInto:(CocoaSplitLayout *)into order:(NSString *)order;
- (void) removeFrom:(CocoaSplitLayout *)from;

@end

