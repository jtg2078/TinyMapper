//
//  DetailViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/5/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBox.h"
#import "MGScrollView.h"
#import "MGStyledBox.h"
#import "MGBoxLine.h"
#import "Entry.h"

@interface DetailViewController : UIViewController <UIScrollViewDelegate>
{
    
}

@property (nonatomic, strong) MGScrollView *scroller;
@property (strong, nonatomic) Entry *entry;

@end
