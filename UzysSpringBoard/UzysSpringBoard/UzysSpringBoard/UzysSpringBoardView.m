//
//  UzysSpringBoardView.m
//  UzysSpringBoard
//
//  Created by 정 재훈 on 11. 11. 22..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//

#import "UzysSpringBoardView.h"
#import "UzysSpringBoardItem.h"

#define COLLISIONWIDTH 30
@interface UzysSpringBoardView (private)
- (void)beginEditing;
- (void)endEditing;
- (void)createLayout;

- (void)initVariable;
- (void)animateItems; 
- (void)stopAnimateItems;  
@end


@implementation UzysSpringBoardView
@synthesize editable;
@synthesize numberOfRows = _numberOfRows;
@synthesize numberOfColumns = _numberOfColumns;
@synthesize itemMargin;
@synthesize scrollView= _scrollView;
@synthesize currentPageIndex=_currentPageIndex;
@synthesize numberOfPages=_numberOfPages;
@synthesize delegate;
@synthesize DragitemStartPos;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initVariable];
        [self createLayout];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initVariable];
        _numberOfColumns = columns;
        _numberOfRows = rows;

        [self createLayout];
    }
    return self;
}

- (void)initVariable
{
    _itemArray = [[NSMutableArray alloc] init];
    _numberOfRows = 3;
    _numberOfColumns = 2;
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)dealloc {
    [_itemArray release];
    [super dealloc];
}
- (void)layoutSubviews 
{
    [super layoutSubviews];
    [self layoutItems];
}
- (void)reloadData
{
    [self setNeedsDisplay]; //called drawRect:(CGRect)rect
    [self setNeedsLayout];
}


- (void)createLayout
{

    
    self.itemMargin =20;
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

- (void)layoutItems
{


    if(self.numberOfPages>0 && self.numberOfRows > 0 && self.numberOfColumns >0)
    {
        NSUInteger numCols = self.numberOfColumns;
        NSUInteger numRows = self.numberOfRows;
//        NSUInteger cellsPerPage = numCols * numRows;

        BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation);
        if(isLandscape)
        {
            numCols = self.numberOfRows;
            numRows = self.numberOfColumns;
            
        }
        
        CGRect gridBounds = self.scrollView.bounds;
        CGRect cellBounds = CGRectMake(0, 0,(NSUInteger)( gridBounds.size.width / (float) numCols),(NSUInteger) ( gridBounds.size.height / (float) numRows ));
        
        CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
        
        [self.scrollView setContentSize:contentSize];
        
        
        
        for(UIView *v in self.scrollView.subviews) 
        {
            [v removeFromSuperview];
        }
        
        for(int page=0;page<[_itemArray count];page++)
        {
            NSArray *curPage = [_itemArray objectAtIndex:page];
           // NSLog(@"Page count:%d",page);
            for(int i=0 ;i <[curPage count];i++)
            {
                UzysSpringBoardItem *item = [curPage objectAtIndex:i];
                item.page =page;
                item.index =i;
                [item performSelector:@selector(setSpringBoard:) withObject:self];

                item.transform = CGAffineTransformIdentity;
                NSUInteger row = (NSUInteger)((float)i/numCols);
                
                CGPoint origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                             (row * cellBounds.size.height));
                
                CGRect contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
                item.frame = CGRectInset(contractFrame, (NSUInteger) self.itemMargin, (NSUInteger) self.itemMargin);
                
                if(self.editable == YES)
                {
                    [item setEdit:YES];
                }
                else 
                {
                    [item setEdit:NO];
                }
                [self.scrollView addSubview:item];
                
            }
       
        }
    }

   
        
}

