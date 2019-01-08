//
//  AliyunPlayerVodPlayViewController.m
//  AliyunPlayerDemo
//
//  Created by 王凯 on 2017/9/21.
//  Copyright © 2017年 shiping chen. All rights reserved.
//
#import <AVFoundation/AVAsset.h>

#import <AVFoundation/AVAssetImageGenerator.h>

#import <AVFoundation/AVTime.h>
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#import "AliyunPlayerVodPlayViewController.h"
#import "AliyunPlayMessageShowView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AliyunPlayerSDK/AliyunPlayerSDK.h>
#import "Reachability.h"
#import "UIColor+HexColor.h"
#define URLSTRING  @"http://player.alicdn.com/video/aliyunmedia.mp4"
//#define URLSTRING @"http://zicailive.oss-cn-shanghai.aliyuncs.com/gongkaike/chenhongzheng/%E9%99%88%E5%AE%8F%E6%94%BF-%E4%B9%B0%E4%B8%8D%E8%B5%B7%E6%88%BF%EF%BC%8C%E5%B0%B1%E4%B9%B0%E6%88%BF%E5%9C%B0%E4%BA%A7%E8%82%A1%EF%BC%81.mp4?Expires=1511183328&OSSAccessKeyId=LTAINkZhkzaSLNjV&Signature=WYTPS28OCPVRwjq4jZ5HTd676lE%3D"

@interface AliyunPlayerVodPlayViewController ()<UIAlertViewDelegate>
@property (strong, nonatomic)  UIView *contentView;
@property (strong, nonatomic)  UIButton *fullScreenButton;
//@property (strong, nonatomic)  UIButton *startButton;
//@property (strong, nonatomic)  UIButton *stopButton;
@property (strong, nonatomic)  UILabel *leftTimeLabel;
@property (strong, nonatomic)  UILabel *rightTimeLabel;
@property (strong, nonatomic)  UISlider *progressSlider;
@property (nonatomic, strong) UIButton *pauseOrPlayBtn;

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;

//@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
//@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (nonatomic, strong) Reachability *reachability;


@property (nonatomic, assign)BOOL isRunTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong)UIActivityIndicatorView *indicationrView;

@property (nonatomic, strong) AliVcMediaPlayer* mediaPlayer;
@property (nonatomic, strong) AliyunPlayMessageShowView *showMessageView;

@end

@implementation AliyunPlayerVodPlayViewController
-(void)fullScreenClicked:(UIButton*)btn
{
    btn.selected=!btn.selected;
    if(btn.selected)
    {
        [self.contentView removeFromSuperview];
        [[[UIApplication sharedApplication]keyWindow] addSubview:self.contentView];

        [UIView animateWithDuration:0.5f animations:^{
            self.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
            
            //                     publicDetailView.videoView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            self.contentView.frame =  CGRectMake(0,0, screenWidth,screenHeight);
            //            publicDetailView.fullImageView.frame=CGRectMake(screenHeight-29, screenWidth-29, 29,  29);
            
            self.fullScreenButton.frame=CGRectMake(screenHeight-30-15,  screenWidth-30-5, 30,  30);
            [self.contentView addSubview:self.fullScreenButton];
            _pauseOrPlayBtn.frame=CGRectMake(15, self.fullScreenButton.center.y-15, 30, 30);
            [self.contentView addSubview:_pauseOrPlayBtn];
            
            
            _leftTimeLabel.frame=CGRectMake(CGRectGetMaxX(self.pauseOrPlayBtn.frame), self.fullScreenButton.center.y-7, 50, 14);
              [self.contentView addSubview:_leftTimeLabel];
            _rightTimeLabel.frame=CGRectMake(CGRectGetMinX(self.fullScreenButton.frame)-50, self.fullScreenButton.center.y-7, 50, 14);
            [self.contentView addSubview:_rightTimeLabel];
            self.progressSlider.frame=CGRectMake(CGRectGetMaxX(_leftTimeLabel.frame), self.fullScreenButton.center.y-10, screenHeight-CGRectGetMaxX(_leftTimeLabel.frame)*2, 20);
            [self.contentView addSubview:self.progressSlider];

            
            
        }];
    }else
    {
                [self.contentView removeFromSuperview];
        
        
        
        [UIView animateWithDuration:0.5f animations:^{
            self.contentView.transform = CGAffineTransformMakeRotation(0);
            
            
            
            self.contentView.frame =  CGRectMake(0, 0, screenWidth, 0.56*screenWidth);
            [self.view addSubview:self.contentView];

            //                         publicDetailView.playerManager.videoView.frame= publicDetailView.videoView.frame;
            
            
            //           [self.mediaPlayer create:self.contentView];
            //                    _bakeBtn.frame = CGRectMake(10, 20, 30, 30);
            //            publicDetailView.fullImageView.frame=CGRectMake(screenWidth-29,  0.56*screenWidth-29, 29,  29);
            
            self.fullScreenButton.frame=CGRectMake(screenWidth-30-15,  0.56*screenWidth-30-5, 30,  30);
            
            _pauseOrPlayBtn.frame=CGRectMake(15, self.fullScreenButton.center.y-15, 30, 30);
            
            
            _leftTimeLabel.frame=CGRectMake(CGRectGetMaxX(self.pauseOrPlayBtn.frame), self.fullScreenButton.center.y-7, 50, 14);
            _rightTimeLabel.frame=CGRectMake(CGRectGetMinX(self.fullScreenButton.frame)-50, self.fullScreenButton.center.y-7, 50, 14);
            self.progressSlider.frame=CGRectMake(CGRectGetMaxX(_leftTimeLabel.frame), self.fullScreenButton.center.y-10, screenWidth-CGRectGetMaxX(_leftTimeLabel.frame)*2, 20);
        }];
    }
    
}
#pragma mark - 展示log界面
-(AliyunPlayMessageShowView *)showMessageView{
    if (!_showMessageView){
        _showMessageView = [[AliyunPlayMessageShowView alloc] init];
        _showMessageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
        _showMessageView.alpha = 1;
    }
    
    return _showMessageView;
}

