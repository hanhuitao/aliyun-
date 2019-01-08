//
//  AliyunPlayerLivePlayerViewController.m
//  AliyunPlayerDemo
//
//  Created by 王凯 on 2017/9/21.
//  Copyright © 2017年 shiping chen. All rights reserved.
//
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#import "AliyunPlayMessageShowView.h"

#import "AliyunPlayerLivePlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
//#import "AliyunPlayerDemoHeader.h"
#import <AliyunPlayerSDK/AliyunPlayerSDK.h>
#import "Reachability.h"
#define LIVE_URL @"http://flv3.bn.netease.com/videolib3/1604/14/LSwHa2712/SD/LSwHa2712-mobile.mp4"
//#define LIVE_URL  @"rtmp://live.hkstv.hk.lxdns.com/live/hks"
//#define LIVE_URL  @"http://live.52hyx.cn/kwl/c.flv"
//#define LIVE_URL      @"http://live.52hyx.cn/kangwl/stock_kwl.flv?auth_key=1510139461-0-0-2207dd02b2ba95e0d147a019ecbb43e7"
//#define LIVE_URL       @"rtmp://video-center.alivecdn.com/kwl/"

//#define LIVE_URL @"rtmp://send1.douyu.com/live"



@interface AliyunPlayerLivePlayViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (strong, nonatomic)  UIView *contentView;
@property (strong, nonatomic)  UIButton *startButton;
@property (strong, nonatomic)  UIButton *stopButton;
@property (strong, nonatomic)  UIButton *fullScreenButton;

@property (strong, nonatomic)  UISwitch *muteSwitch;
@property (strong, nonatomic)  UISlider *volmeSlider;
@property (strong, nonatomic)  UISlider *brightSlider;

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong)UIActivityIndicatorView *indicationrView;
@property (nonatomic, assign)BOOL isPause;

@property (nonatomic, strong) AliVcMediaPlayer* mediaPlayer;
@property (nonatomic, strong) AliyunPlayMessageShowView *showMessageView;

@end

@implementation AliyunPlayerLivePlayViewController
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
//- (void)InitNaviBar{
//    NSString *backString = NSLocalizedString(@"naviBack", nil);
//    NSString *logString = NSLocalizedString(@"show_log", nil);
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:logString style:UIBarButtonItemStylePlain target:self action:@selector(LogButtonItemCliceked:)];
//}

- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    [self.mediaPlayer stop];
    [self.mediaPlayer destroy];
    self.mediaPlayer = nil;
    [self removePlayerObserver];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    self.showMessageView.hidden = NO;
}
-(void)fullScreenClicked:(UIButton*)btn
{
    btn.selected=!btn.selected;
    if(btn.selected)
    {
        [self.contentView removeFromSuperview];
        //                    [self setNeedsStatusBarAppearanceUpdate];
        //                                        self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
        
        //                    publicDetailView.videoView.transform=CGAffineTransformIdentity;
        [UIView animateWithDuration:0.5f animations:^{
            self.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
            
            //                     publicDetailView.videoView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            self.contentView.frame =  CGRectMake(0,0, screenWidth,screenHeight);
            //            publicDetailView.fullImageView.frame=CGRectMake(screenHeight-29, screenWidth-29, 29,  29);
            
            self.fullScreenButton.frame=CGRectMake(screenHeight-40,  screenWidth-40, 40,  40);
            [self.contentView addSubview:self.fullScreenButton];
            
            [[[UIApplication sharedApplication]keyWindow] addSubview:self.contentView];
        }];
    }else
    {
        //        [self.contentView removeFromSuperview];
        
        
        
        [UIView animateWithDuration:0.5f animations:^{
            self.contentView.transform = CGAffineTransformMakeRotation(0);
            
            
            
            self.contentView.frame =  CGRectMake(0, 0, screenWidth, 0.56*screenWidth);
            //                         publicDetailView.playerManager.videoView.frame= publicDetailView.videoView.frame;
            
            
            //           [self.mediaPlayer create:self.contentView];
            //                    _bakeBtn.frame = CGRectMake(10, 20, 30, 30);
            //            publicDetailView.fullImageView.frame=CGRectMake(screenWidth-29,  0.56*screenWidth-29, 29,  29);
            
            self.fullScreenButton.frame=CGRectMake(screenWidth-40,  0.56*screenWidth-40, 40,  40);
            //            [self.contentView addSubview:self.fullScreenButton];
        }];
    }
    
}
#pragma mark -viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //    [self InitNaviBar];
    self.view.backgroundColor=[UIColor whiteColor];
    self.contentView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 0.56*screenWidth)];
    self.contentView.backgroundColor=[UIColor redColor];
    [self.view addSubview:self.contentView];
    self.fullScreenButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenButton.frame=CGRectMake( CGRectGetMaxX(self.contentView.frame)-40, CGRectGetMaxY(self.contentView.frame)-40, 40, 40);
    self.fullScreenButton.backgroundColor=[UIColor redColor];
    [self.fullScreenButton addTarget:self action:@selector(fullScreenClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fullScreenButton];
    
    
    
    
    
    
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
    self.mediaPlayer.timeout = 10000;//毫秒
    //    /****************************************/
    //
    //
    //    //通知
    [self addPlayerObserver];
    self.startButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.startButton.frame=CGRectMake(0, CGRectGetMaxY(self.contentView.frame)+10, 100, 40);
    self.startButton.backgroundColor=[UIColor redColor];
    [self.startButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.tag=201;
    [self.view addSubview:self.startButton];
    
    self.stopButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.stopButton.frame=CGRectMake(CGRectGetMaxX(self.startButton.frame)+10, CGRectGetMaxY(self.contentView.frame)+10, 100, 40);
    self.stopButton.backgroundColor=[UIColor redColor];
    [self.stopButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.stopButton.tag=202;
    [self.view addSubview:self.stopButton];
    
    
    
    
    
    
    
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.volmeSlider.value = self.mediaPlayer.volume;
    self.brightSlider.value = self.mediaPlayer.brightness;
    
    self.showMessageView.hidden = YES;
    [self.view addSubview:self.showMessageView];
    // Do any additional setup after loading the view.
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.indicationrView.center = self.mediaPlayer.view.center;
    self.showMessageView.frame = self.view.bounds;
}


- (void)networkStateChange{
    if(!self.mediaPlayer) return;
    [self networkChangePop:YES];
}

-(BOOL) networkChangePop:(BOOL)isShow{
    BOOL ret = NO;
    switch ([self.reachability currentReachabilityStatus]) {
        case NotReachable:
        {
            ret = YES;
            [self stop];
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
            [self stop];
            ret = YES;
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
            if(self.mediaPlayer) {
                [self start];
            }
        }
            
            break;
            
        default:
            break;
    }
    
}

- (void)becomeActive{
    
    if ([self networkChangePop:NO]) {
        return;
    }
    if (self.isPause) {
        [self resume];
    }
}

- (void)resignActive{
    
    if ([self networkChangePop:NO]) {
        return;
    }
    
    if (self.mediaPlayer){
        if (self.mediaPlayer.isPlaying) {
            [self pause];
        }
        
    }
}
#pragma mark - add NSNotification
-(void)addPlayerObserver
{
    //add network notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
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
    
}

#pragma mark - receive
- (void)OnVideoPrepared:(NSNotification *)notification{
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
    
}
- (void)OnSeekDone:(NSNotification *)notification{
    [self.showMessageView addTextString:@"OnSeekDone"];
    
}
- (void)OnStartCache:(NSNotification *)notification{
    [self.showMessageView addTextString:@"OnStartCache"];
    
}
- (void)OnEndCache:(NSNotification *)notification{
    [self.showMessageView addTextString:@"OnEndCache"];
    
}

- (void)onVideoStop:(NSNotification *)notification{
    [self.showMessageView addTextString:@"OnVideoStop"];
    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 201://start
        {
            [self.indicationrView startAnimating];
            
            if ([self networkChangePop:YES]) {
                return;
            }
            
            [self start];
            
            
        }
            break;
        case 202://stop
        {
            [self stop];
        }
            break;
        default:
            break;
    }
}

- (void)start{
    
    AliVcMovieErrorCode err = [self.mediaPlayer prepareToPlay:[NSURL URLWithString:LIVE_URL]];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"play failed,error code is %d",(int)err);
        [self.indicationrView stopAnimating];
        [self.showMessageView addTextString:[NSString stringWithFormat:@"play failed,error code is %d",(int)err]];
        return;
    }
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    [self.mediaPlayer play];
    [self.contentView bringSubviewToFront:self.fullScreenButton];
    [self.showMessageView addTextString:NSLocalizedString(@"log_start_play", nil)];
    
}

- (void)pause{
    self.isPause = YES;
    AliVcMovieErrorCode err =[self.mediaPlayer pause];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"pause failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"pause failed,error code is %d",(int)err]];
        return;
    }
    [self.showMessageView addTextString:NSLocalizedString(@"log_pause_play", nil)];
    
    
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
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    
    [self.contentView bringSubviewToFront:self.fullScreenButton];
    
}


- (void)volumeChanged:(UISlider *)sender {
    self.mediaPlayer.volume = sender.value;
}
- (void)brightChanged:(UISlider *)sender {
    self.mediaPlayer.brightness = sender.value;
}
- (void)muteChanged:(UISwitch *)sender {
    self.mediaPlayer.muteMode = sender.isOn;
}
- (void)displayModeChanged:(UISegmentedControl *)sender {
    self.mediaPlayer.scalingMode = sender.selectedSegmentIndex;
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

