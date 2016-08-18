//
//  LogViewController.m
//  IntegratingFacebookTutorial
//
//  Created by Francisco Padilla on 4/14/14.
//
//

#import "LogViewController.h"

@interface LogViewController ()

@end

@implementation LogViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

-(PFQuery*)queryForTable
{
    PFQuery* doneQuery = [PFQuery queryWithClassName:self.parseClassName];
    [doneQuery whereKey:@"Status" equalTo:@"Done"];
    [doneQuery whereKey:@"User" equalTo:[PFUser currentUser]];

    return doneQuery;
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
