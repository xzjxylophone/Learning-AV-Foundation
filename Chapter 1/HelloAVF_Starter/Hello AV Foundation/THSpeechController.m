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

#import "THSpeechController.h"
#import <AVFoundation/AVFoundation.h>

@interface THSpeechController ()
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, copy) NSArray *voices;
@property (nonatomic, copy) NSArray *speechStrings;
@end

@implementation THSpeechController

+ (instancetype)speechController {
    return [[self alloc] init];
}
- (id)init {
    if (self = [super init]) {
        self.synthesizer = [AVSpeechSynthesizer new];
        // 1号语音en-US  2号语音en-GB
        self.voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],[AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]];
        // 需要播放的文字列表
        self.speechStrings = @[@"Hello AV Foundation. How are you?",
                               @"I'm well! Thanks for asking.",
                               @"Are you excited about the book?",
                               @"Very! I have always felt so misunderstood.",
                               @"What's your favorite feature?",
                               @"Oh, they're all my babies.  I couldn't possibly choose.",
                               @"It was great to speak with you!",
                               @"The pleasure was all mine!  Have fun!"
                               ];
    }
    return self;
}
- (void)beginConversation {
    for (NSInteger i = 0; i < self.speechStrings.count; i++) {
        NSString *text = self.speechStrings[i];
        // 创建一个话语
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:text];
        // 1号语音与2号语音来回切换
        utterance.voice = self.voices[i % 2];
        // 播放速率, AVSpeechUtteranceMinimumSpeechRate(0.0)  AVSpeechUtteranceMaximumSpeechRate(1.0)
        utterance.rate = 0.4f;
        // 声音的音调， 在0.5 与2.0 之间
        utterance.pitchMultiplier = 0.8f;
        // 语音合成器在播放下一句之前有段时间的暂停。 可以类似的一个属性是：preUtteranceDelay
        utterance.postUtteranceDelay = 0.1f;
        [self.synthesizer speakUtterance:utterance];
    }
}

@end