#pragma mark - naviBar
- (void)InitNaviBar{
    NSString *backString = NSLocalizedString(@"Back",nil);
    NSString *logString = NSLocalizedString(@"Log",nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:logString style:UIBarButtonItemStylePlain target:self action:@selector(LogButtonItemCliceked:)];
}

- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    [self.mediaPlayer stop];
    [self.mediaPlayer destroy];
    self.mediaPlayer = nil;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self removePlayerObserver];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    self.showMessageView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    [self InitNaviBar];
    self.view.backgroundColor=[UIColor whiteColor];
    self.contentView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 0.56*screenWidth)];
    self.contentView.backgroundColor=[UIColor redColor];
    [self.view addSubview:self.contentView];
  
    self.fullScreenButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenButton.frame=CGRectMake( CGRectGetMaxX(self.contentView.frame)-30-15, CGRectGetMaxY(self.contentView.frame)-30-5, 30, 30);
//    self.fullScreenButton.backgroundColor=[UIColor redColor];
    [self.fullScreenButton setBackgroundImage:[UIImage imageNamed:@"fullScreenBtn"] forState:UIControlStateNormal];
    [self.fullScreenButton addTarget:self action:@selector(fullScreenClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fullScreenButton];
    
    
    _pauseOrPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, self.fullScreenButton.center.y-15, 30, 30)];
    [_pauseOrPlayBtn setBackgroundImage:[UIImage imageNamed:@"dianboPlay"] forState:UIControlStateNormal];
    [_pauseOrPlayBtn setBackgroundImage:[UIImage imageNamed:@"dianboPause"] forState:UIControlStateSelected];
    //            _pauseOrPlayBtn.backgroundColor=[UIColor redColor];
    
    [_pauseOrPlayBtn addTarget:self action:@selector(doPlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_pauseOrPlayBtn];
   
    
    _leftTimeLabel=[[UILabel alloc]init];
    _leftTimeLabel.frame=CGRectMake(CGRectGetMaxX(self.pauseOrPlayBtn.frame), self.fullScreenButton.center.y-7, 50, 14);
//    _leftTimeLabel.center=CGPointMake(_progressSlider.frame.origin.x-30, _progressSlider.center.y);
    
    _leftTimeLabel.font=[UIFont systemFontOfSize:10];
    _leftTimeLabel.textAlignment=NSTextAlignmentCenter;
    _leftTimeLabel.textColor=[UIColor getColorFromHex:@"#0398ff"];
    [self.view addSubview:_leftTimeLabel];
//    _leftTimeLabel.backgroundColor=[UIColor redColor];
    _rightTimeLabel=[[UILabel alloc]init];
    _rightTimeLabel.frame=CGRectMake(CGRectGetMinX(self.fullScreenButton.frame)-50, self.fullScreenButton.center.y-7, 50, 14);
//    _rightTimeLabel.center=CGPointMake(_progressSlider.frame.origin.x+_progressSlider.frame.size.width+30, _progressSlider.center.y);
    _rightTimeLabel.font=[UIFont systemFontOfSize:10];
    _rightTimeLabel.textAlignment=NSTextAlignmentCenter;
    _rightTimeLabel.textColor=[UIColor getColorFromHex:@"#0398ff"];
    [self.view addSubview:_rightTimeLabel];
//    _rightTimeLabel.backgroundColor=[UIColor redColor];
    self.progressSlider = [[UISlider alloc]init];
    //    self.progressSlider.bounds=CGRectMake(0, 0, screenWidth-30*2-15*2-10*2-120, 20);
    //    self.progressSlider.center=CGPointMake(screenWidth/2, _pauseOrPlayBtn.center.y);
    self.progressSlider.frame=CGRectMake(CGRectGetMaxX(_leftTimeLabel.frame), self.fullScreenButton.center.y-10, screenWidth-CGRectGetMaxX(_leftTimeLabel.frame)*2, 20);
    
    [self.progressSlider addTarget:self action:@selector(progressChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"orangeSmallRound"] forState:UIControlStateNormal];
    
    
    [self.view addSubview:self.progressSlider];
//    self.startButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    self.startButton.frame=CGRectMake(0, CGRectGetMaxY(self.contentView.frame)+10, 100, 40);
//    self.startButton.backgroundColor=[UIColor redColor];
//    [self.startButton addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.startButton.tag=201;
//    [self.view addSubview:self.startButton];
    
//    self.stopButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    self.stopButton.frame=CGRectMake(CGRectGetMaxX(self.startButton.frame)+10, CGRectGetMaxY(self.contentView.frame)+10, 100, 40);
//    self.stopButton.backgroundColor=[UIColor redColor];
//    [self.stopButton addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.stopButton.tag=202;
//    [self.view addSubview:self.stopButton];
    
    
    
    
    
    self.indicationrView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicationrView.frame = CGRectMake(0, 0, 100, 100);
    self.indicationrView.center = self.mediaPlayer.view.center;
    self.indicationrView.color = [UIColor clearColor];
    //将这个控件加到父容器中。
    [self.view addSubview:self.indicationrView];
    
    /***************集成部分*******************/
    self.mediaPlayer = [[AliVcMediaPlayer alloc] init];
    [self.mediaPlayer create:self.contentView];
    
    self.mediaPlayer.mediaType = MediaType_AUTO;
    self.mediaPlayer.timeout = 25000;//毫秒
    self.mediaPlayer.dropBufferDuration = 8000;
    /****************************************/
    
    
    //通知
    [self addPlayerObserver];
    
    
    
    
   
    
    //初始设置
    self.isRunTime = YES;
    self.volumeSlider.value = self.mediaPlayer.volume;
    self.brightnessSlider.value = self.mediaPlayer.brightness;
    
    //按钮状态
  
    self.replayButton.enabled = NO;
    self.showMessageView.hidden = YES;
    [self.view addSubview:self.showMessageView];
    [self start];
    // Do any additional setup after loading the view.
  
    
    
}




    
 

