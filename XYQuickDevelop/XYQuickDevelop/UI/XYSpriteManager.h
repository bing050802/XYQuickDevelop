//
//  SpriteManager.h
//
//  Created by Heaven on 13-5-15.
//
//

#define XYSpriteManager_interval      1.0/12.0


#import "XYPrecompile.h"
#import "XYUI.h"
#import <UIKit/UIKit.h>

@interface XYSpriteManager : NSObject{
}

XY_SINGLETON(XYSpriteManager)

// 采用统一的定时器来刷新 sprite
@property (nonatomic, readonly) NSTimer                   *timer;
@property (nonatomic, assign)   NSTimeInterval            interval;       // 定时器间隔
@property (nonatomic, readonly)   NSMutableDictionary       *sprites;       // 精灵

-(void) startTimer;      // 开期定时器
-(void) stopTimer;


-(void) startAllSprites;
-(void) stopAllSprites;
-(void) clearAllSprites;    // 从画面上移除所有的精灵, 清空sprites.
@end
