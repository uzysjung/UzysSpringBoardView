//
//  UzysGridView.m
//  UzysGridView
//
//  Created by 정 재훈 on 11. 11. 7..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//
#define COLLISIONWIDTH 100 //distance between moving cell and collision cell
#import "UzysSpringBoardView.h"

@interface UzysGridView (private)
-(void) InitVariable;
-(void) CellRearrange:(NSInteger) moveIndex with:(NSInteger)targetIndex;
@end

@implementation UzysGridView (private)

-(void) InitVariable 
{
    _cellInfo = [[NSMutableArray alloc] init ];
    
}


-(void) CellRearrange:(NSInteger) moveIndex with:(NSInteger)targetIndex
{

    if(moveIndex==targetIndex || targetIndex ==-1)
        return;
    

    NSUInteger numCols = self.numberOfColumns;
    NSUInteger numRows = self.numberOfRows;
    NSUInteger cellsPerPage = numCols * numRows;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if(isLandscape)
    {
        numCols = self.numberOfRows;
        numRows = self.numberOfColumns;
        
    }
    
    CGRect gridBounds = self.scrollView.bounds;
    CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
    
   //Data Position Rearrange
    UzysGridViewCell *movingcell = [_cellInfo objectAtIndex:moveIndex];
    [_cellInfo removeObjectAtIndex:moveIndex];
    if(targetIndex == [_cellInfo count]+1)
    {
        [_cellInfo addObject:movingcell];
    }
    else
    {
        [_cellInfo insertObject:movingcell atIndex:targetIndex];
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(gridView:moveAtIndex:toIndex:)])
    {
        [self.dataSource gridView:self moveAtIndex:moveIndex toIndex:targetIndex];        
    }
    
    //Cell Rearrange
    for(NSUInteger i=0;i<[_cellInfo count];i++)
    {
        
        UzysGridViewCell *cell = [_cellInfo objectAtIndex:i];
        
        NSUInteger setIndex = i;
        [cell performSelector:@selector(setCellIndex:) withObject:[NSNumber numberWithInt:setIndex]];
        if(movingcell != cell)
        {
            NSUInteger page = (NSUInteger)((float)(setIndex)/ cellsPerPage);
            NSUInteger row = (NSUInteger)((float)(setIndex)/numCols) - (page * numRows);
            
            CGPoint origin = CGPointMake((page * gridBounds.size.width) + (((setIndex) % numCols) * cellBounds.size.width), 
                                         (row * cellBounds.size.height));
            
            CGRect contractFrame = CGRectMake(origin.x, origin.y, cellBounds.size.width, cellBounds.size.height);
            [UIView beginAnimations:@"Move" context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
            cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
            [UIView commitAnimations];  
        }
    }
    
    
        

}



@end
@implementation UzysGridView

@synthesize editable;

@synthesize dataSource;
@synthesize delegate;
@synthesize numberOfRows;
@synthesize numberOfColumns;
@synthesize cellMargin;

//Readonly
@synthesize scrollView= _scrollView;
@synthesize currentPageIndex=_currentPageIndex;
@synthesize numberOfPages=_numberOfPages;

-(void) CellSetPosition:(UzysGridViewCell *) cell
{
    NSUInteger numCols = self.numberOfColumns;
    NSUInteger numRows = self.numberOfRows;
    NSUInteger cellsPerPage = numCols * numRows;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if(isLandscape)
    {
        numCols = self.numberOfRows;
        numRows = self.numberOfColumns;
        
    }
    
    CGRect gridBounds = self.scrollView.bounds;
    CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
    

    NSUInteger setIndex = cell.index;
    NSUInteger page = (NSUInteger)((float)(setIndex)/ cellsPerPage);
    NSUInteger row = (NSUInteger)((float)(setIndex)/numCols) - (page * numRows);
    
    CGPoint origin = CGPointMake((page * gridBounds.size.width) + (((setIndex) % numCols) * cellBounds.size.width), 
                                 (row * cellBounds.size.height));
    
    CGRect contractFrame = CGRectMake(origin.x, origin.y, cellBounds.size.width, cellBounds.size.height);
    [UIView beginAnimations:@"Move" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
    [UIView commitAnimations];  

    
    
    
}
-(NSInteger) CellCollisionDetection:(UzysGridViewCell *) cell
{
    
    NSMutableArray *collisionCells = [[NSMutableArray alloc] init];
    UzysGridViewCell *coll;
    NSInteger retInd =-1;
    for(int i=0;i<[_cellInfo count];i++)
    {
        coll=[_cellInfo objectAtIndex:i];
        
        if(![cell isEqual:coll])
        {
            if(CGRectIntersectsRect(coll.frame, cell.frame))  //collision detection
            {
                CGFloat xDist = (coll.center.x - cell.center.x); //[2]
                CGFloat yDist = (coll.center.y - cell.center.y); //[3]
                CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist)); //[4]
                
                //                if(distance < cell.frame.size.width/2)
                //                    [collisionCells addObject:coll];
                if(distance < COLLISIONWIDTH)
                    [collisionCells addObject:coll];
            }
        }
    }
    
    if([collisionCells count]==1)
    {
        
        
        coll = [collisionCells objectAtIndex:0];
        
        if(coll.center.x < cell.center.x)
        {
            retInd = coll.index +1;
            NSLog(@"Collide index:%d right",retInd);
        }
        else
        {
            retInd = coll.index;
            NSLog(@"Collide index:%d left",retInd);
            
        }
        
        
        
    }


    
    
    [self CellRearrange:cell.index with:retInd];
    return retInd;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createLayout:NO];        
        [self InitVariable];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.numberOfRows = rows;
        self.numberOfColumns= columns;
        
        [self createLayout:YES];
        [self InitVariable];
        
    }
    return self;
}