- (void)becomeActive{
    self.isRunTime = YES;
}

- (void)resignActive{
    if ([self networkChangePop:NO]) {
        return;
    }
    if (self.mediaPlayer){
        [self.mediaPlayer pause];
       
        self.replayButton.enabled = NO;
        self.isRunTime = NO;
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.indicationrView.center = self.mediaPlayer.view.center;
    self.showMessageView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
}

- (void)networkStateChange{
    
    if(!self.mediaPlayer) return;
    
    [self networkChangePop:NO];
    
}

-(BOOL) networkChangePop:(BOOL)isShow{
    BOOL ret = NO;
    
    switch ([self.reachability currentReachabilityStatus]) {
        case NotReachable:
        {
            ret = YES;
            if (isShow) {
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"notreachable", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"clicked_ok", nil), nil];
                [av show];
            }
            
        }
            break;
        case ReachableViaWiFi:
            
            break;
        case ReachableViaWWAN:
        {
            ret = YES;
            if (self.mediaPlayer.isPlaying) {
                [self pause];
            }
            
            if (isShow) {
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_show_title_cancel",nil) otherButtonTitles:NSLocalizedString(@"clicked_ok",nil), nil];
                
                [av show];
            }
            
            
        }
            break;
        default:
            break;
    }
    
    NSLog(@"reachability -- %ld",(long)[self.reachability currentReachabilityStatus]);
    return ret;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1://ok
        {
            if(self.mediaPlayer){
                if (self.mediaPlayer.isPlaying) {
                    [self resume];
                }else{
                    [self start];
                }
            }
            
            
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - add NSNotification
-(void)addPlayerObserver
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoPrepared:)
                                                 name:AliVcMediaPlayerLoadDidPreparedNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoFinish:)
                                                 name:AliVcMediaPlayerPlaybackDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoError:)
                                                 name:AliVcMediaPlayerPlaybackErrorNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnSeekDone:)
                                                 name:AliVcMediaPlayerSeekingDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnStartCache:)
                                                 name:AliVcMediaPlayerStartCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnEndCache:)
                                                 name:AliVcMediaPlayerEndCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoStop:)
                                                 name:AliVcMediaPlayerPlaybackStopNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoFirstFrame:)
                                                 name:AliVcMediaPlayerFirstFrameNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    
    
}
#pragma mark - remove NSNotification
-(void)removePlayerObserver
{
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter ] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerLoadDidPreparedNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackErrorNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerSeekingDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerStartCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerEndCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackStopNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackStopNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - receive
- (void)OnVideoPrepared:(NSNotification *)notification{
    NSTimeInterval duration = self.mediaPlayer.duration/1000;
    self.progressSlider.maximumValue = duration;
    self.progressSlider.value = self.mediaPlayer.currentPosition;
    self.rightTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",duration]];
    
    [self.showMessageView addTextString:@"onVideoPrepared"];
}

