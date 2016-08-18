//
//  FocusViewController.m
//  IntegratingFacebookTutorial
//
//  Created by Francisco Padilla on 4/14/14.
//
//

#import "FocusViewController.h"

@interface FocusViewController ()

@end

@implementation FocusViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.newTaskEnabled = TRUE;
        self.moveTaskEnabled = TRUE;
        self.orderColumn = @"FocusOrder";
    }
    return self;
}

-(PFQuery*)queryForTable
{
    PFQuery* focusQuery = [PFQuery queryWithClassName:self.parseClassName];
    [focusQuery whereKey:@"Mark" equalTo:@YES];
    [focusQuery whereKey:@"User" equalTo:[PFUser currentUser]];
    [focusQuery whereKey:@"Status" equalTo:@"NotDone"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                               fromDate:[NSDate date] ];
    NSDate* startToday = [calendar dateFromComponents:components];
    NSDate* stopToday = [startToday dateByAddingTimeInterval:60*60*24];
    PFQuery* doneTodayQuery = [PFQuery queryWithClassName:self.parseClassName];
    [doneTodayQuery whereKey:@"DoneDate" greaterThan:startToday];
    [doneTodayQuery whereKey:@"DoneDate" lessThanOrEqualTo:stopToday];
    [doneTodayQuery whereKeyExists:@"DoneDate"];

    [doneTodayQuery whereKey:@"Status" equalTo:@"Done"];
    [doneTodayQuery whereKey:@"User" equalTo:[PFUser currentUser]];

    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[focusQuery,doneTodayQuery]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;

    [query orderByAscending:@"FocusOrder"];
    return query;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
