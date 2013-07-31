//
//  UIView+XY.h
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-31.
//
//

#import <UIKit/UIKit.h>

@interface UIView (XY)

-(void) addTapGestureWithTarget:(id)target action:(SEL)action;
-(void) removeTapGesture;
#pragma mark - todo
-(void) addTapGestureWithBlock:(void(^)(void))aBlock;

@end
