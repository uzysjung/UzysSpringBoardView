//
//  UzysSpringBoardItem.m
//  UzysSpringBoard
//
//  Created by 정 재훈 on 11. 11. 22..
//  Copyright (c) 2011 NCSoft. All rights reserved.
//

#import "UzysSpringBoardItem.h"
#import "UzysSpringBoardView.h"

@interface UzysSpringBoardItem (private)

- (void)moveByOffset:(CGPoint)offset;
- (void)movePagesTimer:(NSTimer*)timer;
-(void) handleLongPress:(UILongPressGestureRecognizer *)recognizer;
@end

@implementation UzysSpringBoardItem
@synthesize deletable,dragging;
@synthesize SpringBoard;
@synthesize ButtonDelete;
@synthesize page,index;
//@synthesize itemLoc;
@synthesize textLabel;
@synthesize textLabelBackgroundView;
@synthesize backgroundView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        deletable = YES;
        dragging = NO;
        self.exclusiveTouch = YES;
        
        
        UILongPressGestureRecognizer *_gestureLong = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _gestureLong.minimumPressDuration =0.8;
        
        [self addGestureRecognizer:_gestureLong];
        
        [_gestureLong release];
        
        
        
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectNull] autorelease];
        self.backgroundView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.backgroundView];
        
        // Label
        self.textLabelBackgroundView = [[[UIView alloc] initWithFrame:CGRectNull] autorelease];
        self.textLabelBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        self.textLabel = [[[UILabel alloc] initWithFrame:CGRectNull] autorelease];
        self.textLabel.textAlignment = UITextAlignmentRight;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        
        [self.textLabelBackgroundView addSubview:self.textLabel];
        [self addSubview:self.textLabelBackgroundView];
        
        
        ButtonDelete = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [ButtonDelete addTarget:self action:@selector(BtnActionDelete) forControlEvents:UIControlEventTouchUpInside];
        [ButtonDelete setImage:[UIImage imageNamed:@"icon_del.png"] forState:UIControlStateNormal];
        [ButtonDelete setImage:[UIImage imageNamed:@"icon_del_h.png"] forState:UIControlStateHighlighted];
        [ButtonDelete setHidden:YES];
        [self addSubview:ButtonDelete];
        
    }
    return self;
}
-(void) handleLongPress:(UILongPressGestureRecognizer *)recognizer  {
    if(self.SpringBoard.editable == NO)
        self.SpringBoard.editable = YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)layoutSubviews
{
    [super layoutSubviews];

    
    CGSize imgsize = [UIImage imageNamed:@"icon_del.png"].size;
    CGRect CellBound = self.bounds;
    [ButtonDelete setFrame:CGRectMake(CellBound.size.width - imgsize.width , 0, imgsize.width, imgsize.height)];
    
    int labelHeight = 30;
    int inset = 5;
    
    // Background view
    self.backgroundView.frame = self.bounds;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Layout label
    self.textLabelBackgroundView.frame = CGRectMake(0, 
                                                    self.bounds.size.height - labelHeight - inset, 
                                                    self.bounds.size.width, 
                                                    labelHeight);
    self.textLabelBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Layout label background
    CGRect f = CGRectMake(0, 
                          0, 
                          self.textLabel.superview.bounds.size.width,
                          self.textLabel.superview.bounds.size.height);
    self.textLabel.frame = CGRectInset(f, inset, 0);
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    //
    //self.textLabel.text = [NSString stringWithFormat:@"item page:%d,index:%d",self.page,self.index];
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


- (void) BtnActionDelete;
{
//    NSLog(@"Delete Button %d",self.index);
    [UIView animateWithDuration:0.1 
						  delay:0 
						options:UIViewAnimationOptionCurveEaseIn 
					 animations:^{	
						 self.alpha = 0;
						 self.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
					 }
					 completion:nil];
    

    NSLog(@"item page:%d,index:%d",self.page,self.index);
    [self.SpringBoard performSelector:@selector(cellWasDelete:) withObject:self];
    
}

#pragma - Touch event Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _touchLocation = [[touches anyObject] locationInView:self.SpringBoard.scrollView];
    
    if(SpringBoard.editable)
    {
        self.dragging = YES;
        SpringBoard.scrollView.scrollEnabled = NO;
        //Bring Subview to Front
        [SpringBoard.scrollView bringSubviewToFront:self];
        
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
	
    [super touchesMoved:touches withEvent:event];
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self.SpringBoard.scrollView];
    
    if(SpringBoard.editable)
    {
        
        
        [SpringBoard.scrollView bringSubviewToFront:self];
        
        //Picking & Move
        float deltaX = newTouchLocation.x - _touchLocation.x;
        float deltaY = newTouchLocation.y - _touchLocation.y;
        
        
        [self moveByOffset:CGPointMake(deltaX, deltaY)];
        
        
        [SpringBoard performSelector:@selector(CellCollisionDetection:) withObject:self];
        
        
        
        //PageMove
        
        NSInteger MaxScrollwidth = SpringBoard.scrollView.contentOffset.x + SpringBoard.scrollView.bounds.size.width;
        NSInteger MinScrollwidth = SpringBoard.scrollView.contentOffset.x;
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
    
    
    
    
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    
    
    
    
    if(SpringBoard.editable)
    {
        self.dragging = NO;
        SpringBoard.scrollView.scrollEnabled = YES;
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
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [self.SpringBoard layoutItems];
        [UIView commitAnimations];
        
        
        //  [SpringBoard CellSetPosition:self];
    }
    
    
    else
    {
        SEL singleTapSelector = @selector(cellWasSelected:);
        //    SEL doubleTapSelector = @selector(cellWasDoubleTapped:);
        
        if (SpringBoard) {
            UITouch *touch = [touches anyObject];
            
            switch ([touch tapCount])
            {
                case 1:
                    [SpringBoard performSelector:singleTapSelector withObject:self afterDelay:.3];
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
    
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(SpringBoard.editable)
    {
        dragging = NO;
    }
    [super touchesCancelled:touches withEvent:event];
}

- (void)moveByOffset:(CGPoint)offset {
	
	CGRect frame = [self frame];
	frame.origin.x += offset.x;
	frame.origin.y += offset.y;
	[self setFrame:frame];
}

-(void)movePagesTimer:(NSTimer*)timer
{
    
    //PageMove
    //    NSInteger MaxScrollwidth = gridView.scrollView.bounds.size.width * gridView.currentPageIndex;
    //    NSInteger MinScrollwidth = gridView.scrollView.bounds.size.width * gridView.currentPageIndex - gridView.scrollView.bounds.size.width;
    
    NSLog(@"movePageTimer in");
    NSInteger MaxScrollwidth = SpringBoard.scrollView.contentOffset.x + SpringBoard.scrollView.bounds.size.width;
    NSInteger MinScrollwidth = SpringBoard.scrollView.contentOffset.x;
	if([(NSString*)timer.userInfo isEqualToString:@"right"])
    {
        
        if(MaxScrollwidth - self.center.x < 20)
        {
            if(SpringBoard.numberOfPages > SpringBoard.currentPageIndex)
            {
                NSLog(@"cpi:%d",SpringBoard.currentPageIndex);
                SpringBoard.currentPageIndex++;
                NSLog(@"cpi:%d",SpringBoard.currentPageIndex);
                [self moveByOffset:CGPointMake(SpringBoard.scrollView.frame.size.width, 0)];
                _touchLocation =CGPointMake(_touchLocation.x + SpringBoard.scrollView.frame.size.width, _touchLocation.y);
            }
        }
    }
    else if([(NSString*)timer.userInfo isEqualToString:@"left"])
    {
        if(self.center.x - MinScrollwidth < 20)
        {
            NSLog(@"cpi:%d",SpringBoard.currentPageIndex);
            if(SpringBoard.currentPageIndex >0)
            {
                SpringBoard.currentPageIndex--;
                [self moveByOffset:CGPointMake(SpringBoard.scrollView.frame.size.width*-1, 0)];
                _touchLocation =CGPointMake(_touchLocation.x - SpringBoard.scrollView.frame.size.width, _touchLocation.y);
            }
        }
        
    }
    
    
    
    _movePagesTimer = nil;
    
}
@end
