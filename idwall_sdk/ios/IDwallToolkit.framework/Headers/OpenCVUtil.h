//
//  OpenCVUtil.h
//  IDwallToolkit
//
//  Created by Miguel Pari Soto on 28/08/18.
//  Updated 06/01/22
//  Copyright © IDwall. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IqConfigs;
@class IqResult;

@interface OpenCVUtils : NSObject

+ (void)activateFullLogs:(bool)full;                    // for activate/deactivate full loggings
                                                        //
+ (short)setConfigs:(IqConfigs*)confs;                  // uses default configs
                                                        //
+ (void)getImageQuality:(UIImage **)imageIO             // input/output: image
              andResult:(IqResult*)result;              // result output (metrics and flags)

@end
