//
//  LoggingModule.h
//  IDwallToolkit
//
//  Created by Guilherme Horcaio Paciulli on 31/03/20.
//  Copyright © 2020 IDwall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LogginLevels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoggingModule : NSObject
+(void)log:(NSString*) value withLevel:(LoggingLevel) level;
+(void)setLoggingLevel:(LoggingLevel) level;
@end

NS_ASSUME_NONNULL_END
