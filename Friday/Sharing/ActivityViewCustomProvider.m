//
//  ActivityViewCustomProvider.m
//  iRiSTower
//
//  Created by Jose A. Gabriel Massana on 15/01/2013.
//
//

#import "ActivityViewCustomProvider.h"

#define URL_TWITTER_CHARACTERS 24
#define IMAGE_TWITTER_CHARACTERS 33

@implementation ActivityViewCustomProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    int hourNumber = [self.hoursSelection intValue];
    if (hourNumber < 10)
    {
        self.hoursSelection = [NSString stringWithFormat:@"0%@",self.hoursSelection];
    }
    
    NSString *returnString;
    returnString = [NSString stringWithFormat:@"How long until %@\n(%@:%@)\n\n%@\n%@\n%@\n%@", self.weekday,self.hoursSelection, self.minutesSelection, self.days, self.hours, self.minutes, self.seconds];
    return returnString;
}




@end
