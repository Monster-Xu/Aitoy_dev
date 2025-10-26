//
//  AudioPlayerUsageExample.m
//  AIToys
//
//  使用示例：展示如何使用优化后的AudioPlayerView
//

#import "AudioPlayerView.h"

@interface ExampleViewController : UIViewController <AudioPlayerViewDelegate>
@property (nonatomic, strong) AudioPlayerView *audioPlayer;
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建音频播放器
    NSString *audioURL = @"https://example.com/audio.mp3";
    NSString *title = @"Sample Audio Story";
    NSString *coverURL = @"https://example.com/cover.jpg";
    
    self.audioPlayer = [[AudioPlayerView alloc] initWithAudioURL:audioURL 
                                                      storyTitle:title 
                                                  coverImageURL:coverURL];
    self.audioPlayer.delegate = self;
    
    // 配置拖动行为 - 启用全屏拖动，丝滑体验
    [self.audioPlayer configureDragBehaviorWithEdgeSnapping:NO    // 不启用边缘吸附，允许自由放置
                                           allowOutOfBounds:NO    // 不允许超出屏幕边界
                                          enableFullScreen:YES];  // 启用全屏拖动
    
    // 设置拖动参数 - 优化拖动手感
    [self.audioPlayer setDragParameters:0.3      // 边缘阻力系数（0.1-1.0）
                       decelerationRate:0.92];   // 减速率（0.8-0.98，越高惯性越大）
    
    // 显示播放器
    [self.audioPlayer showInView:self.view];
}

// 如果需要边缘吸附功能，可以这样配置：
- (void)enableEdgeSnapping {
    [self.audioPlayer configureDragBehaviorWithEdgeSnapping:YES   // 启用边缘吸附
                                           allowOutOfBounds:YES   // 允许稍微超出边界
                                          enableFullScreen:YES];  // 保持全屏拖动
}

// 如果需要限制只在播放器区域拖动：
- (void)restrictDragToPlayerArea {
    [self.audioPlayer configureDragBehaviorWithEdgeSnapping:NO    // 不启用边缘吸附
                                           allowOutOfBounds:NO    // 不允许超出边界
                                          enableFullScreen:NO];   // 关闭全屏拖动
}

// 调整拖动手感：
- (void)customizeDragFeel {
    // 更丝滑的设置（低阻力，高惯性）
    [self.audioPlayer setDragParameters:0.2 decelerationRate:0.95];
    
    // 更稳定的设置（高阻力，低惯性）
    // [self.audioPlayer setDragParameters:0.5 decelerationRate:0.88];
}

#pragma mark - AudioPlayerViewDelegate

- (void)audioPlayerDidStartPlaying {
    NSLog(@"▶️ 音频开始播放");
}

- (void)audioPlayerDidPause {
    NSLog(@"⏸️ 音频暂停");
}

- (void)audioPlayerDidFinish {
    NSLog(@"⏹️ 音频播放完成");
}

- (void)audioPlayerDidClose {
    NSLog(@"❌ 播放器已关闭");
    self.audioPlayer = nil;
}

- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // 可以在这里更新UI或处理进度相关逻辑
}

@end

/*
 使用总结：

 🎯 全屏拖动优化特性：
 1. 支持全屏任意位置拖动（除控件区域外）
 2. 丝滑的60fps惯性滑动效果
 3. 智能边界约束和回弹
 4. 实时视觉反馈（缩放、透明度变化）
 5. 可配置的边缘吸附功能

 🎨 拖动参数配置：
 - edgeResistance: 边缘阻力系数（0.1-1.0）
   * 0.1 = 几乎无阻力，可以轻易拖出边界
   * 1.0 = 强阻力，很难拖出边界
 
 - decelerationRate: 惯性减速率（0.8-0.98）
   * 0.8 = 快速停止，低惯性
   * 0.98 = 缓慢停止，高惯性

 🎛️ 三种拖动模式：
 1. 全屏自由拖动 - 最佳体验
 2. 全屏边缘吸附 - 整洁布局
 3. 播放器区域拖动 - 传统模式

 💡 最佳实践：
 - 音乐类应用：启用全屏拖动 + 边缘吸附
 - 视频播放器：启用全屏拖动，不启用边缘吸附
 - 工具类应用：根据需要选择模式
*/