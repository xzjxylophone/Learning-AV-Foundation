//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THPlayerController.h"
#import <AVFoundation/AVFoundation.h>

@interface THPlayerController ()
@property (nonatomic, copy) NSArray<AVAudioPlayer *> *players;

@end

@implementation THPlayerController

#pragma mark - init & dealloc
- (id)init {
    if (self = [super init]) {
        AVAudioPlayer *guitarPlayer = [self playerForFile:@"guitar"];
        AVAudioPlayer *bassPlayer = [self playerForFile:@"bass"];
        AVAudioPlayer *drumsPlayer = [self playerForFile:@"drums"];
        self.players = @[guitarPlayer, bassPlayer, drumsPlayer];
        self.playing = NO;
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        
        
        
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"userInfo:%@", userInfo);
    AVAudioSessionInterruptionType type = [userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    switch (type) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [self stop];
            if ([self.delegate respondsToSelector:@selector(playbackStopped)]) {
                [self.delegate playbackStopped];
            }
        }
            break;
        case AVAudioSessionInterruptionTypeEnded:
        default:
        {
            AVAudioSessionInterruptionOptions options = [userInfo[AVAudioSessionInterruptionOptionKey] integerValue];
            if (options == AVAudioSessionInterruptionOptionShouldResume) {
                [self play];
                if ([self.delegate respondsToSelector:@selector(playbackBegan)]) {
                    [self.delegate playbackBegan];
                }
            }
        }
            break;
    }
}
- (void)audioSessionRouteChangeNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"userInfo:%@", userInfo);
    AVAudioSessionRouteChangeReason reason = [userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            [self stop];
            if ([self.delegate respondsToSelector:@selector(playbackStopped)]) {
                [self.delegate playbackStopped];
            }
        }
            break;
            
        default:
        {
            // Do Nothing
        }
            break;
    }
}

#pragma mark - Private
- (AVAudioPlayer *)playerForFile:(NSString *)name {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"caf"];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (player) {
        player.numberOfLoops = -1; // 无限循环
        player.enableRate = YES;
        [player prepareToPlay];
    } else {
        NSLog(@"Error creating player: %@", [error localizedDescription]);
    }
    return player;
}


#pragma mark - Public Method
- (void)play {
    // 可以考虑加锁
    if (!self.playing) {
        // 从一个播放器获取当前时间然后延迟一段时间后，让所有的播放器同时播放音频，这样所有的播放器可以保持紧密同步了
        NSTimeInterval delayTime = [self.players[0] deviceCurrentTime] + 0.01;
        for (AVAudioPlayer *player in self.players) {
            [player playAtTime:delayTime];
        }
        self.playing = YES;
    }
}

- (void)stop {
    if (self.playing) {
        for (AVAudioPlayer *player in self.players) {
            [player stop];
            // 让播放进度回到音频文件的原点
            player.currentTime = 0.0f;
        }
        self.playing = NO;
    }
}

- (void)adjustRate:(float)rate {
    for (AVAudioPlayer *player in self.players) {
        player.rate = rate;
    }
}

- (void)adjustPan:(float)pan forPlayerAtIndex:(NSUInteger)index {
    if ([self isVailidIndex:index]) {
        AVAudioPlayer *player = self.players[index];
        player.pan = pan;
    }
}

- (void)adjustVolume:(float)volume forPlayerAtIndex:(NSUInteger)index {
    if ([self isVailidIndex:index]) {
        AVAudioPlayer *player = self.players[index];
        player.volume = volume;
    }
}

- (BOOL)isVailidIndex:(NSUInteger)index {
    return index == 0 || index < self.players.count;
}

@end
