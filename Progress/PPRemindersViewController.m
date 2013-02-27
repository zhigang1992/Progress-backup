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
#import "GVUserDefaults+Progress.h"
#import <PaperFold/FoldView.h>

typedef NSUInteger ZGScrollViewStyle;

@interface PPRemindersViewController () <ReminderItemCellDelegate, ZGPullDragViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *pullDownView;
@property (nonatomic, strong) UITableViewCell *placeHolderCell;
@property (nonatomic) BOOL isEdingAReminder;
@property (nonatomic) NSMutableArray *remindersDatasource;
@property (nonatomic) CGFloat pullViewShowRadio;
@property (nonatomic) CGFloat dragViewShowRadio;
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
    [[PPEvenKitManager sharedManager] getReminderItemsInListWithIdentifier:defaultReminderIdentifier includeCompleted:![GVUserDefaults standardUserDefaults].hideCompleted includeImcompleted:YES withCompletionBlock:^(NSArray *reminedrItems) {
        self.remindersDatasource = [reminedrItems mutableCopy];
        [self sortReminders];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        
//        [self.tableView addZGPullView:self.placeHolderCell];
        FoldView *pullView = [[FoldView alloc] initWithFrame:self.placeHolderCell.frame foldDirection:FoldDirectionVertical];
        [pullView unfoldViewToFraction:0];
        [self.tableView addZGPullView:pullView];
        
        UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        dragView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:dragView.frame];
        label.nuiClass = @"WhiteLabel";
        [label applyNUI];
        label.text = [GVUserDefaults standardUserDefaults].hideCompleted ? @"Show Completed" : @"Hide Completed";
        label.tag = 1;
        [dragView addSubview:label];
        [self.tableView addZGDragView:dragView];
        self.tableView.pullDragDelegate = self;
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pull And Drag

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

- (void)setIsEdingAReminder:(BOOL)isEdingAReminder{
    if (isEdingAReminder != _isEdingAReminder) {
        _isEdingAReminder = isEdingAReminder;
        
        if (isEdingAReminder) {
            [UIView animateWithDuration:0.2 animations:^{
                self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
            } completion:^(BOOL finished) {
                CGPoint offSet = self.tableView.contentOffset;
                [self.tableView reloadData];
                offSet.y += 80;
                [self.tableView setContentOffset:offSet animated:NO];
                [self.tableView setContentInset:UIEdgeInsetsZero];
            }];
        }
    }
}

- (void)pullView:(UIView *)pullView Show:(CGFloat)shownPixels ofTotal:(CGFloat)totalPixels{
    self.pullViewShowRadio = shownPixels/totalPixels;
    CGFloat pullProgress = MAX(0, MIN(1, shownPixels/totalPixels));
    pullView.alpha = pullProgress;
    FoldView *fView = (FoldView *)pullView;
    [fView unfoldViewToFraction:pullProgress];
}

- (void)dragView:(UIView *)dragView Show:(CGFloat)showPixels ofTotal:(CGFloat)totalPixels{
    CGFloat dragProgress = MAX(0, MIN(1, showPixels/totalPixels));
    dragView.alpha = dragProgress;
    if (self.dragViewShowRadio <= 1 && showPixels/totalPixels >= 1 && showPixels/totalPixels > self.dragViewShowRadio) {
        UILabel *label = (UILabel *)[dragView viewWithTag:1];
        label.text = [GVUserDefaults standardUserDefaults].hideCompleted ? @"Release to Show Completed" : @"Release to Hide Completed";
    } else if (self.dragViewShowRadio >= 1 && showPixels/totalPixels <= 1 && showPixels/totalPixels < self.dragViewShowRadio) {
        UILabel *label = (UILabel *)[dragView viewWithTag:1];
        label.text = [GVUserDefaults standardUserDefaults].hideCompleted ? @"Show Completed" : @"Hide Completed";
    }
    self.dragViewShowRadio = showPixels/totalPixels;
}

- (void)userPullOrDragStoppedWithPullView:(UIView *)pullView dragView:(UIView *)dragView{
    if (self.pullViewShowRadio > 1) {
        if (!self.isEdingAReminder) {
            self.isEdingAReminder = YES;
        } else {
            UITableViewCell *editingCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            UITextField *editingTextField = (UITextField *)[editingCell viewWithTag:6];
            if (editingTextField.text && ![editingTextField.text isEqualToString:@""]) {
                EKReminder *newReminder = [[PPEvenKitManager sharedManager] createReminderWithTitle:editingTextField.text];
                [self.remindersDatasource insertObject:newReminder atIndex:0];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        self.pullDownView = 0;
    }
    
    if (self.dragViewShowRadio > 1) {
        BOOL hideCompleted = [GVUserDefaults standardUserDefaults].hideCompleted;
        
        [[PPEvenKitManager sharedManager] getReminderItemsInListWithIdentifier:[[PPEvenKitManager sharedManager] defaultReminderListIdentifier] includeCompleted:hideCompleted includeImcompleted:YES withCompletionBlock:^(NSArray *reminedrItems) {

            [UIView animateWithDuration:1.0 animations:^{
                self.remindersDatasource = [NSMutableArray array];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
                self.remindersDatasource = [reminedrItems mutableCopy];
                [self sortReminders];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [GVUserDefaults standardUserDefaults].hideCompleted = !hideCompleted;
                UILabel *label = (UILabel *)[dragView viewWithTag:1];
                label.text = [GVUserDefaults standardUserDefaults].hideCompleted ? @"Show Completed" : @"Hide Completed";
                self.dragViewShowRadio = 0;
            }];
        }];
    }
}

#pragma mark - UITextFeild Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (!textField.text || [textField.text isEqualToString:@""]) {
        self.isEdingAReminder = NO;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        EKReminder *newReminder = [[PPEvenKitManager sharedManager] createReminderWithTitle:textField.text];
        [self.remindersDatasource insertObject:newReminder atIndex:0];
        self.isEdingAReminder = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isEdingAReminder ? self.remindersDatasource.count+1 : self.remindersDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEdingAReminder && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:17.f];
        textField.delegate = self;
        textField.text = @"";
        textField.tag = 6;
        [cell addSubview:textField];
        textField.frame = CGRectMake(10, 29, 300, 21);
        [textField becomeFirstResponder];
        return cell;
    } else {
        ReminderItemCell *cell = [[ReminderItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        EKReminder *reminder = [self.remindersDatasource objectAtIndex:self.isEdingAReminder?indexPath.row-1:indexPath.row];
        cell.delegate = self;
        cell.textLabel.text = reminder.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
        cell.accessoryType = reminder.completed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

        if (self.isEdingAReminder) {
            cell.contentView.alpha = 0.4;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else {
            cell.contentView.alpha = 1;
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
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
    if (indexPath.row +1 < self.remindersDatasource.count && reminder.completed) {
        [self.remindersDatasource removeObject:reminder];
        [self.remindersDatasource addObject:reminder];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:self.remindersDatasource.count-1 inSection:0]];
    } else if (indexPath.row > 0 && !reminder.completed) {
        [self.remindersDatasource removeObject:reminder];
        [self.remindersDatasource insertObject:reminder atIndex:0];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (void)deletedByTheUser:(ReminderItemCell *)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    EKReminder *reminder = [self.remindersDatasource objectAtIndex:indexPath.row];
    [self.remindersDatasource removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[PPEvenKitManager sharedManager] deleteReminder:reminder];
}


#pragma mark - Sort Reminders
- (void)sortReminders{
    NSSortDescriptor *sortWithCompleted = [[NSSortDescriptor alloc] initWithKey:@"completed"
                                                  ascending:YES];
    NSSortDescriptor *sortWithID = [[NSSortDescriptor alloc] initWithKey:@"calendarItemIdentifier" ascending:YES];
    self.remindersDatasource = [[self.remindersDatasource sortedArrayUsingDescriptors:@[sortWithCompleted, sortWithID]] mutableCopy];
}

@end
