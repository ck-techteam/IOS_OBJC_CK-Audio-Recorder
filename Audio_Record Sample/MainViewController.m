//
//  MainViewController.m
//  Audio_Record Sample
//
//  Created by Armor on 06/04/16.
//  Copyright © 2016 Armor. All rights reserved.
//

#import "MainViewController.h"
#import "LLACircularProgressView.h"


@interface MainViewController ()
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *_timer;
    NSTimer *_timerPlay;
}
@property (nonatomic, strong) LLACircularProgressView *circularProgressView;
@property (nonatomic, strong) LLACircularProgressView *circularPlayProgressView;

@end

@implementation MainViewController
@synthesize stopButton, playButton, recordPauseButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title =@"Audio Recorder";
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"Recordedaudio.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordPauseTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AUDIO"];
    if (player.playing)
    {
        [self stopPlay:self];
    }
    
    if (!recorder.recording)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        self.circularProgressView = [[LLACircularProgressView alloc] init];
        self.circularProgressView.tintColor=[UIColor colorWithRed:0.588 green:0.035 blue:0.267 alpha:1.000];
        self.circularProgressView.frame=CGRectMake(130, 70, 50, 50);
        //        self.circularProgressView.center = CGPointMake(CGRectGetMidX(self.recordPauseButton.bounds), 50);
        [self.circularProgressView addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
        self.circularProgressView.backgroundColor=[UIColor colorWithRed:0.976 green:0.980 blue:0.984 alpha:1.000];
        [self.viewVoiceRecord addSubview:self.circularProgressView];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
        //        [recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    //     else {
    //
    //        // Pause recording
    //        [recorder pause];
    ////        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    //    }
    
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"Recordedaudio.m4a"] error:NULL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AUDIO"];
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
}

- (IBAction)playTapped:(id)sender
{
    if (!recorder.recording)
    {
        NSString *strPath=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"AUDIO"]];
        if (strPath.length==0)
        {
            
            NSURL *soundFileURL = [NSURL fileURLWithPath:strPath];
            
            AVAudioPlayer *playerz = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                                            error:nil];
            //Infinite
            
            [playerz play];
        }
        else
        {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
            [player setDelegate:self];
            [player play];
            
            self.circularPlayProgressView = [[LLACircularProgressView alloc] init];
            self.circularPlayProgressView.tintColor=[UIColor colorWithRed:0.588 green:0.035 blue:0.267 alpha:1.000];
            self.circularPlayProgressView.backgroundColor=[UIColor colorWithRed:0.976 green:0.980 blue:0.984 alpha:1.000];
            self.circularPlayProgressView.frame=CGRectMake(400, 58, 50, 50);
            //        self.circularProgressView.center = CGPointMake(CGRectGetMidX(self.recordPauseButton.bounds), 50);
            [self.circularPlayProgressView addTarget:self action:@selector(stopPlay:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewVoiceRecord addSubview:self.circularPlayProgressView];
            
            _timerPlay = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tickPlay:) userInfo:nil repeats:YES];
        }
        
        
    }
}
#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    //    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *audioURL=[documentsDirectory stringByAppendingPathComponent:@"Recordedaudio.m4a"];
    NSData *data=[NSData dataWithContentsOfFile:audioURL];
    if (data)
    {
        [[NSUserDefaults standardUserDefaults] setObject:audioURL forKey:@"AUDIO"];
    }
    
   // [self.circularProgressView removeFromSuperview];
    [stopButton setEnabled:YES];
    [playButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_timerPlay invalidate];
    
   // [self.circularPlayProgressView removeFromSuperview];
    
}

- (void)tick:(NSTimer *)timer
{
    CGFloat progress = self.circularProgressView.progress;
    if (progress<=1.000f)
    {
        [self.circularProgressView setProgress:(progress + (1.0/120.0)) animated:YES];
    }
    else
    {
        [self stop:self];
    }
}

- (void)stop:(id)sender
{
    [_timer invalidate];
   // [self.circularProgressView removeFromSuperview];
    if (recorder.recording)
    {
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
    }
}

- (void)tickPlay:(NSTimer *)timer
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:recorder.url options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    CGFloat progress = self.circularPlayProgressView.progress;
    if (progress<=1.000f)
    {
        [self.circularPlayProgressView setProgress:(progress + (1.0/audioDurationSeconds)) animated:YES];
    }
    else
    {
        
        [_timerPlay invalidate];
        [player stop];
        [self.circularPlayProgressView removeFromSuperview];
    }
    
}
- (void)stopPlay:(id)sender
{
    
    [_timerPlay invalidate];
    [player stop];
   // [self.circularPlayProgressView removeFromSuperview];
    
}

@end
