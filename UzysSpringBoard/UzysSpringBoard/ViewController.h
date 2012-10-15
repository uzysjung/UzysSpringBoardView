//
//  ViewController.h
//  UzysSpringBoard
//
//  Created by 정 재훈 on 11. 11. 22..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysSpringBoardView.h"
#import "UzysSpringBoardItem.h"
@interface ViewController : UIViewController <UzysSpringBoardViewDelegate>
{
    UzysSpringBoardView *gridView;
    NSMutableArray *test_arr;
}
- (void) ButtonTapp;
@end
