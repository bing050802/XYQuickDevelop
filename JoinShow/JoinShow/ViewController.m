//
//  ViewController.m
//  JoinShow
//
//  Created by Heaven on 13-6-26.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"
#import "Test2View.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    Test2View *tmpView = [[Test2View alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    tmpView.backgroundColor = [UIColor redColor];
    [tmpView addTapGestureWithBlock:^{
        NSLogD(@"%s", __FUNCTION__);
    }];

    _testView = tmpView;
    [self.view addSubview:tmpView];
    [tmpView release];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(200, 200, 100, 100);
    btn.backgroundColor = [UIColor yellowColor];
    [btn setTitle:@"remove" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 700, 60, 30);
    btn.backgroundColor = [UIColor yellowColor];
    [btn setTitle:@"replay" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnReplayClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UILabel *tmpLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 50)];
    tmpLab.backgroundColor = [UIColor lightGrayColor];
    tmpLab.text = @"test";
    labText = tmpLab;
    [self.view addSubview:tmpLab];
    [tmpLab release];
    
    /*

    */
    [_testView performSelector:@selector(changeLabText)
                        target:self mark:@"1"
                    afterDelay:^NSTimeInterval{
                        return 1;
                    }
                          loop:YES
                      isRunNow:NO];

    NSString *strTest = @"test1";
    strTest = @"test2";
    NSLog(@"%s, %@", __FUNCTION__, strTest);
    
    ////////////////////////////  XYSpriteView ////////////////////////////
    XYSpriteView *tmpSprite = [[XYSpriteView alloc] initWithFrame:CGRectMake(300, 0, 600, 768)];
    [tmpSprite formatImg:@"p3_b_%d.png" count:24 repeatCount:1];
    [tmpSprite showImgWithIndex:4];
    tmpSprite.delegate = self;
    [[XYSpriteManager sharedInstance].sprites setObject:tmpSprite forKey:@"a"];
    [self.view addSubview:tmpSprite];
    [tmpSprite release];
    
    [[XYSpriteManager sharedInstance] startTimer];
    [[XYSpriteManager sharedInstance] startAllSprites];
    
}

-(void)changeLabText{
    static int i = 0;
    i++;
    labText.text = [NSString stringWithFormat:@"%i", i];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnClick{
    [_testView removePerformRandomDelay];
    [_testView removeFromSuperview];
}
-(void)btnReplayClick{
    XYSpriteView *tmpSprite = [[XYSpriteManager sharedInstance].sprites objectForKey:@"a"];
    [tmpSprite reset];
    [tmpSprite start];
}
#pragma mark -XYSpriteDelegate
-(void) spriteOnIndex:(int)aIndex  sprite:(XYSpriteView *)aSprite{
}
@end
