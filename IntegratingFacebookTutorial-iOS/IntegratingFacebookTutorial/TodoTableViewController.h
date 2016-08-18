//
//  TodoTableViewController.h
//  IntegratingFacebookTutorial
//
//  Created by Francisco Padilla on 3/26/14.
//
//

#import <Parse/Parse.h>

@interface TodoTableViewController : PFQueryTableViewController < UITextFieldDelegate>
{
    UITextField* activeTextField;
}

@property (strong, retain) NSMutableArray* data;
@property (assign) BOOL newTaskEnabled;
@property (assign) BOOL moveTaskEnabled;
@property (strong) NSString* orderColumn;

- (IBAction)longPressGestureRecognized:(id)sender ;
@end
