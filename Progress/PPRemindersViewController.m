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
#import "UIScrollView+ZGPullDrag.h"
#import <NUI/UILabel+NUI.h>
#import "ReminderItemCell.h"

typedef NSUInteger ZGScrollViewStyle;

@interface PPRemindersViewController () <ReminderItemCellDelegate, ZGPullDragViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *pullDownView;
@property (nonatomic, strong) UITableViewCell *placeHolderCell;
@property (nonatomic, strong) UITableViewCell *editingCell;
@property (nonatomic) BOOL isEdingAReminder;
@property (nonatomic) NSArray *remindersDatasource;
@property (nonatomic) CGFloat pullViewShowRadio;
@property (nonatomic) CGFloat xTouchPoint;
@end

@implementation PPRemindersViewController

static NSString *CellIdentifier = @"ReminderCell";



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isEdingAReminder = NO;
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationController.navigationBarHidden = YES;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    [self.tableView registerClass:[ReminderItemCell class] forCellReuseIdentifier:CellIdentifier];
    
    [SVProgressHUD show];
    NSString *defaultReminderIdentifier = [[PPEvenKitManager sharedManager] defaultReminderListIdentifier];
    [[PPEvenKitManager sharedManager] getReminderItemsInListWithIdentifier:defaultReminderIdentifier includeCompleted:YES includeImcompleted:YES withCompletionBlock:^(NSArray *reminedrItems) {
        self.remindersDatasource = reminedrItems;
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        
        [self.tableView addZGPullView:self.placeHolderCell];
        
        UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.tableView.rowHeight)];
        dragView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:dragView.frame];
        label.nuiClass = @"WhiteLabel";
        [label applyNUI];
        label.text = @"Hide Completed";
        label.tag = 1;
        [dragView addSubview:label];
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
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1.f)];
        seperator.backgroundColor = self.tableView.separatorColor;
        [_placeHolderCell addSubview:seperator];
    }
    return _placeHolderCell;
}


- (void)pullView:(UIView *)pullView Show:(CGFloat)shownPixels ofTotal:(CGFloat)totalPixels{
    self.pullViewShowRadio = shownPixels/totalPixels;
    CGFloat pullProgress = MAX(0, MIN(1, shownPixels/totalPixels));
    pullView.alpha = pullProgress;
}

- (void)dragView:(UIView *)dragView Show:(CGFloat)showPixels ofTotal:(CGFloat)totalPixels{
    CGFloat dragProgress = MAX(0, MIN(1, showPixels/totalPixels));
    dragView.alpha = dragProgress;
}

- (void)userPullOrDragStoppedWithPullView:(UIView *)pullView dragView:(UIView *)dragView{
    NSLog(@"Stopped");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isEdingAReminder ? self.remindersDatasource.count+1 : self.remindersDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEdingAReminder && indexPath.row == 0) {
        return self.editingCell;
    } else {
        ReminderItemCell *cell = [[ReminderItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        EKReminder *reminder = [self.remindersDatasource objectAtIndex:self.isEdingAReminder?indexPath.row-1:indexPath.row];
        cell.delegate = self;
        cell.textLabel.text = reminder.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
        cell.accessoryType = reminder.completed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        return cell;
    }
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
