//
//  GHULinkButton.m
//  GHUGithubUsers
//
//  Created by Dmytro Omelchuk on 4/6/15.
//  Copyright (c) 2015 Dmytro Omelchuk. All rights reserved.
//

#import "GHULinkButton.h"

@implementation GHULinkButton

- (void)awakeFromNib
{
	[self addTarget:self action:@selector(openLink:)
				forControlEvents:UIControlEventTouchUpInside];
}

- (void)openLink:(id)aSender
{
	if (nil != self.link)
	{
		[[UIApplication sharedApplication] openURL:self.link];
	}
}

@end
