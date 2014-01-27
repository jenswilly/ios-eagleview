//
//  EAGLEFile.m
//  
//
//  Created by Jens Willy Johannsen on 27/01/14.
//
//

#import "EAGLEFile.h"
#import "EAGLELibrary.h"

@implementation EAGLEFile

- (EAGLELibrary *)libraryWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.libraries filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}

- (NSString*)dateString
{
	// If no date has been set, return an empty string
	if( !self.fileDate )
		return @"";

	// Substitute file's date
	static NSDateFormatter *dateFormatter = nil;
	if( dateFormatter == nil )
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"dd/MM/yy HH.mm";
	}
	return [dateFormatter stringFromDate:self.fileDate];
}

@end
