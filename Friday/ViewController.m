//
//  ViewController.m
//  Friday
//
//  Created by Gabriel Massana on 1/14/14.
//  Copyright (c) 2014 Gabriel Massana. All rights reserved.
//

#import "ViewController.h"
#import "Utils.h"
#import "ActivityViewCustomProvider.h"

//Settings (change day) picker
//Settings (when Friday starts)  picker
//Share button
//Check iPhone5 and iPad

//Add alarm with Settings.bundle  - Push nitifications?

@interface ViewController ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UILabel *howLongUntilLabel;
@property (nonatomic, strong) UILabel *friday;

@property (nonatomic, strong) UIButton *changeDay;
@property (nonatomic, strong) UILabel *changeDayArrow;

@property (nonatomic, strong) UILabel *daysLabel;
@property (nonatomic, strong) UILabel *hoursLabel;
@property (nonatomic, strong) UILabel *minutesLabel;
@property (nonatomic, strong) UILabel *secondsLabel;

@property (nonatomic) CGFloat initialY;

@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UIActionSheet *actionSheetPicker;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSArray *weekDaysArray;
@property (nonatomic, strong) NSArray *hoursArray;
@property (nonatomic, strong) NSArray *colonArray;
@property (nonatomic, strong) NSArray *minutesArray;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIPopoverController *pickerPopover;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self.userDefaults setObject:@"5" forKey:@"WEEKDAY"];
    [self.userDefaults setObject:@"0" forKey:@"HOUR"];
    [self.userDefaults setObject:@"0" forKey:@"MINUTES"];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];
    
    self.weekDaysArray = @[@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"];
    self.hoursArray = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",
                        @"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"];
    self.colonArray = @[@":"];
    self.minutesArray = @[@"00",@"15",@"30",@"45"];
    
    self.actionSheetPicker = [[UIActionSheet alloc]initWithTitle:@"" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(reloadTime:)
                                                userInfo:nil
                                                 repeats:YES];
    
    
    self.initialY = 40;
    
    self.changeDay = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.changeDay setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, 100)];
    [self.changeDay addTarget:self action:@selector(changeDayClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeDay];
    
    self.howLongUntilLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, 35)];
    [self.howLongUntilLabel setText:@"How long until"];
    [self.howLongUntilLabel setTextColor:[UIColor blackColor]];
    [self.howLongUntilLabel setTextAlignment:NSTextAlignmentCenter];
    [self.howLongUntilLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:30]];
    [self.view addSubview:self.howLongUntilLabel];
    
    self.initialY += 35;
    
    self.friday = [[UILabel alloc] initWithFrame:CGRectMake(30, self.initialY, SCREEN_WIDTH-60, 60)];
    [self.friday setText:@"Friday?"];
    [self.friday setTextColor:[UIColor blackColor]];
    [self.friday setTextAlignment:NSTextAlignmentCenter];
    [self.friday setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:50]];
    [self.friday setAdjustsFontSizeToFitWidth:YES];
    [self.friday setMinimumScaleFactor:0.5f];
    [self.view addSubview:self.friday];
    
    self.changeDayArrow = [[UILabel alloc] initWithFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH-10, 60)];
    [self.changeDayArrow setText:@">"];
    [self.changeDayArrow setTextColor:[UIColor blackColor]];
    [self.changeDayArrow setTextAlignment:NSTextAlignmentRight];
    [self.changeDayArrow setFont:[UIFont fontWithName:@"EuphemiaUCAS" size:25]];
    [self.view addSubview:self.changeDayArrow];

    CGFloat heightText = 0.0;
    
    //iPhone4 and iPhone5 Layout
    if (SCREEN_HEIGHT == 480 && USER_INTERFACE_IDIOM != IPAD)
    {
        self.initialY += 100;
        heightText = (SCREEN_HEIGHT - self.initialY - 100) / 4.0f;
    }
    else if (SCREEN_HEIGHT > 480 && USER_INTERFACE_IDIOM != IPAD)
    {
        self.initialY += 130;
        heightText = (SCREEN_HEIGHT - self.initialY - 130) / 4.0f;
    }
    
    self.daysLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
    [self.daysLabel setText:[NSString stringWithFormat:@"%@", [self getDaysToFriday]]];
    [self.daysLabel setTextColor:[UIColor blackColor]];
    [self.daysLabel setTextAlignment:NSTextAlignmentCenter];
    [self.daysLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25]];
    [self.view addSubview:self.daysLabel];
    
    self.initialY += heightText;
    
    self.hoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
    [self.hoursLabel setText:[NSString stringWithFormat:@"%@", [self getHoursToFriday]]];
    [self.hoursLabel setTextColor:[UIColor blackColor]];
    [self.hoursLabel setTextAlignment:NSTextAlignmentCenter];
    [self.hoursLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25]];
    [self.view addSubview:self.hoursLabel];
    
    self.initialY += heightText;
    
    self.minutesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
    [self.minutesLabel setText:[NSString stringWithFormat:@"%@", [self getMinutesToFriday]]];
    [self.minutesLabel setTextColor:[UIColor blackColor]];
    [self.minutesLabel setTextAlignment:NSTextAlignmentCenter];
    [self.minutesLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25]];
    [self.view addSubview:self.minutesLabel];
    
    self.initialY += heightText;
    
    self.secondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
    [self.secondsLabel setText:[NSString stringWithFormat:@"%@", [self getSecondsToFriday]]];
    [self.secondsLabel setTextColor:[UIColor blackColor]];
    [self.secondsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.secondsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25]];
    [self.view addSubview:self.secondsLabel];
    
    int buttonSize = 70;
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setFrame:CGRectMake(SCREEN_WIDTH-buttonSize, SCREEN_HEIGHT-buttonSize, buttonSize, buttonSize)];
    [self.shareButton addTarget:self action:@selector(shareButtonlicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
    [self.view addSubview:self.shareButton];

    //iPad Layout
    if (IPAD == USER_INTERFACE_IDIOM)
    {
        int buttonSize = 150;
        [self.shareButton setFrame:CGRectMake(SCREEN_WIDTH-buttonSize, SCREEN_HEIGHT-buttonSize, buttonSize, buttonSize)];
        
        self.initialY = 40;
        
        [self.changeDay setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, 200)];
        
        [self.howLongUntilLabel setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, 70)];
        [self.howLongUntilLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:60]];
        
        self.initialY += 70;
        
        [self.friday setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, 120)];
        [self.friday setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:80]];
        
        [self.changeDayArrow setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH-20, 120)];
        [self.changeDayArrow setFont:[UIFont fontWithName:@"EuphemiaUCAS" size:50]];
        
        self.initialY += 230;
        
        CGFloat heightText = (SCREEN_HEIGHT - self.initialY - 230) / 4.0f;
        
        [self.daysLabel setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
        [self.daysLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:50]];
        
        self.initialY += heightText;
        
        [self.hoursLabel setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
        [self.hoursLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:50]];
        
        self.initialY += heightText;
        
        [self.minutesLabel setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
        [self.minutesLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:50]];
        
        self.initialY += heightText;
        
        [self.secondsLabel setFrame:CGRectMake(0, self.initialY, SCREEN_WIDTH, heightText)];
        [self.secondsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:50]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

