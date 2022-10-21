//
//  IDwallToolkitFlow.h
//  IDwallToolkit
//
//  Created by IDwall on 22/08/2018.
//  Copyright © 2018 IDwall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IDwallToolkit/IDwallDocumentType.h>

typedef void (^IDwallToolkitFlowResult) ( NSDictionary* _Nullable  jsonData,  NSError* _Nullable error);
typedef void (^IDwallToolkitImageResult) (bool success,  NSError* _Nullable  error);
typedef void (^IDwallToolkitSendResult) ( NSDictionary* _Nullable  jsonData,  NSError* _Nullable error);

@interface IDwallToolkitFlow : NSObject

+ (instancetype _Nonnull)sharedInstance;

- (void)startCompleteFlowWithDocument:(IDwallDocumentType) documentType andCallBack: (IDwallToolkitFlowResult _Nullable) callback;
- (void)startFaceFlowWithCallBack: (IDwallToolkitFlowResult _Nullable) callback;
- (void)startDocumentFlowWithDocumentType:(IDwallDocumentType) documentType andCallBack: (IDwallToolkitFlowResult _Nullable) callback;
- (void)sendAllDataWithCallBack: (IDwallToolkitFlowResult _Nullable) callback;

@end
