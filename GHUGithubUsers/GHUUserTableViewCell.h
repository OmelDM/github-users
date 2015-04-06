//
//  GHUUserTableViewCell.h
//  GHUGithubUsers
//
//  Created by Dmytro Omelchuk on 4/6/15.
//  Copyright (c) 2015 Dmytro Omelchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHULinkButton;

@interface GHUUserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foto;
@property (weak, nonatomic) IBOutlet UILabel *login;
@property (weak, nonatomic) IBOutlet GHULinkButton *link;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;

@end
