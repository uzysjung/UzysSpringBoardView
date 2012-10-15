//
//  UzysGridViewCell.m
//  UzysGridView
//
//  Created by 정 재훈 on 11. 11. 7..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//

#import "UzysGridViewCell.h"
#import "UzysSpringBoardView.h"
@implementation UzysGridViewCell

@synthesize index=_index;
@synthesize gridView;
@synthesize ButtonDelete;
@synthesize page,pageindex;
@synthesize deletable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         // Initialization code       
        deletable = YES;
        

        ButtonDelete = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [ButtonDelete addTarget:self action:@selector(BtnActionDelete) forControlEvents:UIControlEventTouchUpInside];
        [ButtonDelete setImage:[UIImage imageNamed:@"icon_del.png"] forState:UIControlStateNormal];
        [ButtonDelete setImage:[UIImage imageNamed:@"icon_del_h.png"] forState:UIControlStateHighlighted];
        
        [self addSubview:ButtonDelete];
        
        UILongPressGestureRecognizer *_gestureLong = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _gestureLong.minimumPressDuration =2.0;
        
        [self addGestureRecognizer:_gestureLong];
        
        [_gestureLong release];
        
        

    }
    return self;
}

- (void)dealloc {
    [ButtonDelete release];
    [super dealloc];
}

-(void) handleLongPress:(UILongPressGestureRecognizer *)recognizer  {
    self.gridView.editable =YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"Call Cell layoutSubview");
    
    CGSize imgsize = [UIImage imageNamed:@"icon_del.png"].size;
    CGRect CellBound = self.bounds;
    [ButtonDelete setFrame:CGRectMake(CellBound.size.width - imgsize.width , 0, imgsize.width, imgsize.height)];
    
    
}

- (void)setCellIndex:(NSNumber *)theIndex
{
    _index = [theIndex intValue];
}
- (void)setCellPage:(NSNumber *)thePage
{
    page = [thePage intValue];
}


#pragma Touch Event Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

       
    _touchLocation = [[touches anyObject] locationInView:self.gridView.scrollView];
   
    if(gridView.editable)
    {
        gridView.scrollView.scrollEnabled = NO;
        //Bring Subview to Front
        [gridView.scrollView bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseIn 
                         animations:^{
            
                                 self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                 self.alpha = 0.7;
           
                  
                         }
                         completion:nil];
        

    }
    
	[super touchesBegan:touches withEvent:event];

    NSLog(@"TB");
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
    
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self.gridView.scrollView];
    
    if(gridView.editable)
    {
        


        
        //Picking & Move
        float deltaX = newTouchLocation.x - _touchLocation.x;
        float deltaY = newTouchLocation.y - _touchLocation.y;
        

        [self moveByOffset:CGPointMake(deltaX, deltaY)];
            
   
        [gridView performSelector:@selector(CellCollisionDetection:) withObject:self];
       
        
        
        //PageMove
//        NSInteger MaxScrollwidth = gridView.scrollView.bounds.size.width * gridView.currentPageIndex;
//        NSInteger MinScrollwidth = gridView.scrollView.bounds.size.width * gridView.currentPageIndex - gridView.scrollView.bounds.size.width;
        NSInteger MaxScrollwidth = gridView.scrollView.contentOffset.x + gridView.scrollView.bounds.size.width;
        NSInteger MinScrollwidth = gridView.scrollView.contentOffset.x;
        if(MaxScrollwidth - self.center.x < 20)
        {
            if(_movePagesTimer == nil)
            {
                _movePagesTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                   target:self 
                                                                 selector:@selector(movePagesTimer:) 
                                                                 userInfo:@"right" 
                                                                  repeats:NO];
            
                NSLog(@"movePageTmr right");
            }
        }
        else if(self.center.x - MinScrollwidth < 20)
        {
            
            if(_movePagesTimer ==nil)
            {
                _movePagesTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                   target:self 
                                                                 selector:@selector(movePagesTimer:) 
                                                                 userInfo:@"left" 
                                                                  repeats:NO];
                NSLog(@"movePageTmr left");
            }
        }
        else
        {
            if(_movePagesTimer !=nil)
            {
                NSLog(@"MovPageTimver invalidate");
                [_movePagesTimer invalidate];
                NSLog(@"MovPageTimver nil");
                _movePagesTimer = nil;
                
            }
        }
    
        
        
        _touchLocation = newTouchLocation;
        
        
    }


    
    [super touchesMoved:touches withEvent:event];
    
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    gridView.scrollView.scrollEnabled = YES;

    
    
    if(gridView.editable)
    {
        [_movePagesTimer invalidate];
        _movePagesTimer = nil;
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseIn 
                         animations:^{
                             
							 self.transform = CGAffineTransformIdentity;
							 self.alpha = 1;
                             
                             
                         }
                         completion:nil];
        
        
        [gridView CellSetPosition:self];
    }
    
    
    else
    {
        SEL singleTapSelector = @selector(cellWasSelected:);
        //    SEL doubleTapSelector = @selector(cellWasDoubleTapped:);
        
        if (gridView) {
            UITouch *touch = [touches anyObject];
            
            switch ([touch tapCount]) 
            {
                case 1:
                    [gridView performSelector:singleTapSelector withObject:self afterDelay:.3];
                    break;
                    
                    //            case 2:
                    //                [gridView performSelector:doubleTapSelector withObject:self];
                    //                break;
                    
                default:
                    break;
            }
        }
        
    }
    
    NSLog(@"TE");
    //[super touchesEnded:touches withEvent:event];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [_movePagesTimer invalidate];
    _movePagesTimer = nil;
    if(gridView.editable)
    {
        NSLog(@"add to GridView");
        gridView.scrollView.scrollEnabled = YES;
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseIn 
                         animations:^{
                             
							 self.transform = CGAffineTransformIdentity;
							 self.alpha = 1;
                             
                             
                         }
                         completion:nil];
    }
}