-(void) CellRearrange:(UzysSpringBoardItem *) moveItem with:(itemLocation)targetLoc
{
    
    if(moveItem.index == targetLoc.pindex && moveItem.page == targetLoc.page)
        return;
    
    if (delegate && [delegate respondsToSelector:@selector(springBoard:moveAtIndex:toIndex:)]) {
        itemLocation loc;
        loc.page = moveItem.page;
        loc.pindex = moveItem.index;
        [self.delegate springBoard:self moveAtIndex:loc toIndex:targetLoc];
        
    }

    
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
    CGRect cellBounds = CGRectMake(0, 0,(NSUInteger)( gridBounds.size.width / (float) numCols),(NSUInteger) ( gridBounds.size.height / (float) numRows ));
    
    //Data Position Rearrange


    [[_itemArray objectAtIndex:moveItem.page]removeObjectAtIndex:moveItem.index];        
        
        
    if(targetLoc.pindex == -1 && targetLoc.page ==-1) // MOVING TARGET IS WANDERING ON PAGE
    {
        NSMutableArray *ppage = [_itemArray objectAtIndex:self.currentPageIndex];
        
        [ppage addObject:moveItem];
        targetLoc.page=self.currentPageIndex;
        targetLoc.pindex = [ppage indexOfObject:moveItem];
        
    }
    else
    {
        
        
        if(targetLoc.pindex == [[_itemArray objectAtIndex:targetLoc.page] count]+1)
        {
            [[_itemArray objectAtIndex:targetLoc.page] addObject:moveItem];
        }
        else
        {
            [[_itemArray objectAtIndex:targetLoc.page] insertObject:moveItem atIndex:targetLoc.pindex];
        }
        
    }

    
    //cell rearrange
    if([[_itemArray objectAtIndex:targetLoc.page] count] > cellsPerPage)
    {
        for(int page=targetLoc.page;page<[_itemArray count];page++)
        {
            NSMutableArray *curPage = [_itemArray objectAtIndex:page];
            if([curPage count]>cellsPerPage)
            {
                while([curPage count] != cellsPerPage)
                {
                    
                    UzysSpringBoardItem *tmp =[[curPage objectAtIndex:[curPage count]-1] retain];
                    [curPage removeLastObject];
                    if(page+1 == [_itemArray count])
                    {
                        [_itemArray addObject:[NSMutableArray array]];
                    }
                    [[_itemArray objectAtIndex:page+1] insertObject:tmp atIndex:0];
                    
                    
                }
            }
        }
    }
    
    
    for(int page=0;page<[_itemArray count];page++)
    {
        NSArray *curPage = [_itemArray objectAtIndex:page];
        //NSLog(@"Page count:%d",page);
        for(int i=0 ;i <[curPage count];i++)
        {
            UzysSpringBoardItem *item = [curPage objectAtIndex:i];
            
            [item performSelector:@selector(setSpringBoard:) withObject:self];
            
            item.page =page;
            item.index =i;
            NSUInteger row = (NSUInteger)((float)i/numCols);
            
            CGPoint origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                         (row * cellBounds.size.height));
            
            CGRect contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
            
            if(![moveItem isEqual:item])
            {
                item.transform = CGAffineTransformIdentity;
            [UIView beginAnimations:@"Move" context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
            item.frame = CGRectInset(contractFrame, (NSUInteger) self.itemMargin, (NSUInteger) self.itemMargin);
            }
            if(self.editable == YES)
            {
                [item setEdit:YES];
                
                
            }
            else 
            {
                [item setEdit:NO];
                
            }
            [self.scrollView addSubview:item];
            [UIView commitAnimations]; 
        }
    }
    
    
}

- (itemLocation) insertItem:(UzysSpringBoardItem *) item
{
    itemLocation ret;
    
    NSUInteger numCols = self.numberOfColumns;
    NSUInteger numRows = self.numberOfRows;
    NSUInteger cellsPerPage = numCols * numRows;
    
    NSUInteger numOfPages =[_itemArray count];
    
    if(numOfPages == 0 ) //nothing in itemarray 
    {
        NSMutableArray *page = [[NSMutableArray alloc] init];
        [page addObject:item];
        
        [_itemArray addObject:page];
        

        [page release];

    }
    else
    {
        NSMutableArray *lastPage = [_itemArray lastObject];
        
        if([lastPage count] >= cellsPerPage)
        {
            NSMutableArray *newPage = [[NSMutableArray alloc] init];
            [newPage addObject:item];
            [_itemArray addObject:newPage];
            [newPage release];
            
        }
        else
        {
            [lastPage addObject:item];
        }

        
    }
    ret.page = [_itemArray count] -1;
    ret.pindex = [[_itemArray lastObject] count] -1;
    item.page =ret.page;
    item.index =ret.pindex;
    
//    UzysSpringBoardItem *tmp =[[_itemArray objectAtIndex:ret.page] objectAtIndex:ret.pindex];
    
//    NSLog(@"Insert Page : %d Index : %d",tmp.page,tmp.index);
    NSLog(@"itemArray count: %d",[_itemArray count]);
    
    
    
    return  ret;
}