#pragma mark Timer reload Time

- (void) reloadTime: (id) sender
{
    [self.daysLabel setText:[NSString stringWithFormat:@"%@", [self getDaysToFriday]]];
    [self.hoursLabel setText:[NSString stringWithFormat:@"%@", [self getHoursToFriday]]];
    [self.minutesLabel setText:[NSString stringWithFormat:@"%@", [self getMinutesToFriday]]];
    [self.secondsLabel setText:[NSString stringWithFormat:@"%@", [self getSecondsToFriday]]];
}

#pragma mark get days, hours, minutes and seconds

-(NSString *) getDaysToFriday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[self getDateWithAdjustement]];
    // weekday: Sunday = 1, Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7
    NSInteger weekday = [comps weekday];
    
    NSInteger returnDays;
    
    NSInteger selectedDay = [[self.userDefaults objectForKey:@"WEEKDAY"] integerValue];
    
    if (weekday > selectedDay)
    {
        selectedDay += 7;
    }
    
    returnDays = selectedDay - weekday;
    
    if (returnDays == 1)
    {
        return [NSString stringWithFormat:@"%ld day", (long)returnDays];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld days", (long)returnDays];
    }
}


-(NSString *) getHoursToFriday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[self getDateWithAdjustement]];
    NSInteger hours = [comps hour];
    
    NSInteger returnHours = (24-hours) - 1;
    
    if (returnHours == 1)
    {
        return [NSString stringWithFormat:@"%ld hour", (long)returnHours];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld hours", (long)returnHours];
    }
}


