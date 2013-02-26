//
//  PPRemindersViewController.m
//  Progress
//
//  Created by Kyle Fang on 2/25/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import "PPRemindersViewController.h"
#import "PPEvenKitManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <UIScrollView+ZGPullDrag.h>
#import <NUI/NUIConverter.h>
#import <NUI/NUIGraphics.h>
#import "ReminderItemCell.h"

@interface PPRemindersViewController () <ReminderItemCellDelegate, ZGPullDragViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *pullDownView;
@property (nonatomic, strong) UITableViewCell *placeHolderCell;
@property (nonatomic) NSArray *remindersDatasource;
@end

@implementation PPRemindersViewController

static NSString *CellIdentifier = @"ReminderCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationController.navigationBarHidden = YES;
    
    [self.tableView registerClass:[ReminderItemCell class] forCellReuseIdentifier:CellIdentifier];
    
    [SVProgressHUD show];
    NSString *defaultReminderIdentifier = [[PPEvenKitManager sharedManager] defaultReminderListIdentifier];
    [[PPEvenKitManager sharedManager] getReminderItemsInListWithIdentifier:defaultReminderIdentifier includeCompleted:YES includeImcompleted:YES withCompletionBlock:^(NSArray *reminedrItems) {
        self.remindersDatasource = reminedrItems;
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        
        [self.tableView addZGPullView:self.placeHolderCell];
        
        UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.tableView.rowHeight)];
        dragView.backgroundColor = [UIColor greenColor];
        [self.tableView addZGDragView:dragView];
        self.tableView.pullDragDelegate = self;
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - Pull

- (UITableViewCell *)placeHolderCell{
    if (!_placeHolderCell) {
        _placeHolderCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        _placeHolderCell.frame = CGRectMake(0, 0, self.view.frame.size.width, self.tableView.rowHeight);
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 29, 300, 21)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:17.0];
        textField.tag = 1;
        [_placeHolderCell addSubview:textField];
    }
    return _placeHolderCell;
}

- (void)pullView:(UIView *)pullView hangForCompletionBlock:(void (^)())completed{
    [[self.placeHolderCell viewWithTag:1] becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.remindersDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderItemCell *cell = [[ReminderItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    EKReminder *reminder = [self.remindersDatasource objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.textLabel.text = reminder.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    cell.accessoryType = reminder.completed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

#pragma mark - ReminderCell Delegate

- (void)completedByTheUser:(ReminderItemCell *)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    EKReminder *reminder = [self.remindersDatasource objectAtIndex:indexPath.row];
    sender.accessoryType = reminder.completed ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    reminder.completed = !reminder.completed;
    [[PPEvenKitManager sharedManager] saveReminder:reminder];
}

- (void)deletedByTheUser:(ReminderItemCell *)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    EKReminder *reminder = [self.remindersDatasource objectAtIndex:indexPath.row];
    NSMutableArray *mutableDataSource = [self.remindersDatasource mutableCopy];
    [mutableDataSource removeObjectAtIndex:indexPath.row];
    self.remindersDatasource = mutableDataSource;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[PPEvenKitManager sharedManager] deleteReminder:reminder];
}

@end
