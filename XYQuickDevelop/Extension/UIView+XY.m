//
//  UIView+XY.m
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-31.
//
//

#import "UIView+XY.h"
#import "XYExtension.h"
#import <objc/runtime.h>

@implementation UIView (XY)

#undef	UIView_key_tapBlock
#define UIView_key_tapBlock	"TapBlock"


-(void) UIView_dealloc{
    objc_removeAssociatedObjects(self);
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
    
    objc_setAssociatedObject(self, UIView_key_tapBlock, aBlock, OBJC_ASSOCIATION_COPY);
    [self replaceMethod_dealloc];
}
-(void)actionTap{
    void (^aBlock)(void) = objc_getAssociatedObject(self, UIView_key_tapBlock);
    
    if (aBlock) aBlock();
}
@end