- (void)onVideoFirstFrame :(NSNotification *)notification{
    [self.indicationrView stopAnimating];
    [self.showMessageView addTextString:@"onVideoFirstFrame"];
    
}
- (void)OnVideoError:(NSNotification *)notification{
    NSDictionary* userInfo = [notification userInfo];
    NSString* errorMsg = [userInfo objectForKey:@"errorMsg"];
    NSNumber* errorCodeNumber = [userInfo objectForKey:@"error"];
    NSLog(@"%@-%@",errorMsg,errorCodeNumber);
    
    [self.showMessageView addTextString:[NSString stringWithFormat:@"OnVideoError:-%@-%@",errorMsg,errorCodeNumber]];
    
}
- (void)OnVideoFinish:(NSNotification *)notification{
    
    
    [self.showMessageView addTextString:@"OnVideoFinish"];

    [self replay];
    
    
}
- (void)OnSeekDone:(NSNotification *)notification{
    self.isRunTime = YES;
    [self.showMessageView addTextString:@"OnSeekDone"];
    
}
- (void)OnStartCache:(NSNotification *)notification{
    [self.showMessageView addTextString:@"OnStartCache"];
    
}
- (void)OnEndCache:(NSNotification *)notification{
    [self.showMessageView addTextString:@"OnEndCache"];
    
}

- (void)onVideoStop:(NSNotification *)notification{
    [self.showMessageView addTextString:@"onVideoStop"];
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - clicked

-(void)doPlayOrPause:(UIButton*)btn
{
    btn.selected=!btn.selected;
    if (btn.selected) {
       
        [self pause];
    }else
    {
       [self resume];
    }
}





//- (void)onClicked:(UIButton *)sender {
//
//    switch (sender.tag) {
//        case 201://播放
//        {
//            [self.indicationrView startAnimating];
//            if ([self networkChangePop:YES]) {
//            [self.indicationrView stopAnimating];
//                return;
//            }
//
//            [self start];
//        }
//            break;
//
//        case 202://停止
//        {
//            [self stop];
//        }
//            break;
//
//        case 203://暂停
//        {
//            [self pause];
//        }
//            break;
//
//        case 204://继续
//        {
//            [self resume];
//        }
//            break;
//
//        case 205://重播
//        {
//            [self.indicationrView startAnimating];
//            [self replay];
//        }
//            break;
//
//        default:
//            break;
//    }
//}

- (void)start{
    //本地视频
    NSURL *fileUrl = [NSURL fileURLWithPath:@""];

    //网络视频
    NSURL *strUrl = [NSURL URLWithString:URLSTRING];
    NSURL *url = strUrl;
    AliVcMovieErrorCode err = [self.mediaPlayer prepareToPlay:url];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"play failed,error code is %d",(int)err);
        [self.indicationrView stopAnimating];
        [self.showMessageView addTextString:[NSString stringWithFormat:@"play failed,error code is %d",(int)err]];
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTime:) userInfo:nil repeats:YES];
    [self.timer fire];
    [self.mediaPlayer play];
    [self.contentView bringSubviewToFront:self.fullScreenButton];
    
    [self.showMessageView addTextString:NSLocalizedString(@"log_start_play", nil)];
    
    self.replayButton.enabled = YES;
    
}

