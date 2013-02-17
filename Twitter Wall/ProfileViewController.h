//
//  ProfileViewController.h
//  Twitter Wall
//
//  Created by Nick Meinhold on 16/02/13.
//  Copyright (c) 2013 NPENPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

@interface ProfileViewController : UIViewController
{
    
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIImageView *bannerImageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *tweetsLabel;
    IBOutlet UILabel *followingLabel;
    IBOutlet UILabel *followersLabel;
    IBOutlet UITextView *lastTweetTextView;
    NSString *username;
    
}

@property (nonatomic, retain) NSString *username;

@end
