//
//  PlanViewController.m
//  IntegratingFacebookTutorial
//
//  Created by Francisco Padilla on 4/14/14.
//
//

#import "PlanViewController.h"

@interface PlanViewController ()

@end

@implementation PlanViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.newTaskEnabled = TRUE;
        self.moveTaskEnabled = TRUE;
        self.orderColumn = @"PlanOrder";
    }
    return self;
}

-(PFQuery*)queryForTable
{
    PFQuery* planQuery = [PFQuery queryWithClassName:self.parseClassName];
    [planQuery whereKey:@"Status" notEqualTo:@"Done"];
    [planQuery whereKey:@"User" equalTo:[PFUser currentUser]];
    
    planQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    [planQuery orderByAscending:@"PlanOrder"];
    return planQuery;
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
