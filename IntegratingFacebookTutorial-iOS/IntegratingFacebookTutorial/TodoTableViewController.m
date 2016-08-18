//
//  TodoTableViewController.m
//  IntegratingFacebookTutorial
//
//  Created by Francisco Padilla on 3/26/14.
//
//

#import "TodoTableViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TodoTableViewController ()

@end

@implementation TodoTableViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Custom initialization
        self.parseClassName = @"Todo";
        self.textKey = @"Title";
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self loadObjects];
    
    // move task gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
    // two fingers double tap to add task
    UITapGestureRecognizer* addTaskGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTask:)];
    addTaskGesture.numberOfTapsRequired = 2;
    addTaskGesture.numberOfTouchesRequired = 2;
    [self.tableView addGestureRecognizer:addTaskGesture];

    // double tap to edit task
    UITapGestureRecognizer* editTaskGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editTask:)];
    editTaskGesture.numberOfTapsRequired = 2;
    editTaskGesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:editTaskGesture];
    
    [editTaskGesture requireGestureRecognizerToFail:addTaskGesture];
    
    // complete task gesture
    UISwipeGestureRecognizer* completeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(completeTaskGestureRecognized:)];
    completeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    completeGesture.numberOfTouchesRequired = 2;
    [self.tableView addGestureRecognizer:completeGesture];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadObjects];
}

#pragma mark -
#pragma mark Gesture Recognizer Methods

-(void)addTask:(UILongPressGestureRecognizer *)sender
{
    if (!self.newTaskEnabled) {
        return;
    }
    UIGestureRecognizerState state = sender.state;
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

    if (!indexPath) {
        indexPath = [NSIndexPath indexPathForItem:self.data.count inSection:indexPath.section];
    } else {
        indexPath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
    }
        
    PFObject* newTask = [PFObject objectWithClassName:self.parseClassName];
    [newTask setObject:@"New Task" forKey:@"Title"];
    [newTask setObject:[PFUser currentUser] forKey:@"User"];
    [newTask setObject:@"NotDone" forKey:@"Status"];
    [newTask saveInBackground];

    [self.data insertObject:newTask atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    [self editTaskAtIndexPath:indexPath];
}

-(void)editTask:(UILongPressGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    [self editTaskAtIndexPath:indexPath];
}

-(void) editTaskAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField* textField = [cell viewWithTag:10];
    textField.enabled = YES;
    [textField becomeFirstResponder];    
}


-(void)completeTaskGestureRecognized:(UILongPressGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    PFObject* task = [self objectAtIndexPath:indexPath];
    NSString* currentStatus = [task objectForKey:@"Status"];
    if ( [currentStatus isEqualToString:@"Done"]) {
        [task setObject:@"notDone" forKey:@"Status"];
        [task setObject:[NSNull null] forKey:@"DoneDate"];
    } else {
        [task setObject:@"Done" forKey:@"Status"];
        [task setObject:[NSDate date] forKey:@"DoneDate"];
    }
    [task saveInBackground];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
}

- (IBAction)longPressGestureRecognized:(id)sender {
    
    if (!self.moveTaskEnabled) {
        return;
    }
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Black out.
                    cell.backgroundColor = [UIColor grayColor];
                } completion:nil];
            } // if
            break;
        } // case UIGestureRecognizerStateBegan
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                [self tableView:self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        } // case UIGestureRecognizerStateChanged
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo the black-out effect we did.
                cell.backgroundColor = [UIColor clearColor];
                
            } completion:^(BOOL finished) {
                
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            sourceIndexPath = nil;
            break;
        }
    }// switch
}

