//
//  ViewController.h
//  UzysSpringBoard
//
//  Created by Uzys on 11. 11. 22..
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