-(void)moveitemOutTimer:(NSTimer *)timer
{
    _moveitemOutTmr = nil;
    
    UzysSpringBoardItem *item = (UzysSpringBoardItem *) timer.userInfo;
    
    itemLocation loc;
    loc.page=-1;
    loc.pindex = -1;
    [self CellRearrange:item with:loc];
    
}

-(void) CellCollisionDetection:(UzysSpringBoardItem *) item
{
    NSUInteger CollWidth=(NSUInteger)((item.bounds.size.width+item.bounds.size.height)/4) *0.6;
    NSMutableArray *collisionitem = [[NSMutableArray alloc] init];
    UzysSpringBoardItem *coll;
    itemLocation retInd;
    retInd.page = -1;
    retInd.pindex = -1;

    for(int page=0;page<[_itemArray count];page++)
    {
        NSMutableArray *curpage=[_itemArray objectAtIndex:page];
        for(int i=0;i<[curpage count];i++)
        {
            
            coll= [curpage objectAtIndex:i];
            if(![item isEqual:coll])
            {
//                if(CGRectIntersectsRect(coll.frame, item.frame))
//                {
                    CGFloat xDist = (coll.center.x - item.center.x); 
                    CGFloat yDist = (coll.center.y - item.center.y); 
                    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist)); 
                    
                    
                
                    if(distance < CollWidth)
                        [collisionitem addObject:coll];
//                }
                
            }

            
            
            
            
        }
        
    }
    
    
    if([collisionitem count]==1)
    {
        
        [_moveitemOutTmr invalidate];
        _moveitemOutTmr = nil;
        
        coll = [collisionitem objectAtIndex:0];
        
        if(coll.center.x < item.center.x)
        {
            retInd.page = coll.page;
            retInd.pindex = coll.index +1;
           // NSLog(@"Collide index:%d right",retInd);
        }
        else
        {
            retInd.page = coll.page;
            retInd.pindex = coll.index;
            //NSLog(@"Collide index:%d left",retInd);
            
        }
        
        [self CellRearrange:item with:retInd];
        
    }
    else
    {
      //  _moveitemOutTmr = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(moveitemOutTimer:) userInfo:item repeats:NO];

        UzysSpringBoardItem *cmp = [[_itemArray objectAtIndex:self.currentPageIndex] lastObject];
        if(![item isEqual:cmp])
        {
            NSUInteger numCols = self.numberOfColumns;
            NSUInteger numRows = self.numberOfRows;

            
            int i= item.index;
            int page = item.page;
            BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
            if(isLandscape)
            {
                numCols = self.numberOfRows;
                numRows = self.numberOfColumns;
                
            }
            
            CGRect gridBounds = self.scrollView.bounds;
            CGRect cellBounds = CGRectMake(0, 0,(NSUInteger)( gridBounds.size.width / (float) numCols),(NSUInteger) ( gridBounds.size.height / (float) numRows ));
            
            
            NSUInteger row = (NSUInteger)((float)i/numCols);
            
            CGPoint origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                         (row * cellBounds.size.height));
            
            CGRect contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
            CGRect prevPosition = CGRectInset(contractFrame, (NSUInteger) self.itemMargin, (NSUInteger) self.itemMargin);
            
            if(!CGRectIntersectsRect(prevPosition,item.frame))
            {
            itemLocation loc;
            loc.page=-1;
            loc.pindex = -1;
            [self CellRearrange:item with:loc];
            }
        }
    }


    
    

    
    

}


#pragma - UzysSpringBoardItem callback
- (void)cellWasDelete:(UzysSpringBoardItem *)item
{

    NSLog(@"cellWasDelete item page:%d,index:%d",item.page,item.index);
        
    NSMutableArray *curPage =[_itemArray objectAtIndex:item.page];
    [curPage removeObject:item];
    if([curPage count] == 0)
    {
        [_itemArray removeObject:curPage];
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];    
    [self layoutItems];
    [UIView commitAnimations];

    if (delegate && [delegate respondsToSelector:@selector(springBoard:deleteItem:atIndex:atIndex:)]) {
        itemLocation loc;
        loc.page = item.page;
        loc.pindex = item.index;
        [self.delegate springBoard:self deleteItem:item atIndex:loc];
        
    }
    

}

