//
//  UIView+XY.h
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-31.
//
//

#import <UIKit/UIKit.h>
MAKE_CATEGORIES_LOADABLE(UIView_xy);
@interface UIView (XY)

-(void) addTapGestureWithTarget:(id)target action:(SEL)action;
-(void) addTapGestureWithBlock:(void(^)(void))aBlock;

-(void) removeTapGesture;

@end
