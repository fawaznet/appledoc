//
//  GBCategoryData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBCategoryData.h"

@implementation GBCategoryData

#pragma mark Initialization & disposal

+ (id)categoryDataWithName:(NSString *)name className:(NSString *)className {
	return [[[self alloc] initWithName:name className:className] autorelease];
}

- (id)initWithName:(NSString *)name className:(NSString *)className {
	NSParameterAssert(className && [className length] > 0);
	GBLogDebug(@"Initializing category %@ for class %@...", name, className);
	self = [super init];
	if (self) {
		_categoryName = name ? [name copy] : nil;
		_className = [className copy];
		_adoptedProtocols = [[GBAdoptedProtocolsProvider alloc] init];
		_methods = [[GBMethodsProvider alloc] initWithParentObject:self];
	}
	return self;
}

#pragma mark Overriden methods

- (void)mergeDataFromObject:(id)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging data from implementation...", self);
	NSParameterAssert([[source nameOfClass] isEqualToString:self.nameOfClass]);
	NSParameterAssert([source nameOfCategory] == self.nameOfCategory || [[source nameOfCategory] isEqualToString:self.nameOfCategory]); // allow nil for extensions!
	[super mergeDataFromObject:source];
	
	// Forward merging request to components.
	GBCategoryData *sourceCategory = (GBCategoryData *)source;	
	[self.adoptedProtocols mergeDataFromProtocolsProvider:sourceCategory.adoptedProtocols];
	[self.methods mergeDataFromMethodsProvider:sourceCategory.methods];
}

- (NSString *)description {
	return self.categoryID;
}

#pragma mark Properties

- (BOOL)isExtension {
	return ([self nameOfCategory] == nil);
}

- (NSString *)categoryID {
	if (self.isExtension) return [NSString stringWithFormat:@"%@()", self.nameOfClass];
	return [NSString stringWithFormat:@"%@(%@)", self.nameOfClass, self.nameOfCategory];
}

@synthesize nameOfCategory = _categoryName;
@synthesize nameOfClass = _className;
@synthesize adoptedProtocols = _adoptedProtocols;
@synthesize methods = _methods;

@end