-(NSString *) getMinutesToFriday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[self getDateWithAdjustement]];
    NSInteger minutes = [comps minute];

    NSInteger returnMinutes = (60-minutes) - 1;
    
    if (returnMinutes == 1)
    {
        return [NSString stringWithFormat:@"%ld minute", (long)returnMinutes];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld minutes", (long)returnMinutes];
    }
}

-(NSString *) getSecondsToFriday
{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[self getDateWithAdjustement]];
    NSInteger seconds = [comps second];
    
    NSInteger returnSeconds = (60-seconds) - 1;
    
    if (returnSeconds == 1)
    {
        return [NSString stringWithFormat:@"%ld second", (long)returnSeconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld seconds", (long)returnSeconds];
    }
}

- (NSDate *) getDateWithAdjustement
{
    if ([[self.userDefaults objectForKey:@"HOUR"] integerValue] == 0 && [[self.userDefaults objectForKey:@"MINUTES"] integerValue] == 0)
    {
        return [NSDate date];
    }
    else
    {
        NSDate *date = [NSDate date];
        
        NSInteger hourToAdd = [[self.userDefaults objectForKey:@"HOUR"] integerValue];
        NSInteger minutesToAdd = [[self.minutesArray objectAtIndex:[[self.userDefaults objectForKey:@"MINUTES"] integerValue]] integerValue];
        
        NSTimeInterval hours = -hourToAdd * 60 * 60;
        NSDate *dateReturnPlusHour =[date dateByAddingTimeInterval:hours];
        
        NSTimeInterval minutes = -minutesToAdd * 60;
        NSDate *dateReturnPlusHourAndMinutes =[dateReturnPlusHour dateByAddingTimeInterval:minutes];
        
        return dateReturnPlusHourAndMinutes;
    }
}

#pragma mark change day

- (void) changeDayClicked: (id) sender
{
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    [self.picker setDataSource: self];
    [self.picker setDelegate: self];
    self.picker.showsSelectionIndicator = YES;
    
    [self.picker setBackgroundColor:[UIColor whiteColor]];
    
    UIToolbar *pickerDateToolbar;
    if (USER_INTERFACE_IDIOM == IPAD)
    {
        pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, 44)];
    }
    else
    {
        pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    }
    pickerDateToolbar.barStyle = UIBarStyleBlack;
    [pickerDateToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UILabel *labelTitle = [[UILabel alloc]init];
    [labelTitle setText:@"Select day and time"];
    UIBarButtonItem *titleText = [[UIBarButtonItem alloc] initWithTitle:labelTitle.text style:UIBarButtonItemStylePlain target:nil action:nil];
    [barItems addObject:titleText];
    
    UIBarButtonItem *flexSpace;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        
        NSDictionary *attributes = @{NSFontAttributeName: [labelTitle font]};

        CGSize textSize = [[labelTitle text] sizeWithAttributes:attributes];
        
        flexSpace.width = 300-textSize.width;
    }
    else
    {
        flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    }
    
    [barItems addObject:flexSpace];
   
    [self.picker selectRow:[[self.userDefaults objectForKey:@"WEEKDAY"] integerValue] inComponent:0 animated:NO];
    [self.picker selectRow:[[self.userDefaults objectForKey:@"HOUR"] integerValue] inComponent:1 animated:NO];
    [self.picker selectRow:[[self.userDefaults objectForKey:@"MINUTES"] integerValue] inComponent:3 animated:NO];

    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [barItems addObject:doneBtn];
    
    [pickerDateToolbar setItems:barItems animated:YES];
    
    [self.actionSheetPicker addSubview:pickerDateToolbar];
    [self.actionSheetPicker addSubview:self.picker];
    
    if (USER_INTERFACE_IDIOM == IPAD)
    {
        UIButton *senderButton = (UIButton*) sender;
        UIView *view = [[UIView alloc]init];
        [self.picker setFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 216)];
        [view addSubview:self.picker];
        [view addSubview:pickerDateToolbar];
        
        UIViewController *vc = [[UIViewController alloc] init];
        [vc setView:view];
        //[vc setContentSizeForViewInPopover:CGSizeMake(SCREEN_WIDTH, 260)];
        [vc setPreferredContentSize:CGSizeMake(SCREEN_WIDTH / 2, 216)];
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [self.popover presentPopoverFromRect:senderButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
         
    }
    else
    {
        [self.actionSheetPicker showInView:self.view];
        [self.actionSheetPicker setBounds:CGRectMake(0,0,320, 464)];
    }
}