- (void) BtnActionDelete;
{
    NSLog(@"Delete Button %d",self.index);
    [UIView animateWithDuration:0.1 
						  delay:0 
						options:UIViewAnimationOptionCurveEaseIn 
					 animations:^{	
						 self.alpha = 0;
						 self.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
					 }
					 completion:nil];
    
    [self.gridView performSelector:@selector(cellWasDelete:) withObject:self];
    
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)moveByOffset:(CGPoint)offset {
	
	CGRect frame = [self frame];
	frame.origin.x += offset.x;
	frame.origin.y += offset.y;
	[self setFrame:frame];
}


- (void)SetPosition:(CGPoint) point {
	
    CGRect frame = [self frame];
	frame.origin.x = point.x;
	frame.origin.y = point.y;
	[self setFrame:frame];
    
}

-(void)movePagesTimer:(NSTimer*)timer
{

    //PageMove
//    NSInteger MaxScrollwidth = gridView.scrollView.bounds.size.width * gridView.currentPageIndex;
//    NSInteger MinScrollwidth = gridView.scrollView.bounds.size.width * gridView.currentPageIndex - gridView.scrollView.bounds.size.width;	
    
    NSLog(@"movePageTimer in");
    NSInteger MaxScrollwidth = gridView.scrollView.contentOffset.x + gridView.scrollView.bounds.size.width;
    NSInteger MinScrollwidth = gridView.scrollView.contentOffset.x;
	if([(NSString*)timer.userInfo isEqualToString:@"right"])
    {

        if(MaxScrollwidth - self.center.x < 20)
        {
            if(gridView.numberOfPages > gridView.currentPageIndex)
            {
                [gridView MovePage:gridView.currentPageIndex+1];
                [self moveByOffset:CGPointMake(gridView.scrollView.frame.size.width, 0)];
                _touchLocation =CGPointMake(_touchLocation.x + gridView.scrollView.frame.size.width, _touchLocation.y);
            }
        }
    }
    else if([(NSString*)timer.userInfo isEqualToString:@"left"])
    {
        if(self.center.x - MinScrollwidth < 20)
        {
            if(gridView.currentPageIndex >0)
            {
                [gridView MovePage:gridView.currentPageIndex-1];
                [self moveByOffset:CGPointMake(gridView.scrollView.frame.size.width*-1, 0)];
                _touchLocation =CGPointMake(_touchLocation.x - gridView.scrollView.frame.size.width, _touchLocation.y);
            }   
        }
        
    }

        

    _movePagesTimer = nil;
    
}

- (void)setEdit:(BOOL)edit
{
    if(edit == YES)
    {
        if(self.deletable == YES)
        {
            [self.ButtonDelete setHidden:NO];
        }
    }
    else
    {
        if(self.deletable ==YES)
        {
            [self.ButtonDelete setHidden:YES];
        }
        
    }
}


@end
