//
//  GHUUsersTableViewController.m
//  GHUGithubUsers
//
//  Created by Dmytro Omelchuk on 4/6/15.
//  Copyright (c) 2015 Dmytro Omelchuk. All rights reserved.
//

#import "GHUUsersTableViewController.h"
#import "GHUUserTableViewCell.h"
#import "GHULinkButton.h"
#import "GHUBigFotoViewController.h"

NSString *const kGithubUsersLink = @"https://api.github.com/users";

@interface GHUUsersTableViewController ()

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation GHUUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.cache = [NSMutableDictionary new];
	
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
	NSString *theLink = theUser[@"html_url"];
	[theCell.link setTitle:theLink forState:UIControlStateNormal];
	theCell.link.link = [NSURL URLWithString:theLink];

	[theCell.downloadIndicator startAnimating];
	
	NSString *theAvatarLink = theUser[@"avatar_url"];
	NSString *thePathToAvatar = self.cache[theAvatarLink];
	
	if (nil != thePathToAvatar)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		^{
			UIImage *theAvatar = [UIImage imageNamed:@"Image_Placeholder"];
			NSData *theAvatarData = [NSData dataWithContentsOfFile:thePathToAvatar];
			
			if (nil != theAvatarData)
			{
				UIImage *theAvatarImage = [UIImage imageWithData:theAvatarData];
				if (nil != theAvatarImage)
				{
					theAvatar = theAvatarImage;
				}
			}

			dispatch_async(dispatch_get_main_queue(),
			^{
				[theCell.foto setBackgroundImage:theAvatar forState:UIControlStateNormal];
				[theCell.downloadIndicator stopAnimating];
				theCell.downloadIndicator.hidden = YES;
			});
		});
		
	}
	else
	{
		[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:theAvatarLink]
				completionHandler:^(NSData *aData, NSURLResponse *aResponse, NSError *anError)
		{
			UIImage *theAvatar = [UIImage imageNamed:@"Image_Placeholder"];
			
			if (nil == anError && nil != aData)
			{
				UIImage *theAvatarImage = [UIImage imageWithData:aData];
				if (nil != theAvatarImage)
				{
					theAvatar = theAvatarImage;
					// store to cache
					NSString *theDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
								NSUserDomainMask, YES) lastObject];
					NSString *theStorePath = [theDirectory stringByAppendingFormat:@"/%@/%ld.jpeg",
								[[NSBundle mainBundle] bundleIdentifier], [theAvatarLink hash]];
					
					if ([aData writeToFile:theStorePath atomically:NO])
					{
						[self.cache setObject:theStorePath forKey:theAvatarLink];
					}
				}
			}

			dispatch_async(dispatch_get_main_queue(),
			^{
				[theCell.foto setBackgroundImage:theAvatar forState:UIControlStateNormal];
				[theCell.downloadIndicator stopAnimating];
				theCell.downloadIndicator.hidden = YES;
			});
		}] resume];
	
	}

    return theCell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)aSegue sender:(id)aSender
{
	if ([aSegue.identifier isEqualToString:@"BigFotoSegue"])
	{
		GHUBigFotoViewController *theBigFotoController = aSegue.destinationViewController;
		GHUUserTableViewCell *theCell = (GHUUserTableViewCell *)[[aSender superview] superview];
		UIImage *theImage = [theCell.foto backgroundImageForState:UIControlStateNormal];
		theBigFotoController.foto = theImage;
	}
}


@end
