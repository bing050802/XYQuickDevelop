//  Created by Heaven on 13-5-15.
//
//


#import "XYSpriteManager.h"
#import "XYSpriteView.h"


@implementation XYSpriteManager{
    
}

DEF_SINGLETON(XYSpriteManager);

-(id)init{
    self = [super init];
    if (self) {
        _sprites = [[NSMutableDictionary alloc] initWithCapacity:5];
        self.interval = 1.0/12.0;
    }
    return self;
}
-(void)dealloc{
    [_sprites release];
    [super dealloc];
}

-(void)startTimer{
    if (_timer == nil) {
        NSTimer *tmpTimer;
        NSDate *date = [NSDate date];
        tmpTimer = [[NSTimer alloc] initWithFireDate:date interval:_interval target:self selector:@selector(updateSprites) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:tmpTimer forMode:NSRunLoopCommonModes];
        _timer = tmpTimer;
        [tmpTimer release];
    }
}
-(void)stopTimer{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

-(void)clearAllSprites{
    [self.sprites enumerateKeysAndObjectsUsingBlock:^(id key, XYSpriteView *ani, BOOL *stop) {
        [ani removeFromSuperview];
    }];
    [self.sprites removeAllObjects];
}
-(void) startAllSprites{
    [self.sprites enumerateKeysAndObjectsUsingBlock:^(id key, XYSpriteView *ani, BOOL *stop) {
        [ani start];
    }];
}
-(void) stopAllSprites{
    [self.sprites enumerateKeysAndObjectsUsingBlock:^(id key, XYSpriteView *ani, BOOL *stop) {
        [ani stop];
    }];
}

- (void)updateSprites{
    if (self.sprites.count == 0) return;
    
    [self.sprites enumerateKeysAndObjectsUsingBlock:^(id key, XYSpriteView *ani, BOOL *stop) {
        [ani updateTimer:_interval];
       // [ani updateImage];
    }];
}

#pragma mark -
@end
