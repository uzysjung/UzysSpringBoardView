//
//  UzysGridViewCell.h
//  UzysGridView
//
//  Created by 정 재훈 on 11. 11. 7..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UzysGridView;


@interface UzysGridViewCell : UIView<UIGestureRecognizerDelegate>
{
    NSInteger _index;                                   //Cell index
    CGPoint _touchLocation;                             //Last location
    NSTimer *_movePagesTimer;                           //GridView Page move Timer  
}

@property (nonatomic, assign) NSInteger page; 
@property (nonatomic, assign) NSInteger pageindex; 
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) UzysGridView *gridView;
@property (nonatomic, assign) BOOL deletable;           // deletable flag
@property (nonatomic,retain) UIButton *ButtonDelete;    


- (void)BtnActionDelete;                                //Cell Delete Action Handler
- (void)moveByOffset:(CGPoint)offset;                   //Cell Moving by offset
- (void)SetPosition:(CGPoint) point;                    //Cell moving absolute position
- (void)movePagesTimer:(NSTimer*)timer;                 //Page Move Timer
- (void)setEdit:(BOOL)edit;                             // Entering Edit mode
@end
