//
//  ProfileViewController.m
//  Twitter Wall
//
//  Created by Nick Meinhold on 16/02/13.
//  Copyright (c) 2013 NPENPI. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize username;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [profileImageView.layer setBorderWidth:4.0f];
    [profileImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [profileImageView.layer setShadowRadius:3.0];
    [profileImageView.layer setShadowOpacity:0.5];
    [profileImageView.layer setShadowOffset:CGSizeMake(1.0, 0.0)];
    [profileImageView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    
    [self getInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getInfo
{
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                // https://api.twitter.com/1.1/users/show.json
                // parameters:[NSDictionary dictionaryWithObject:username forKey:@"screen_name"]
                
                NSDictionary *params = @{@"q" : @"imgur",
                                         @"geocode" : @"37.781157,-122.398720,1mi",
                                         @"count" : @"20"};
                // twitpic,yfrog,imgur,tweetphoto,plixi 
                
                //https://stream.twitter.com/1.1/statuses/sample.json
                // Creating a request to get the info about a user on Twitter
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"] parameters:params];
                //SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:username forKey:@"screen_name"]];
                [twitterInfoRequest setAccount:twitterAccount];
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit 
                        if ([urlResponse statusCode] == 429) { 
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            //NSLog(@"%@", TWData);
                            NSArray* statuses = [(NSDictionary *)TWData objectForKey:@"statuses"];
                            for(NSDictionary* dict in statuses) {
                                NSLog(@"Screen Name: %@", [[dict objectForKey:@"user"] objectForKey:@"screen_name"]);
                                NSLog(@"Tweet text: %@", [dict objectForKey:@"text"]);
                                NSArray *urlsArray = [[dict objectForKey:@"entities"] objectForKey:@"urls"];
                                if([urlsArray count] > 0) {
                                    NSLog(@"Entity URL: %@", [[urlsArray objectAtIndex:0] objectForKey:@"url"]);
                                    NSLog(@"Entity Display URL: %@", [[urlsArray objectAtIndex:0] objectForKey:@"display_url"]);
                                    NSLog(@"Entity Expanded URL: %@", [[urlsArray objectAtIndex:0] objectForKey:@"expanded_url"]);
                                }
                                
                            }
                            //NSLog(@"Item: %@", [[TWData objectAtIndex: 0] objectForKey: @"statuses"]);
//                            for(NSDictionary *item in TWData) {
//                                NSLog(@"Item: %@", item);
//                            }
                            // Filter the preferred data
                            NSString *screen_name = [(NSDictionary *)TWData objectForKey:@"screen_name"];
                            NSString *name = [(NSDictionary *)TWData objectForKey:@"name"];
                            int followers = [[(NSDictionary *)TWData objectForKey:@"followers_count"] integerValue];
                            int following = [[(NSDictionary *)TWData objectForKey:@"friends_count"] integerValue];
                            int tweets = [[(NSDictionary *)TWData objectForKey:@"statuses_count"] integerValue];
                            NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                            NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                            // Update the interface with the loaded data
                            nameLabel.text = name;
                            usernameLabel.text= [NSString stringWithFormat:@"@%@",screen_name];
                            tweetsLabel.text = [NSString stringWithFormat:@"%i", tweets];
                            followingLabel.text= [NSString stringWithFormat:@"%i", following];
                            followersLabel.text = [NSString stringWithFormat:@"%i", followers];
                            NSString *lastTweet = [[(NSDictionary *)TWData objectForKey:@"status"] objectForKey:@"text"];
                            lastTweetTextView.text= lastTweet;
                            // Get the profile image in the original resolution
                            profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            [self getProfileImageForURLString:profileImageStringURL];
                            // Get the banner image, if the user has one
                            if (bannerImageStringURL) {
                                NSString *bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerImageStringURL];
                                [self getBannerImageForURLString:bannerURLString];
                            } else {
                                bannerImageView.backgroundColor = [UIColor underPageBackgroundColor];
                            }
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

- (void) getProfileImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    profileImageView.image = [UIImage imageWithData:data];
}

- (void) getBannerImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    bannerImageView.image = [UIImage imageWithData:data];
}

@end