- (void)dealloc {
    [_scrollView release];
    [_cellInfo release];

    [super dealloc];
}


// ----------------------------------------------------------------------------------
#pragma - Layout/Draw

- (void) createLayout:(BOOL)isVariable
{
    if(isVariable ==NO)
    {
        self.numberOfRows = 3;
        self.numberOfColumns = 2;
        
    }
    self.cellMargin =40;
    _currentPageIndex = 0;
    
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    
    _scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delaysContentTouches =YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.multipleTouchEnabled = NO;
    [self addSubview:_scrollView];
    
  //  [self reloadData];


    
}
- (void)layoutSubviews 
{
    [self LoadTotalView];

    NSLog(@"Call GridView LayoutSubview");
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

}

- (void)reloadData
{
    [self setNeedsDisplay]; //called drawRect:(CGRect)rect
    [self setNeedsLayout];
}

- (void) LoadTotalView {
    
    if(self.dataSource && self.numberOfRows > 0 && self.numberOfColumns >0)
    {
        NSUInteger numCols = self.numberOfColumns;
        NSUInteger numRows = self.numberOfRows;
        NSUInteger cellsPerPage = numCols * numRows;
        [_cellInfo removeAllObjects];
        
        BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
        if(isLandscape)
        {
            numCols = self.numberOfRows;
            numRows = self.numberOfColumns;
            
        }
        
        CGRect gridBounds = self.scrollView.bounds;
        CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
        
        CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
        
        [self.scrollView setContentSize:contentSize];
        
        
        for(UIView *v in self.scrollView.subviews) 
        {
            [v removeFromSuperview];
        }
        
        for(NSUInteger i = 0 ; i< [self.dataSource numberOfCellsInGridView:self];i++)
        {
            UzysGridViewCell *cell = [self.dataSource gridView:self cellAtIndex:i];
            [cell performSelector:@selector(setGridView:) withObject:self];
            [cell performSelector:@selector(setCellIndex:) withObject:[NSNumber numberWithInt:i]];
            
            
            NSUInteger page = (NSUInteger)((float)i/ cellsPerPage);
            NSUInteger row = (NSUInteger)((float)i/numCols) - (page * numRows);
            
            /////////////////
            cell.page = page;
            cell.pageindex = (NSUInteger)(i % cellsPerPage);
            /////////////////
            
            CGPoint origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                         (row * cellBounds.size.height));
            
            CGRect contractFrame = CGRectMake(origin.x, origin.y, cellBounds.size.width, cellBounds.size.height);
            cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
            
            if(self.editable == YES)
            {
                [cell.ButtonDelete setHidden:NO];
                
            }
            else 
            {
                [cell.ButtonDelete setHidden:YES];
            }
            [self.scrollView addSubview:cell];
            
            [_cellInfo addObject:cell];
        }
        
        
    }
    
}

// ----------------------------------------------------------------------------------
#pragma - Cell/Page Control

