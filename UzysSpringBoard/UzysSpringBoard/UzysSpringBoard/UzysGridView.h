//
//  UzysGridView.h
//  UzysGridView
//
//  Created by 정 재훈 on 11. 11. 7..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysGridViewCell.h"


typedef struct _itemLocation {
    NSUInteger page;
    NSUInteger pindex;
} itemLocation;



@class UzysGridView;

#pragma - UzysGridViewDataSource
@protocol UzysGridViewDataSource<NSObject>
-(NSInteger) numberOfCellsInGridView:(UzysGridView *)gridview;
-(UzysGridViewCell *)gridView:(UzysGridView *)gridview cellAtIndex:(NSUInteger)index;

@optional                                                                                                   //edit mode
-(void) gridView:(UzysGridView *)gridview moveAtIndex:(NSUInteger)fromindex toIndex:(NSUInteger)toIndex;    //Cell Position Reorder
-(void) gridView:(UzysGridView *)gridview deleteAtIndex:(NSUInteger)index;                      
-(void) gridView:(UzysGridView *)gridview InsertAtIndex:(NSUInteger)index;
@end



#pragma -UzysGridViewDelegate
@protocol UzysGridViewDelegate<NSObject>
@optional
-(void) gridView:(UzysGridView *)gridView didSelectCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index;
//-(void) gridView:(UzysGridView *)gridView didDeselectCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index;
//-(void) gridView:(UzysGridView *)gridView didEndEditingCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index;
-(void) gridView:(UzysGridView *)gridView changedPageIndex:(NSUInteger)index;

@end


#pragma -UzysGridView
@interface UzysGridView : UIView <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSUInteger _currentPageIndex;
    NSUInteger _numberOfPages;
    NSMutableArray *_cellInfo;


//    NSMutableArray *_cellCollisionPosition;

}

@property (nonatomic, retain, readonly) UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet id<UzysGridViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<UzysGridViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) NSUInteger cellMargin;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic, readonly) NSUInteger numberOfPages;
@property (nonatomic,assign) BOOL editable;

- (void) reloadData;

- (void) createLayout:(BOOL)isVariable;
- (void) LoadTotalView ;
- (id)initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns;


- (void)cellWasSelected:(UzysGridViewCell *)cell;
- (void)cellWasDelete:(UzysGridViewCell *)cell;
- (void) DeleteCell:(NSInteger)index;

- (void) MovePage:(NSInteger)index;

-(NSInteger) CellCollisionDetection:(UzysGridViewCell *) cell;
-(void) CellSetPosition:(UzysGridViewCell *) cell;
@end
