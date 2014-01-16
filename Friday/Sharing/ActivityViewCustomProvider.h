//
//  ActivityViewCustomProvider.h
//  iRiSTower
//
//  Created by Jose A. Gabriel Massana on 15/01/2013.
//
//

#import <UIKit/UIKit.h>

@interface ActivityViewCustomProvider : UIActivityItemProvider <UIActivityItemSource>

@property (nonatomic, strong) NSString *days;
@property (nonatomic, strong) NSString *hours;
@property (nonatomic, strong) NSString *minutes;
@property (nonatomic, strong) NSString *seconds;
@property (nonatomic, strong) NSString *weekday;
@property (nonatomic, strong) NSString *hoursSelection;
@property (nonatomic, strong) NSString *minutesSelection;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end