- (void)cellWasSelected:(UzysSpringBoardItem *)item
{
    //do something
    if (delegate && [delegate respondsToSelector:@selector(springBoard:didSelectItem:atIndex:)]) {
        itemLocation loc;
        loc.page = item.page;
        loc.pindex = item.index;
        [self.delegate springBoard:self didSelectItem:item atIndex:loc];
        
    }
    
}

#pragma - Edit Mode
- (void)beginEditing
{

	
    [_itemArray addObject:[NSMutableArray array]];
    
    CGRect gridBounds = self.scrollView.bounds;
    CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
    NSLog(@"numofPage : %d",self.numberOfPages);
    [self.scrollView setContentSize:contentSize];
    
    for(UIView *v in self.scrollView.subviews) 
    {
        if([v isKindOfClass:[UzysSpringBoardItem class]])
        {
            UzysSpringBoardItem *temp=(UzysSpringBoardItem *)v;
            [temp setEdit:YES];
            
        }
    }
    [self animateItems];


    
}
- (void)endEditing
{
    //editable = NO;
    for(int page=0;page<[_itemArray count];page++)
    {
        NSMutableArray *curPage = [_itemArray objectAtIndex:page];
        
        if([curPage count] == 0)
        {
            [_itemArray removeObject:curPage];
        }
        else
        {
            for(UzysSpringBoardItem *item in curPage)
            {
                item.transform = CGAffineTransformIdentity;
                
            }
        }
    }
    
    CGRect gridBounds = self.scrollView.bounds;
    CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
    [self.scrollView setContentSize:contentSize];
    
    for(UIView *v in self.scrollView.subviews) 
    {
        if([v isKindOfClass:[UzysSpringBoardItem class]])
        {
            UzysSpringBoardItem *temp=(UzysSpringBoardItem *)v;
            [temp setEdit:NO];
            //                [temp.ButtonDelete setHidden:YES];               
        }
    }
    
    
}

- (void)setEditable:(BOOL)value
{
    editable = value;
    if(editable)
    {
        [self beginEditing];
 
    }
    
    else
    {
        [self endEditing];
    }
    
    
    //  [self reloadData];
    
}


-(void)animateItems 
{
	static BOOL animatesLeft = NO;
	
	if (editable) 
	{

        CGAffineTransform animateUp = CGAffineTransformMakeRotation(1*M_PI/180);
		CGAffineTransform animateDown = CGAffineTransformMakeRotation(-1*M_PI/180);
		
		[UIView beginAnimations:nil context:nil];
		
		NSInteger i = 0;
		NSInteger animatingItems = 0;
		for (NSArray* itemPage in _itemArray) 
		{
			for (UzysSpringBoardItem* item in itemPage) 
			{
//				item.closeButton.hidden = !editing;
				if (item.dragging != YES) 
				{
                    
					++animatingItems;

                    if (i % 2) 
						item.transform = animatesLeft ? animateDown : animateUp;
					else 
						item.transform = animatesLeft ? animateUp : animateDown;
				}
				++i;
			}
		}
		
		if (animatingItems >= 1) 
		{
			[UIView setAnimationDuration:0.02];
			[UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animateItems)];
			animatesLeft = !animatesLeft;
            //[NSObject cancelPreviousPerformRequestsWithTarget:self];
			//[self performSelector:@selector(animateItems) withObject:nil afterDelay:0.2];
            
		} 
		else 
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			[self performSelector:@selector(animateItems) withObject:nil afterDelay:0.05];
		}
		
		[UIView commitAnimations];
	}
}


#pragma - Property Override
- (NSUInteger)numberOfPages
{
    
    
    return [_itemArray count];
    
}

- (void) setCurrentPageIndex:(NSUInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    CGPoint move = CGPointMake(self.scrollView.frame.size.width * currentPageIndex, 0);
    [self.scrollView setContentOffset:move animated:YES];
}


#pragma - Page Control

- (void)updateCurrentPageIndex
{
    NSUInteger curPage = round(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    static NSUInteger prevPage =0;
   // NSLog(@"CurPage %d",curPage);
    if(curPage != prevPage)
    {
        _currentPageIndex =curPage;

        if (delegate && [delegate respondsToSelector:@selector(springBoard:changedPageIndex:)]) {
            
            [self.delegate springBoard:self changedPageIndex:curPage];

        }
    }
    
    prevPage = curPage;
    
}


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

@end
