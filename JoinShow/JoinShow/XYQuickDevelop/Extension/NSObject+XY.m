//
//  NSObject+XY.m
//  JoinShow
//
//  Created by Heaven on 13-7-31.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#import "NSObject+XY.h"
#import "XYExtension.h"

#undef	NSObject_key_performSelector
#define NSObject_key_performSelector	"PerformSelector"
#undef	NSObject_key_performTarget
#define NSObject_key_performTarget	"PerformTarget"
#undef	NSObject_key_performBlock
#define NSObject_key_performBlock	"PerformBlock"
#undef	NSObject_key_loop
#define NSObject_key_loop	"Loop"
#undef	NSObject_key_afterDelay
#define NSObject_key_afterDelay	"AfterDelay"
#undef	NSObject_key_object
#define NSObject_key_object	"Object"


@implementation NSObject (XY)
/*
-(void) NSObject_dealloc{
    objc_removeAssociatedObjects(self);
    XY_swizzleInstanceMethod([self class], @selector(NSObject_dealloc), @selector(dealloc));
	[self dealloc];
}

-(void) replaceMethod_dealloc{
    XY_swizzleInstanceMethod([self class], @selector(dealloc), @selector(NSObject_dealloc));
}
*/
-(void) performSelector:(SEL)aSelector  target:(id)target  mark:(id)mark afterDelay:(NSTimeInterval(^)(void))aBlockTime loop:(BOOL)loop isRunNow:(BOOL)now{
    if (!aBlockTime) return;
    
    NSTimeInterval t;
    if (now) {
        t = 0;
    }else{
        t = aBlockTime();
    }
    
    objc_setAssociatedObject(self, NSObject_key_performBlock, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performTarget, target, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performSelector, (id)aSelector, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_afterDelay, aBlockTime, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, NSObject_key_loop, (id)loop, OBJC_ASSOCIATION_ASSIGN);
    
    [self performSelector:@selector(randomRerform:) withObject:mark afterDelay:t];
}
-(void) performBlock:(void(^)(void))aBlock mark:(id)mark afterDelay:(NSTimeInterval(^)(void))aBlockTime loop:(BOOL)loop isRunNow:(BOOL)now{
    if (!aBlockTime) return;
    
    NSTimeInterval t;
    if (aBlockTime) {
        t = aBlockTime();
    }
    if (now) {
        t = 0;
    }

    objc_setAssociatedObject(self, NSObject_key_performBlock, aBlock, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, NSObject_key_performSelector, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performTarget, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_afterDelay, aBlockTime, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, NSObject_key_loop, (id)loop, OBJC_ASSOCIATION_ASSIGN);
    
    [self performSelector:@selector(randomRerform:) withObject:mark afterDelay:t];
}
-(void) randomRerform:(id)anArgument{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomRerform:) object:nil];
    
    void (^aBlock)(void) = objc_getAssociatedObject(self, NSObject_key_performBlock);
    if (aBlock) {
        aBlock();
    }
    
    SEL sel =   (SEL)objc_getAssociatedObject(self, NSObject_key_performSelector);
    if (sel) {
        id target = objc_getAssociatedObject(self, NSObject_key_performTarget);
        [target performSelector:sel withObject:anArgument];
    }
    
    
     NSTimeInterval (^aBlockTime)(void) = objc_getAssociatedObject(self, NSObject_key_afterDelay);
    NSTimeInterval t;
    if (aBlockTime) {
        t = aBlockTime();
    }
    
    BOOL b = (BOOL)objc_getAssociatedObject(self, NSObject_key_loop);
    if (b) {
        [self performSelector:@selector(randomRerform:) withObject:anArgument afterDelay:t];
    }
}
-(void) removePerformRandomDelay{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomRerform:) object:nil];
    
    objc_setAssociatedObject(self, NSObject_key_performBlock, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performSelector, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performTarget, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_afterDelay, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_object, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_loop, nil, OBJC_ASSOCIATION_ASSIGN);
}
@end
