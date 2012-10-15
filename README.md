UzysSpringBoardView
===================

# Introduction

UzysSpringBoardView is UI component which is similar to the iOS HomeScreen(also known as SpringBoard)

# Features

 - Add Item dynamically  
 - Move & reorder Items by drag & drop between several pages.
 - Delete item

# GettingStarted

 1. Drag the 'UzysSpringBoard' forder into your project (UzysSpringBoardItem.h/m , UzysSpringBoardView.h/m)
 2. If you want know which item is removed, reordered, you should use UzysSpringBoardViewDelegate on ViewController
 3. Initialize UzysSpringBoardView
 
	gridView =[[UzysSpringBoardView alloc ] initWithFrame:self.view.frame numOfRow:3 numOfColumns:3];
    gridView.delegate =self;

 4. Add Items
	for(int i=0;i < 50;i++)
    {
        UzysSpringBoardItem *tmp=[[[UzysSpringBoardItem alloc] initWithFrame:CGRectNull] autorelease];
        
        tmp.textLabel.text=[NSString stringWithFormat:@"Index %d",i];
        if(i==1)
            tmp.deletable = NO;
        [gridView insertItem:tmp];
    }
 5. in order to update uiview you should call reloadData
 	[gridView reloadData];
 6. 
