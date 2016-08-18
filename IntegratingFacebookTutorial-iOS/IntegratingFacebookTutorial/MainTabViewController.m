//
//  MainTabViewController.m
//  IntegratingFacebookTutorial
//
//  Created by Francisco Padilla on 4/23/14.
//
//

#import "MainTabViewController.h"
#import "TodoViewCell.h"

@interface MainTabViewController ()

@end

@implementation MainTabViewController

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
    NSArray* items = self.tabBar.items;
    ((UITabBarItem*)items[0]).selectedImage = [UIImage imageNamed:@"planTabSelected"];
    ((UITabBarItem*)items[1]).selectedImage = [UIImage imageNamed:@"focusTabSelected"];
    ((UITabBarItem*)items[2]).selectedImage = [UIImage imageNamed:@"logTabSelected"];
    //((UITabBarItem*)items[3]).selectedImage = [UIImage imageNamed:@"profileTabSelected"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    [self.tabBar setTintColor:[UIColor colorWithRed:81.0/255.0 green:196.0/255.0 blue:212.0/255.0 alpha:1]];
    
    // TextField on Tables
    [[UITextField appearanceWhenContainedIn:TodoViewCell.class, nil] setFont:[UIFont fontWithName:@"Roboto-Light" size:16.0]];
    [[UITextField appearanceWhenContainedIn:TodoViewCell.class, nil] setTextColor:[UIColor colorWithRed:96.0/255.0 green:99.0/255.0 blue:102.0/255.0 alpha:1]];
    
    // Label on Navigation Bar
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                NSFontAttributeName: [UIFont fontWithName:@"Roboto-Light" size:20.0],
                NSForegroundColorAttributeName: [UIColor whiteColor]
            }];
    [[UILabel appearanceWhenContainedIn:UINavigationBar.class, nil] setTextColor:[UIColor grayColor]];
    [[UILabel appearanceWhenContainedIn:UINavigationBar.class, nil] setFont:[UIFont fontWithName:@"Roboto-Light" size:16.0]];

    //[[UILabel appearance] setColor:[UIColor colorWithRed:96.0/255.0 green:99.0/255.0 blue:102.0/255.0 alpha:1]];
    //[[UITabBar appearance] setFont:[UIFont fontWithName:@"Roboto-Light" size:10]];

    // General Label
    //[[UILabel appearance] setFont:[UIFont fontWithName:@"Roboto-Regular" size:10.0]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
