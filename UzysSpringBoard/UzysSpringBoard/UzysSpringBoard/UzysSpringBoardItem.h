//
//  UzysSpringBoardItem.h
//  UzysSpringBoard
//
//  Created by Uzys on 11. 11. 22..
//


#import <UIKit/UIKit.h>
@class UzysSpringBoardView;


@interface UzysSpringBoardItem : UIControl
{
    CGPoint _touchLocation;                             //Last location
    NSTimer *_movePagesTimer;                           //GridView Page move Timer  
}

@property (nonatomic,retain) UIButton *ButtonDelete;    
@property (nonatomic,retain) UzysSpringBoardView *SpringBoard;
@property (nonatomic,assign) BOOL deletable;
@property (nonatomic,assign) BOOL dragging;

@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIView *textLabelBackgroundView;
@property (nonatomic, retain) UIView *backgroundView;


@property (nonatomic,assign) NSUInteger page;
@property (nonatomic,assign) NSUInteger index;
//@property (nonatomic,assign) itemLocation itemLoc;

- (void)setEdit:(BOOL)edit;                             // Entering Edit mode

@end
