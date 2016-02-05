//
//  TweetViewAppDelegate.m
//  TweetView
//
//  Created by Mike Rundle on 12/2/10.
//
//  My license: do whatever you want with this code, you don't have to give me credit. It might
//  blow up or set your computer on fire so it's provided AS IS.

#import "TweetViewAppDelegate.h"
#import "TVTextView.h"
#import "RegexKitLite.h"

@implementation TweetViewAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (void)awakeFromNib {
	NSString *statusString = @"Example tweet text here. Don't you just love AppKit? Here's a reference to @flyosity. Check out this cool new site: http://apple.com #hashtag #tutorial";
	
	// Rect inset from the contentView to put our textview
	NSRect insetRect = NSInsetRect([[self.window contentView] bounds], 30, 30);
	
	// Building up our attributed string
	NSMutableAttributedString *attributedStatusString = [[NSMutableAttributedString alloc] initWithString:statusString];
	
	// Defining our paragraph style for the tweet text. Starting with the shadow to make the text
	// appear inset against the gray background.
	NSShadow *textShadow = [[NSShadow alloc] init];
	[textShadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:.8]];
	[textShadow setShadowBlurRadius:0];
	[textShadow setShadowOffset:NSMakeSize(0, -1)];
							 
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setMinimumLineHeight:22];
	[paragraphStyle setMaximumLineHeight:22];
	[paragraphStyle setParagraphSpacing:0];
	[paragraphStyle setParagraphSpacingBefore:0];
	[paragraphStyle setTighteningFactorForTruncation:4];
	[paragraphStyle setAlignment:NSNaturalTextAlignment];
	[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
	
	// Our initial set of attributes that are applied to the full string length
	NSDictionary *fullAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSColor colorWithDeviceHue:.53 saturation:.13 brightness:.26 alpha:1], NSForegroundColorAttributeName,
									textShadow, NSShadowAttributeName,
									[NSCursor arrowCursor], NSCursorAttributeName,
									[NSNumber numberWithFloat:0.0], NSKernAttributeName,
									[NSNumber numberWithInt:0], NSLigatureAttributeName,
									paragraphStyle, NSParagraphStyleAttributeName,
									[NSFont systemFontOfSize:14.0], NSFontAttributeName, nil];
	[attributedStatusString addAttributes:fullAttributes range:NSMakeRange(0, [statusString length])];
	[textShadow release];
	[paragraphStyle release];
		
	// Generate arrays of our interesting items. Links, usernames, hashtags.
	NSArray *linkMatches = [self scanStringForLinks:statusString];
	NSArray *usernameMatches = [self scanStringForUsernames:statusString];
	NSArray *hashtagMatches = [self scanStringForHashtags:statusString];
	
	// Iterate across the string matches from our regular expressions, find the range
	// of each match, add new attributes to that range	
	for (NSString *linkMatchedString in linkMatches) {
		NSRange range = [statusString rangeOfString:linkMatchedString];
		if( range.location != NSNotFound ) {
			// Add custom attribute of LinkMatch to indicate where our URLs are found. Could be blue
			// or any other color.
			NSDictionary *linkAttr = [[NSDictionary alloc] initWithObjectsAndKeys:
									  [NSCursor pointingHandCursor], NSCursorAttributeName,
									  [NSColor blueColor], NSForegroundColorAttributeName,
									  [NSFont boldSystemFontOfSize:14.0], NSFontAttributeName,
									  linkMatchedString, @"LinkMatch",
									  nil];
			[attributedStatusString addAttributes:linkAttr range:range];
			[linkAttr release];
		}
	}
	
	for (NSString *usernameMatchedString in usernameMatches) {
		NSRange range = [statusString rangeOfString:usernameMatchedString];
		if( range.location != NSNotFound ) {
			// Add custom attribute of UsernameMatch to indicate where our usernames are found
			NSDictionary *linkAttr2 = [[NSDictionary alloc] initWithObjectsAndKeys:
									   [NSColor blackColor], NSForegroundColorAttributeName,
									   [NSCursor pointingHandCursor], NSCursorAttributeName,
									   [NSFont boldSystemFontOfSize:14.0], NSFontAttributeName,
									   usernameMatchedString, @"UsernameMatch",
									   nil];
			[attributedStatusString addAttributes:linkAttr2 range:range];
			[linkAttr2 release];
		}
	}
	
	for (NSString *hashtagMatchedString in hashtagMatches) {
		NSRange range = [statusString rangeOfString:hashtagMatchedString];
		if( range.location != NSNotFound ) {
			// Add custom attribute of HashtagMatch to indicate where our hashtags are found
			NSDictionary *linkAttr3 = [[NSDictionary alloc] initWithObjectsAndKeys:
									  [NSColor grayColor], NSForegroundColorAttributeName,
									  [NSCursor pointingHandCursor], NSCursorAttributeName,
									  [NSFont systemFontOfSize:14.0], NSFontAttributeName,
									  hashtagMatchedString, @"HashtagMatch",
									  nil];
			[attributedStatusString addAttributes:linkAttr3 range:range];
			[linkAttr3 release];
		}
	}
	
	// At this point our attributed string has a style for the entire thing, plus attributes
	// added that surround the interesting parts, namely, URLs, usernames and hashtags. These
	// each have a pointing hand cursor style and a custom attribute name that we can look at
	// when a user clicks down on the region occupied by the upcoming NSTextView subclass
	// that will draw our attributed string.
	
	// Initialize the custom text view, set its myriad settings.
	TVTextView *statusView = [[TVTextView alloc] initWithFrame:insetRect];
	[statusView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	[statusView setBackgroundColor:[NSColor clearColor]];
	[statusView setTextContainerInset:NSZeroSize];
	[[statusView textStorage] setAttributedString:attributedStatusString];
	[statusView setEditable:NO];
	[statusView setSelectable:YES];
	
	// Add to window and we're done.
	[[self.window contentView] addSubview:statusView];
	[statusView release];
	
	[attributedStatusString release];
}

#pragma mark -
#pragma mark String parsing

// These regular expressions aren't the greatest. There are much better ones out there to parse URLs, @usernames
// and hashtags out of tweets. Getting the escaping just right is a pain in the ass, so be forewarned.

- (NSArray *)scanStringForLinks:(NSString *)string {
	return [string componentsMatchedByRegex:@"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))"];
}

- (NSArray *)scanStringForUsernames:(NSString *)string {
	return [string componentsMatchedByRegex:@"@{1}([-A-Za-z0-9_]{2,})"];
}

- (NSArray *)scanStringForHashtags:(NSString *)string {
	return [string componentsMatchedByRegex:@"[\\s]{1,}#{1}([^\\s]{2,})"];
}

@end