- (void) doneClicked: (id) sender
{
    [self.actionSheetPicker dismissWithClickedButtonIndex:0 animated:YES];
    
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)[self.picker selectedRowInComponent:0]] forKey:@"WEEKDAY"];
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)[self.picker selectedRowInComponent:1]] forKey:@"HOUR"];
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)[self.picker selectedRowInComponent:3]] forKey:@"MINUTES"];
    
    [self.friday setText:[NSString stringWithFormat:@"%@?",[self.weekDaysArray objectAtIndex: [self.picker selectedRowInComponent:0]]]];
    
    for (UIView *view in self.actionSheetPicker.subviews)
    {
        [view removeFromSuperview];
    }
    [self.popover dismissPopoverAnimated:YES];
    
    [self reloadTime:nil];
}


#pragma mark Picker delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [self.weekDaysArray count];
    }
    else if (component == 1)
    {
        return [self.hoursArray count];
    }
    else if (component == 2)
    {
        return [self.colonArray count];
    }
    else
    {
        return [self.minutesArray count];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
        if (component == 0)
        {
            return [self.weekDaysArray objectAtIndex: row];
        }
        else if (component == 1)
        {
            return [self.hoursArray objectAtIndex: row];
        }
        else if (component == 2)
        {
            return [self.colonArray objectAtIndex: row];
        }
        else
        {
            return [self.minutesArray objectAtIndex: row];
        }
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (!(USER_INTERFACE_IDIOM == IPAD))
    {
        if (component == 0)
        {
            return SCREEN_WIDTH / 2 ;
        }
        else if (component == 1)
        {
            return SCREEN_WIDTH / 9;
        }
        else if (component == 2)
        {
            return SCREEN_WIDTH / 10;
        }
        else
        {
            return SCREEN_WIDTH / 9;
        }
    }
    else
    {
        if (component == 0)
        {
            return SCREEN_WIDTH / 4 ;
        }
        else if (component == 1)
        {
            return SCREEN_WIDTH / 18;
        }
        else if (component == 2)
        {
            return SCREEN_WIDTH / 30;
        }
        else
        {
            return SCREEN_WIDTH / 18;
        }
    }
}

#pragma mark Share Button

-(void) shareButtonlicked: (id) sender
{
    ActivityViewCustomProvider *customProvider = [[ActivityViewCustomProvider alloc]init];
    [customProvider setDays:self.daysLabel.text];
    [customProvider setHours:self.hoursLabel.text];
    [customProvider setMinutes:self.minutesLabel.text];
    [customProvider setSeconds:self.secondsLabel.text];
    [customProvider setWeekday:self.friday.text];
    [customProvider setHoursSelection:[self.userDefaults objectForKey:@"HOUR"] ];
    [customProvider setMinutesSelection:[self.minutesArray objectAtIndex:[[self.userDefaults objectForKey:@"MINUTES"] integerValue]] ];
    
    NSArray *activityItems = [[NSArray alloc]initWithObjects:customProvider, @"",  nil];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:activityVC animated:TRUE completion:nil];
    }
    else
    {
        self.pickerPopover = [[UIPopoverController alloc]initWithContentViewController:activityVC];
        [self.pickerPopover presentPopoverFromRect:self.shareButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

@end