- (void) DeleteCell:(NSInteger)index {
    
    [[_cellInfo objectAtIndex:index] removeFromSuperview];
    [_cellInfo removeObjectAtIndex:index];
    
    NSUInteger numCols = self.numberOfColumns;
    NSUInteger numRows = self.numberOfRows;
    NSUInteger cellsPerPage = numCols * numRows;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if(isLandscape)
    {
        numCols = self.numberOfRows;
        numRows = self.numberOfColumns;
        
    }
    
    CGRect gridBounds = self.scrollView.bounds;
    CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
    
    
    
    UzysGridViewCell *tmpcell = [_cellInfo objectAtIndex:index];
    NSUInteger curPage = tmpcell.page;
    //NSUInteger curPageIndex = tmpcell.pageindex;
    for(NSUInteger i=index;i<[_cellInfo count];i++)
    {
        UzysGridViewCell *cell = [_cellInfo objectAtIndex:i];
        [cell performSelector:@selector(setCellIndex:) withObject:[NSNumber numberWithInt:i]];
    
        
        if(cell.page == curPage)
        {
            cell.pageindex = cell.pageindex--;
            NSUInteger page = (NSUInteger)((float)i/ cellsPerPage);
            NSUInteger row = (NSUInteger)((float)i/numCols) - (page * numRows);
            CGPoint origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                         (row * cellBounds.size.height));
            
            CGRect contractFrame = CGRectMake(origin.x, origin.y, cellBounds.size.width, cellBounds.size.height);
            [UIView beginAnimations:@"Move" context:nil];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
            cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
            [UIView commitAnimations];  
        }
    }
    
}


- (void)updateCurrentPageIndex
{
//    CGFloat pageWidth = _scrollView.frame.size.width;
//    NSUInteger cpi = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    _currentPageIndex = cpi;
//    
//    if (delegate && [delegate respondsToSelector:@selector(gridView:changedPageToIndex:)]) {
//        [self.delegate gridView:self changedPageIndex:_currentPageIndex];
//    }
    NSUInteger curPage = round(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    static NSUInteger prevPage =0;
   // NSLog(@"CurPage %d",curPage);
    if(curPage != prevPage)
    {
        if (delegate && [delegate respondsToSelector:@selector(gridView:changedPageToIndex:)]) {
            _currentPageIndex =curPage;
            [self.delegate gridView:self changedPageIndex:curPage];
        }
    }
    
    prevPage = curPage;
    
}
- (void) MovePage:(NSInteger)index 
{
    CGPoint move = CGPointMake(self.scrollView.frame.size.width * index, 0);
    [self.scrollView setContentOffset:move animated:YES];
    _currentPageIndex = index;
}


// ----------------------------------------------------------------------------------
#pragma - UzysGridView callback
- (void)cellWasSelected:(UzysGridViewCell *)cell
{
    if (delegate && [delegate respondsToSelector:@selector(gridView:didSelectCell:atIndex:)]) {
        [delegate gridView:self didSelectCell:cell atIndex:cell.index];
    }
}
- (void)cellWasDelete:(UzysGridViewCell *)cell
{
    if (dataSource && [dataSource respondsToSelector:@selector(gridView:deleteAtIndex:)])
    {
        [dataSource gridView:self deleteAtIndex:cell.index];
        [self DeleteCell:cell.index];
    }
}
// ----------------------------------------------------------------------------------

#pragma - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
    
}

// ----------------------------------------------------------------------------------
#pragma - Property Override


- (void)setDataSource:(id<UzysGridViewDataSource>)uDataSource  //override
{
    dataSource = uDataSource;
    [self reloadData];
}


- (void)setNumberOfColumns:(NSUInteger)value
{
    numberOfColumns = value;
    [self reloadData];
}


- (void)setNumberOfRows:(NSUInteger)value
{
    numberOfRows = value;
    [self reloadData];
}


- (void)setCellMargin:(NSUInteger)value
{
    cellMargin = value;
    [self reloadData];
}

- (void)setEditable:(BOOL)value
{
    editable = value;
    if(editable)
    {
        for(UIView *v in self.scrollView.subviews) 
        {
            if([v isKindOfClass:[UzysGridViewCell class]])
            {
                UzysGridViewCell *temp=(UzysGridViewCell *)v;
                [temp setEdit:YES];
//                [temp.ButtonDelete setHidden:NO];
                
            }
        }
        
        
    }
    
    else
    {
        for(UIView *v in self.scrollView.subviews) 
        {
            if([v isKindOfClass:[UzysGridViewCell class]])
            {
                UzysGridViewCell *temp=(UzysGridViewCell *)v;
                [temp setEdit:NO];
//                [temp.ButtonDelete setHidden:YES];               
            }
        }
        
       
        
    }
    
    
    //  [self reloadData];
    
}


- (NSUInteger)numberOfPages
{
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInGridView:self];
    NSUInteger cellsPerPage = self.numberOfColumns * self.numberOfRows;
    return (NSUInteger)(ceil((float)numberOfCells / (float)cellsPerPage));
}

@end