- (void)pause{
    AliVcMovieErrorCode err =[self.mediaPlayer pause];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"pause failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"pause failed,error code is %d",(int)err]];
        return;
    }
    [self.showMessageView addTextString:NSLocalizedString(@"log_pause_play", nil)];
    self.replayButton.enabled = NO;
        [self.contentView bringSubviewToFront:self.fullScreenButton];
    
}

- (void)resume{
    AliVcMovieErrorCode err = [self.mediaPlayer play];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"resume failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"resume failed,error code is %d",(int)err]];
        return;
    }
    
    NSString *pauseplay = NSLocalizedString(@"log_resume_play", nil);
    [self.showMessageView addTextString:pauseplay];
    self.replayButton.enabled = NO;
    
}

- (void)replay{
    
    AliVcMovieErrorCode err = [self.mediaPlayer stop];
    if(err != ALIVC_SUCCESS) {
        [self.indicationrView stopAnimating];
        NSLog(@"stop failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"stop failed,error code is %d",(int)err]];
        return;
    }
    [self.showMessageView addTextString:NSLocalizedString(@"log_re_play", nil)];
    
    //本地视频
    NSURL *fileUrl = [NSURL fileURLWithPath:@""];
    //网络视频
    NSURL *strUrl = [NSURL URLWithString:URLSTRING];
    
    NSURL *url = strUrl;
    
    
    err = [self.mediaPlayer prepareToPlay:url];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"preprare failed,error code is %d",(int)err);
        
        if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
        [self.showMessageView addTextString:[NSString stringWithFormat:@"prepare failed,error code is %d",(int)err]];
        return;
    }
    self.progressSlider.value = 0.0;
    self.leftTimeLabel.text= @"00:00:00";
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTime:) userInfo:nil repeats:YES];
    [self.timer fire];
    [self.mediaPlayer play];
    
    self.replayButton.enabled = YES;
    
}

- (void)stop{
    AliVcMovieErrorCode err = [self.mediaPlayer stop];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"stop failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"stop failed,error code is %d",(int)err]];
        return;
    }
    
    err = [self.mediaPlayer reset];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"reset failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"reset failed,error code is %d",(int)err]];
        return;
    }
    
    [self.showMessageView addTextString:NSLocalizedString(@"log_stop_play", nil)];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.progressSlider.value = 0.0;
    self.leftTimeLabel.text= @"00:00:00";
    
    
   
    self.replayButton.enabled = NO;
    
}

- (void)runTime:(NSTimer *)timer{
    
    
    
    if (self.isRunTime&&self.mediaPlayer){
        self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",self.mediaPlayer.currentPosition/1000]];
        [self.progressSlider setValue:self.mediaPlayer.currentPosition/1000 animated:YES];
        NSLog(@"value time-- %f ,currentPosition --- %f",self.progressSlider.value,self.mediaPlayer.currentPosition/1000);
    }
    
}


- (void)progressChanged:(UISlider *)sender {
    self.isRunTime = NO;
    self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",sender.value]];
    AliVcMovieErrorCode code = [self.mediaPlayer seekTo:sender.value*1000];
    if (code == ALIVC_SUCCESS) {
        NSLog(@"value slider-- %f ,currentPosition---%f",sender.value,self.mediaPlayer.currentPosition/1000);
    }
}


- (IBAction)volumeSliderChanged:(UISlider *)sender {
    [self.mediaPlayer setVolume:sender.value];
}
- (IBAction)bringhtnessSliderChanged:(UISlider *)sender {
    [self.mediaPlayer setBrightness:sender.value];
}




-(NSString *)getMMSSFromSS:(NSString *)totalTime{
    NSInteger seconds = [totalTime integerValue];
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