// Returns a customized snapshot of a given view.
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    if ([inputView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        UIView *snapshot = [inputView performSelector:@selector(snapshotViewAfterScreenUpdates:)
                                           withObject:[NSNumber numberWithBool:YES]];
        snapshot.layer.masksToBounds = NO;
        snapshot.layer.cornerRadius = 0.0;
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        snapshot.layer.shadowRadius = 5.0;
        snapshot.layer.shadowOpacity = 0.4;
        return snapshot;
    } else {
        UIGraphicsBeginImageContext(inputView.bounds.size);
        [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        return [[UIImageView alloc] initWithImage:image];
    }
    
}

- (void)toogleMark:(UITapGestureRecognizer*)sender
{
    UITableViewCell* cell = [self parentCellFor:sender.view];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    PFObject* task = [self objectAtIndexPath:indexPath];
    
    if ([task[@"status"] isEqualToString:@"Done"])
        return;
    
    BOOL markNewValue = ![[task objectForKey:@"Mark"] boolValue];
    [task setObject:[NSNumber numberWithBool:markNewValue] forKey:@"Mark"];
    //sender.selected = markNewValue;
    [task saveInBackground];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
}

#pragma mark -
#pragma mark Parse Table Controller Methods

-(void) objectsWillLoad
{
    //[self.data removeAllObjects];
    [super objectsWillLoad];
    NSLog(@"Object will load");
}

-(void)objectsDidLoad:(NSError *)error
{
    if (!error) {
        self.data = [NSMutableArray arrayWithArray:self.objects];
        NSLog(@"objectDidLoad %i", self.data.count);
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    [super objectsDidLoad:error];
}

-(PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"objectAtIndexPath %i", indexPath.row);
    if(indexPath.row >= self.data.count)
        return nil;
    else
        return [self.data objectAtIndex:indexPath.row];
}

#pragma mark -
#pragma mark Table View Data Source Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self isLoading]) {
        NSLog(@"loading...");
        return 0;
    }
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isLoading]) {
        NSLog(@"loading");
        return 0;
    }
    NSLog(@"numberOfRowsInSection %i", self.data.count);
    return self.data.count;
}


- (PFTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"task"];
    UITextField* titleField = [cell viewWithTag:10];
    titleField.text = [object objectForKey:@"Title"];
    titleField.delegate = self;
    NSString* status = [object objectForKey:@"Status"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UIImageView* imageView = cell.imageView;
    
    if (!cell.imageView.image) {
        UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(toogleMark:)];
        [cell.imageView addGestureRecognizer:tapGesture];
        cell.imageView.frame = CGRectMake(70, cell.imageView.frame.origin.y, 22, 22);
    }
    
    if ([status isEqualToString:@"Done"]) {
        cell.imageView.image  = [UIImage imageNamed:@"completeTask"];
        cell.imageView.userInteractionEnabled = NO;
    } else {
        cell.imageView.userInteractionEnabled = YES;
        if([[object objectForKey:@"Mark"] boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"targetedTask"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"task"];
        }
    }
    
    return cell;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = self.data[indexPath.row];
        [object deleteEventually];
        [self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    }
}

/*- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}*/

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.data exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];

    int i = 0;
    for (PFObject* task in self.data) {
        [task setObject:[NSNumber numberWithInt:i++ ] forKey:self.orderColumn];
    }
    [PFObject saveAllInBackground:self.data];
}


#pragma mark -
#pragma mark Table View Delegate Methods

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField* titleField = (UITextField*)[cell viewWithTag:10];
    //titleField.enabled = NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField* titleField = (UITextField*)[cell viewWithTag:10];
    //titleField.enabled = YES;
    if(activeTextField){
        [activeTextField resignFirstResponder];
    }
}

#pragma mark -
#pragma mark TextFieldDelegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell* cell = [self parentCellFor:textField];
    if (cell)
    {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        activeTextField = textField;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell* cell = [self parentCellFor:textField];
    if (cell)
    {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        [self textFieldDidEndEditing:textField inRowAtIndexPath:indexPath];
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        textField.enabled = NO;
        activeTextField = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (UITableViewCell*)parentCellFor:(UIView*)view
{
    if (!view)
        return nil;
    if ([view isKindOfClass:[UITableViewCell class]])
        return (UITableViewCell*)view;
    return [self parentCellFor:view.superview];
}

- (void)textFieldDidEndEditing:(UITextField*)textField inRowAtIndexPath:(NSIndexPath*)indexPath;
{
    PFObject* task = [self objectAtIndexPath:indexPath];
    [task setObject:textField.text forKey:@"Title"];
    [task saveInBackground];
}

@end
