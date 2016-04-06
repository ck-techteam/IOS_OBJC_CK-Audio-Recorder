//
//  MainViewController.h
//  Audio_Record Sample
//
//  Created by Armor on 06/04/16.
//  Copyright © 2016 Armor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LLACircularProgressView.h"


@interface MainViewController : UIViewController<AVAudioRecorderDelegate,
AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *viewVoiceRecord;

@end
