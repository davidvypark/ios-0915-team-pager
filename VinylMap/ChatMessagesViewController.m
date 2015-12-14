//
//  ChatMessagesViewController.m
//  Firechat
//
//  Copyright (c) 2012 Firebase.
//
//  No part of this project may be copied, modified, propagated, or distributed
//  except according to terms in the accompanying LICENSE file.
//

#import "ChatMessagesViewController.h"
#import "UserObject.h"
#import "VinylColors.h"
#import <Masonry.h>
#import "VinylConstants.h"


@interface ChatMessagesViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomContstraint;
@property (nonatomic, assign) double originalTextFieldBottomConstant;
@property (nonatomic, strong) NSString *currentUser;
@property (nonatomic, strong) NSString *currentUserDisplayName;


@end

@implementation ChatMessagesViewController

@synthesize nameField;
@synthesize textField;
@synthesize tableView;


#pragma mark - Setup

// Initialization.

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Initialize array that will store chat messages.
    self.chat = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor vinylLightGray];
    self.tableView.backgroundColor = [UIColor vinylLightGray];
    
    
    // Initialize the root of our Firebase namespace.
    self.firebase = [[Firebase alloc] initWithUrl:FIREBASE_CHATROOM];
    
    
    self.currentUser = [UserObject sharedUser].firebaseRoot.authData.uid;
    NSString *displayName = [NSString stringWithFormat:@"%@users/%@",FIREBASE_URL, self.currentUser];
    Firebase *displayNameFirebase = [[Firebase alloc] initWithUrl:displayName];
    [displayNameFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.currentUserDisplayName = snapshot.value[@"displayName"];
    }];
    
    nameField.text = self.userToMessageDisplayName;
    self.title   = self.userToMessageDisplayName;
    
    
    // This allows us to check if these were messages already stored on the server
    // when we booted up (YES) or if they are new messages since we've started the app.
    // This is so that we can batch together the initial messages' reloadData for a perf gain.
    __block BOOL initialAdds = YES;
    

    NSString *messagesOfPeopleInChat = [NSString stringWithFormat:@"/%@%@", self.currentUser, self.userToMessage];

    Firebase *userChat = [self.firebase childByAppendingPath:messagesOfPeopleInChat];

    
    [userChat observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {

        // Add the chat message to the array.

            [self.chat addObject:snapshot.value];
               
        // Reload the table view so the new message will show up.
        if (!initialAdds) {
            [self.tableView reloadData];
            [self scrollToBottom];
        }
    }];
    
    [userChat observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        // Reload the table view so that the intial messages show up
        [self.tableView reloadData];
        [self scrollToBottom];
        initialAdds = NO;

    }];
    

    self.originalTextFieldBottomConstant = self.textFieldBottomContstraint.constant;
    

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};

}
-(void)scrollToBottom{
    
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:NO];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Text field handling

// This method is called when the user enters text in the text field.
// We add the chat message to our Firebase.
- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{

    // This will also add the message to our local array self.chat because
    // the FEventTypeChildAdded event will be immediately fired.
    NSString *messageParticipants = [NSString stringWithFormat:@"/%@%@", self.currentUser, self.userToMessage];
    NSString *reversemessageParticipants = [NSString stringWithFormat:@"/%@%@", self.userToMessage, self.currentUser];
    NSString *chatRooms = [NSString stringWithFormat:@"%@users/%@/chatrooms",FIREBASE_URL ,self.currentUser];
    NSString *chatroomsReverse = [NSString stringWithFormat:@"%@users/%@/chatrooms",FIREBASE_URL, self.userToMessage];
    Firebase *chatRoomsFirebase = [[Firebase alloc] initWithUrl:chatRooms];
    Firebase *chatroomsReverseFirebase = [[Firebase alloc] initWithUrl:chatroomsReverse];
    Firebase *chatRoomsRef = [chatRoomsFirebase childByAppendingPath:self.userToMessage];
    [chatRoomsRef setValue:@{@"display" : self.userToMessageDisplayName, @"id" : self.userToMessage, @"time": kFirebaseServerValueTimestamp, @"newest": aTextField.text}];
    Firebase *chatRoomsRefReverse = [chatroomsReverseFirebase childByAppendingPath:self.currentUser];
    [chatRoomsRefReverse setValue:@{@"display" : self.currentUserDisplayName, @"id" : self.currentUser, @"time": kFirebaseServerValueTimestamp, @"newest": aTextField.text}];
    

    Firebase *chatRoomMessages = [self.firebase childByAppendingPath:messageParticipants];
            Firebase *eachMessage = [chatRoomMessages childByAutoId];
            [eachMessage setValue:@{@"name" : self.currentUserDisplayName, @"text": aTextField.text, @"time": kFirebaseServerValueTimestamp}];
    Firebase *reverseChatRoomMessages = [self.firebase childByAppendingPath:reversemessageParticipants];
    Firebase *reverseEachMessage = [reverseChatRoomMessages childByAutoId];
    [reverseEachMessage setValue:@{@"name" : self.currentUserDisplayName, @"text": aTextField.text, @"time": kFirebaseServerValueTimestamp}];
    [aTextField setText:@""];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    Firebase *connectedRef = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/.info/connected"];
    [connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(![snapshot.value boolValue]) {
            NSLog(@"Not Connected");
            UIAlertController *internetAlertController = [UIAlertController
                                                          alertControllerWithTitle:@"You do not currently have network access"
                                                          message:@"Your messages will be sent when you reconnect to a network"
                                                          preferredStyle:UIAlertControllerStyleAlert];
            [internetAlertController addAction:okAction];
            [self presentViewController:internetAlertController animated:YES completion:nil];
        }}];

    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    // We only have one section in our table view.
    return 1;
}

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section
{
    // This is the number of chat messages.
    return [self.chat count];
  
}

// This method changes the height of the text boxes based on how much text there is.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* chatMessage = [self.chat objectAtIndex:indexPath.row];
    
    NSString *text = chatMessage[@"text"];
    
    // typical textLabel.frame = {{10, 30}, {260, 22}}
    const CGFloat TEXT_LABEL_WIDTH = 260;
    CGSize constraint = CGSizeMake(TEXT_LABEL_WIDTH, 20000);
    
    // typical textLabel.font = font-family: "Helvetica"; font-weight: bold; font-style: normal; font-size: 18px

    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping]; // requires iOS 6+
    const CGFloat CELL_CONTENT_MARGIN = 22;
    CGFloat height = MAX(CELL_CONTENT_MARGIN + size.height, 44);
    
    return height;
}

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)index
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.numberOfLines = 0;
    }
    
    NSDictionary* chatMessage = [self.chat objectAtIndex:index.row];

    cell.textLabel.text = chatMessage[@"text"];
    cell.detailTextLabel.text = chatMessage[@"name"];
    
    cell.backgroundColor = [UIColor vinylLightGray];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor vinylBlue];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}


#pragma mark - Keyboard handling

// Subscribe to keyboard show/hide notifications.
- (void)viewWillAppear:(BOOL)animated
    {
[[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
}

// Unsubscribe from keyboard show/hide notifications.
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
        removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewDidLayoutSubviews{
    [self scrollToBottom];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;

    self.textFieldBottomContstraint.constant -= keyboardFrameBeginRect.size.height - tabBarHeight;

}

- (void)keyboardWillHide:(NSNotification*)notification
{
    self.textFieldBottomContstraint.constant = self.originalTextFieldBottomConstant;
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
}


@end
