//
//  IDwallColors.h
//  IDwallToolkit
//
//  Created by Guilherme Horcaio Paciulli on 17/02/20.
//  Copyright © 2020 IDwall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    Light,
    Dark
} UserInterfaceStyle;

typedef enum : NSUInteger {
    SDK,
    Text,
    Success,
    Warning,
    Shadow
} UserInterfaceContext;

typedef enum : NSUInteger {
    Primary,
    Secundary,
    Tertiary,
    Quaternary,
    Background,
    ButtonText
} UserInterfaceColor;


@interface IDwallColors : NSObject

+ (instancetype _Nonnull)sharedInstance;

- (UIColor * _Nonnull)getColor:(UserInterfaceStyle)style
                     atContext:(UserInterfaceContext)context
                      withType:(UserInterfaceColor)type;
- (UIColor* _Nonnull) neutral;

@end
