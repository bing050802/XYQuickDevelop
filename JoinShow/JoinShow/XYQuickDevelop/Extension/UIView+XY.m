//
//  UIView+XY.m
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-31.
//
//

#import "UIView+XY.h"
#import <objc/runtime.h>

@implementation UIView (XY)

//const char oldDelegateKey;
const char completionHandlerKey;

-(void) addTapGestureWithTarget:(id)target action:(SEL)action{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
    [tap release];
}
-(void) removeTapGesture{
    /*
    NSArray *array = self.gestureRecognizers;
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    for (UIGestureRecognizer *ges in array) {
        if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
            [tmpArray addObject:ges];
        }
    }
    
    for (UIGestureRecognizer *ges in tmpArray) {
        [self removeGestureRecognizer:ges];
    }
    
    [tmpArray release];
    */
    
    for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[UITapGestureRecognizer class]] )
		{
			[self removeGestureRecognizer:gesture];
		}
	}
}

-(void) addTapGestureWithBlock:(void(^)(void))aBlock{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
    [self addGestureRecognizer:tap];
    [tap release];
    
    objc_setAssociatedObject(self, &completionHandlerKey, aBlock, OBJC_ASSOCIATION_COPY);
}
-(void)actionTap{
    void (^aBlock)(void) = objc_getAssociatedObject(self, &completionHandlerKey);
    
    if ( aBlock )
    {
        aBlock();
    }
}
@end
