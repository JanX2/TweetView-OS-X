//
//  TweetViewAppDelegate.h
//  TweetView
//
//  Created by Mike Rundle on 12/2/10.
//
//  My license: do whatever you want with this code, you don't have to give me credit. It might
//  blow up or set your computer on fire so it's provided AS IS.

#import <Cocoa/Cocoa.h>

@interface TweetViewAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate> {
}

@property (weak) IBOutlet NSWindow *window;

- (NSArray *)scanStringForLinks:(NSString *)string;
- (NSArray *)scanStringForUsernames:(NSString *)string;
- (NSArray *)scanStringForHashtags:(NSString *)string;

@end
