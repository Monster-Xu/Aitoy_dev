//
//  AudioPlayerView.h
//  AIToys
//
//  Created by Assistant on 2025/10/17.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AudioPlayerViewDelegate <NSObject>
@optional
- (void)audioPlayerDidStartPlaying;
- (void)audioPlayerDidPause;
- (void)audioPlayerDidFinish;
- (void)audioPlayerDidClose;
- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;
@end

@interface AudioPlayerView : UIView

@property (nonatomic, weak) id<AudioPlayerViewDelegate> delegate;

// 拖动行为控制属性
@property (nonatomic, assign) BOOL enableEdgeSnapping;  // 是否启用边缘吸附
@property (nonatomic, assign) BOOL allowOutOfBounds;    // 是否允许超出屏幕边界
@property (nonatomic, assign) BOOL enableFullScreenDrag; // 是否启用全屏拖动

// 新增的初始化方法
- (instancetype)initWithAudioURL:(NSString *)audioURL storyTitle:(NSString *)title coverImageURL:(NSString *)coverImageURL;

// 新增的后台播放初始化方法（不显示UI）
- (instancetype)initWithAudioURL:(NSString *)audioURL backgroundPlay:(BOOL)backgroundPlay;

// 显示和隐藏方法
- (void)showInView:(UIView *)parentView;
- (void)showInView:(UIView *)parentView withFrame:(CGRect)frame;
- (void)showInView:(UIView *)parentView atPosition:(CGPoint)position;
- (void)hide;

// 播放控制方法
- (void)play;
- (void)pause;
- (void)stop;
-(void)rePlay;

// 后台播放方法（直接播放，不显示UI）
- (void)playInBackground;

// 是否正在播放
- (BOOL)isPlaying;

// 新增后台播放相关方法
- (void)setupBackgroundAudioSession;
- (void)setupRemoteTransportControls;
- (void)updateNowPlayingInfo;

// 新增拖动配置方法
- (void)configureDragBehaviorWithEdgeSnapping:(BOOL)enableSnapping 
                              allowOutOfBounds:(BOOL)allowBounds 
                             enableFullScreen:(BOOL)enableFullScreen;
- (void)setDragParameters:(CGFloat)edgeResistance decelerationRate:(CGFloat)deceleration;
@end

NS_ASSUME_NONNULL_END
