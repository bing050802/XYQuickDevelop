//
//  UIView+XY.m
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-31.
//
//

#import "UIView+XY.h"
#import "XYFunction.h"
#import <objc/runtime.h>

@implementation UIView (XY)

#undef	UIView_KEY_TapBlock
#define UIView_KEY_TapBlock	"TapBlock"


-(void) UIView_dealloc{
	// 移除所有关联对象。
    objc_removeAssociatedObjects(self);
    // 调用dealloc方法。
    XY_swizzleInstanceMethod([self class], @selector(UIView_dealloc), @selector(dealloc));
	[self dealloc];
}

/*
+ (void)initialize{
}
 */

-(void) replaceMethod_dealloc{
    XY_swizzleInstanceMethod([self class], @selector(dealloc), @selector(UIView_dealloc));
}

-(void) addTapGestureWithTarget:(id)target action:(SEL)action{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
    [tap release];
}
-(void) removeTapGesture{
    for (UIGestureRecognizer * gesture in self.gestureRecognizers)
	{
		if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
		{
			[self removeGestureRecognizer:gesture];
		}
	}
}

-(void) addTapGestureWithBlock:(void(^)(void))aBlock{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
    [self addGestureRecognizer:tap];
    [tap release];
    
    objc_setAssociatedObject(self, UIView_KEY_TapBlock, aBlock, OBJC_ASSOCIATION_COPY);
    [self replaceMethod_dealloc];
}
-(void)actionTap{
    void (^aBlock)(void) = objc_getAssociatedObject(self, UIView_KEY_TapBlock);
    
    if (aBlock) aBlock();
}
@end
