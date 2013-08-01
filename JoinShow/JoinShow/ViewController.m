//
//  ViewController.m
//  JoinShow
//
//  Created by Heaven on 13-6-26.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#import "ViewController.h"
#import "XYCommon.h"
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
    
    [_testView performBlock:^{
        static int i = 0;
        i = i + 2;
        labText.text = [NSString stringWithFormat:@"%i", i];
        
    }
                       mark:@"1"
                 afterDelay:^NSTimeInterval{
                     return 1;
                 }
                       loop:YES
                   isRunNow:NO];
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
@end
