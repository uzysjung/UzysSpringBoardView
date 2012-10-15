//
//  UzysSpringBoardView.h
//  UzysSpringBoard
//
//  Created by 정 재훈 on 11. 11. 22..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef struct _itemLocation {
    NSInteger page;
    NSInteger pindex;
} itemLocation;

@class UzysSpringBoardView;
@class UzysSpringBoardItem;
#pragma -UzysGridViewDelegate
@protocol UzysSpringBoardViewDelegate<NSObject>


@optional
-(void) springBoard:(UzysSpringBoardView *)springBoard didSelectItem:(UzysSpringBoardItem *)item atIndex:(itemLocation) index;
-(void) springBoard:(UzysSpringBoardView *)springBoard changedPageIndex:(NSUInteger)index;
-(void) springBoard:(UzysSpringBoardView *)springBoard moveAtIndex:(itemLocation)fromindex toIndex:(itemLocation)toIndex;    
-(void) springBoard:(UzysSpringBoardView *)springBoard deleteItem:(UzysSpringBoardItem *) item atIndex:(itemLocation)index ; 

@end




@interface UzysSpringBoardView : UIView <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSMutableArray *_itemArray;

    NSUInteger _currentPageIndex;
    NSUInteger _numberOfPages;
    NSUInteger _numberOfRows;
    NSUInteger _numberOfColumns;
    
    NSTimer *_moveitemOutTmr;
    
}

@property (nonatomic, assign) IBOutlet id<UzysSpringBoardViewDelegate> delegate;
@property (nonatomic, retain, readonly) UIScrollView *scrollView;
@property (nonatomic,assign) BOOL editable;
@property (nonatomic, assign) NSUInteger itemMargin;
@property (nonatomic, readonly) NSUInteger numberOfRows;
@property (nonatomic, readonly) NSUInteger numberOfColumns;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, readonly) NSUInteger numberOfPages;


@property (nonatomic, assign) itemLocation DragitemStartPos;

- (id)initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns;
- (itemLocation) insertItem:(UzysSpringBoardItem *) item;
- (void)reloadData;


- (void)cellWasDelete:(UzysSpringBoardItem *)item;
- (void)cellWasSelected:(UzysSpringBoardItem *)item;

- (void)updateCurrentPageIndex;
- (void)layoutItems;
@end
