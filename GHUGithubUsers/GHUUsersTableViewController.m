//
//  GHUUsersTableViewController.m
//  GHUGithubUsers
//
//  Created by Dmytro Omelchuk on 4/6/15.
//  Copyright (c) 2015 Dmytro Omelchuk. All rights reserved.
//

#import "GHUUsersTableViewController.h"
#import "GHUUserTableViewCell.h"

NSString *const kGithubUsersLink = @"https://api.github.com/users";

@interface GHUUsersTableViewController ()

@property (nonatomic, strong) NSArray *users;

@end

@implementation GHUUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:kGithubUsersLink]
				completionHandler:^(NSData *aData, NSURLResponse *aResponse, NSError *anError)
	{
		if (nil != anError)
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				[[[UIAlertView alloc] initWithTitle:@"Download error" message:anError.localizedDescription
							delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			});
			return;
		}
		
		if (nil != aData && 200 == [(NSHTTPURLResponse *)aResponse statusCode])
		{
			NSError *theError = nil;
			self.users = [NSJSONSerialization JSONObjectWithData:aData options:0 error:&theError];
			
			if (nil == self.users)
			{
				dispatch_async(dispatch_get_main_queue(),
				^{
					[[[UIAlertView alloc] initWithTitle:@"Parsing error" message:theError.localizedDescription
								delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
				});
				return;
			}
			
			dispatch_async(dispatch_get_main_queue(),
			^{
				[self.tableView reloadData];
			});
		}
		else
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Unexpected error"
							delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			});
		}
		
	}] resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)aSection
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    GHUUserTableViewCell *theCell = [aTableView dequeueReusableCellWithIdentifier:@"UserCellReuseIdentifier" forIndexPath:anIndexPath];

	NSDictionary *theUser = self.users[anIndexPath.row];
	
	theCell.login.text = theUser[@"login"];
	theCell.link.text = theUser[@"html_url"];
	[theCell.downloadIndicator startAnimating];
	
	[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:theUser[@"avatar_url"]]
				completionHandler:^(NSData *aData, NSURLResponse *aResponse, NSError *anError)
	{
		if (nil != anError)
		{
		
		}
		
		UIImage *theFoto = [UIImage imageWithData:aData];
		
		if (nil != theFoto)
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				theCell.foto.image = theFoto;
				[theCell.downloadIndicator stopAnimating];
				theCell.downloadIndicator.hidden = YES;
			});
		}
		
	}] resume];
	
    return theCell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
