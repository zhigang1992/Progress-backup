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
#import "ReminderItemCell.h"

@interface PPRemindersViewController () <ReminderItemCellDelegate>
@property (nonatomic) NSArray *remindersDatasource;
@end

@implementation PPRemindersViewController

static NSString *CellIdentifier = @"ReminderCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    return [[UIView alloc] init];
//}
//
//- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 1;
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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
