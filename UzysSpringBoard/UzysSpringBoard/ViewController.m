//
//  ViewController.m
//  UzysSpringBoard
//
//  Created by Uzys on 11. 11. 22..
//


#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    gridView =[[UzysSpringBoardView alloc ] initWithFrame:self.view.frame numOfRow:3 numOfColumns:3];
    gridView.delegate =self;
    
    [self.view addSubview:gridView];
    
    
    for(int i=0;i < 500;i++)
    {
        UzysSpringBoardItem *tmp=[[[UzysSpringBoardItem alloc] initWithFrame:CGRectNull] autorelease];
        
        tmp.textLabel.text=[NSString stringWithFormat:@"Index %d",i];
        if(i==1)
            tmp.deletable = NO;
        [gridView insertItem:tmp];
    }
    
    [gridView reloadData];
    UIButton *moveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [moveButton addTarget:self action:@selector(ButtonTapp) forControlEvents:UIControlEventTouchUpInside];
    [moveButton setTitle:@"Edit" forState:UIControlStateNormal];
    [moveButton setFrame:CGRectMake(200, 200, 200, 100)];
    [self.view addSubview:moveButton];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) ButtonTapp
{
    if(gridView.editable == NO)
    {
        gridView.editable = YES;
    }
    else
    {
        gridView.editable = NO;
    }

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UzysSpringBoardViewDelegate
-(void) springBoard:(UzysSpringBoardView *)springBoard didSelectItem:(UzysSpringBoardItem *)item atIndex:(itemLocation) index
{
    NSLog(@"p: %d,i : %d",item.page,item.index);
}
-(void) springBoard:(UzysSpringBoardView *)springBoard changedPageIndex:(NSUInteger)index
{
    NSLog(@"p index:%d",index);
}
-(void) springBoard:(UzysSpringBoardView *)springBoard moveAtIndex:(itemLocation)fromindex toIndex:(itemLocation)toIndex
{
    NSLog(@"from %d,%d to %d,%d",fromindex.page,fromindex.pindex,toIndex.page,toIndex.pindex );
}
-(void) springBoard:(UzysSpringBoardView *)springBoard deleteItem:(UzysSpringBoardItem *) item atIndex:(itemLocation)index
{
    NSLog(@"deleted item %d %d",index.page,index.pindex);
}

@end
