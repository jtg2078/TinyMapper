//
//  DetailViewController.m
//  TinyMapper
//
//  Created by ling tsu hsuan on 7/5/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - define

#define ANIM_SPEED 0.6

#pragma mark - synthesize

@synthesize scroller;
@synthesize entry;
@synthesize phoneAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // -------------------- view controller --------------------
    
    self.view.backgroundColor = [UIColor colorWithRed:0.29 green:0.32 blue:0.35 alpha:1];
    UIFont *headerFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    
    // -------------------- naivgation bar --------------------
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", nil) 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    // -------------------- MGScrollView --------------------
    
    CGRect frame = CGRectMake(0, 0, 320, 416);
    scroller = [[MGScrollView alloc] initWithFrame:frame];
    [self.view addSubview:scroller];
    scroller.alwaysBounceVertical = YES;
    scroller.delegate = self;
    
    // -------------------- title box --------------------
    
    MGStyledBox *titleBox = [MGStyledBox box];
    [scroller.boxes addObject:titleBox];
    
    MGBoxLine *typeLine = [MGBoxLine lineWithLeft:entry.name right:nil];
    typeLine.font = headerFont;
    [titleBox.topLines addObject:typeLine];
    
    MGBoxLine *nameLine = [MGBoxLine lineWithLeft:entry.type right:nil];
    [titleBox.topLines addObject:nameLine];
    
    // -------------------- info box --------------------
    
    MGStyledBox *infoBox = [MGStyledBox box];
    [scroller.boxes addObject:infoBox];
    
    MGBoxLine *infoLine = [MGBoxLine lineWithLeft:@"資訊" right:nil];
    infoLine.font = headerFont;
    [infoBox.topLines addObject:infoLine];
    
    
    MGBoxLine *telLine = [MGBoxLine lineWithLeft:entry.tel right:nil];
    [infoBox.topLines addObject:telLine];
    
    MGBoxLine *addressLine = [MGBoxLine multilineWithText:entry.address font:nil padding:24];
    [infoBox.topLines addObject:addressLine];
    
    UIButton *telButton = [self button:@"撥打電話" forAction:@selector(callPhone:)];
    UIButton *openAddressButton = [self button:@"在google map開啟" forAction:@selector(openAddressInGoogleMap:)];
    UIButton *copyAddressButton = [self button:@"複製地址" forAction:@selector(copyAddress:)];
    
    NSArray *left = [NSArray arrayWithObjects:telButton, nil];
    NSArray *right = [NSArray arrayWithObjects:openAddressButton, copyAddressButton, nil];
    
    MGBoxLine *buttonsLine = [MGBoxLine lineWithLeft:left right:right];
    [infoBox.topLines addObject:buttonsLine];
    
    // -------------------- reservation box --------------------
    
    MGStyledBox *reservationBox = [MGStyledBox box];
    [scroller.boxes addObject:reservationBox];
    
    MGBoxLine *reservationHeaderLine = [MGBoxLine lineWithLeft:@"定位難易" right:nil];
    reservationHeaderLine.font = headerFont;
    [reservationBox.topLines addObject:reservationHeaderLine];
    
    NSString *reservation = @"沒有資料";
    if([entry.reservation length])
        reservation = entry.reservation;
    
    MGBoxLine *reservationLine = [MGBoxLine multilineWithText:reservation font:nil padding:24];
    [reservationBox.topLines addObject:reservationLine];
    
    // -------------------- review box --------------------
    
    MGStyledBox *reviewBox = [MGStyledBox box];
    [scroller.boxes addObject:reviewBox];
    
    MGBoxLine *reviewHeaderLine = [MGBoxLine lineWithLeft:@"其他" right:nil];
    reviewHeaderLine.font = headerFont;
    [reviewBox.topLines addObject:reviewHeaderLine];
    
    NSString *review = @"沒有資料";
    if([entry.review length])
        review = entry.review;
    
    MGBoxLine *reviewLine = [MGBoxLine multilineWithText:review font:nil padding:24];
    [reviewBox.topLines addObject:reviewLine];
    
    // draw all the boxes and animate as appropriate
    [scroller drawBoxesWithSpeed:ANIM_SPEED];
    [scroller flashScrollIndicators];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.scroller.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - misc

- (UIButton *)button:(NSString *)title forAction:(SEL)selector 
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    [button setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9]
                 forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.2 alpha:0.9]
                       forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    CGSize size = [title sizeWithFont:button.titleLabel.font];
    button.frame = CGRectMake(0, 0, size.width + 18, 26);
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    button.layer.cornerRadius = 3;
    button.backgroundColor = self.view.backgroundColor;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowRadius = 0.8;
    button.layer.shadowOpacity = 0.6;
    
    return button;
}

- (NSString *)preparePhoneNumber:(NSString *)telString
{
    // phone num length should be xx-xxxx-xxxx
    //                            00200007
    
    NSMutableString *processed = [NSMutableString stringWithCapacity:10+2];
    
    NSScanner *scanner = [NSScanner scannerWithString:telString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while([scanner isAtEnd] == NO && processed.length < 12)
    {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) 
        {
            [processed appendString:buffer];
            if(processed.length == 2 || processed.length == 7)
                [processed appendString:@"-"];
        } 
        else 
        {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    return processed;    
}

#pragma mark - user interaction

- (void)callPhone:(UIButton *)sender
{
    NSString *tel = [self preparePhoneNumber:self.entry.tel];
    
    phoneAlert = [[UIAlertView alloc] initWithTitle:nil 
                                            message:[NSString stringWithFormat:@"撥號: %@", tel] 
                                           delegate:self 
                                  cancelButtonTitle:@"取消" 
                                  otherButtonTitles:@"撥打", nil];
    
    [phoneAlert show];
}

- (void)openAddressInGoogleMap:(UIButton *)sender
{
    NSString *address = self.entry.address;
    
    if([self.entry.formattedAddress length])
        address = self.entry.formattedAddress;
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",
                           [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)copyAddress:(UIButton *)sender
{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    generalPasteBoard.string = self.entry.address;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已複製到剪貼簿" 
                                                        message:self.entry.address 
                                                       delegate:nil 
                                              cancelButtonTitle:nil otherButtonTitles:@"ok",nil];
    
    [alertView show];
}

- (void)dismiss
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView == self.phoneAlert)
    {
        if(buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.entry.tel]]];
        }
        
        NSLog(@"%d", buttonIndex);
    }
}





@end
