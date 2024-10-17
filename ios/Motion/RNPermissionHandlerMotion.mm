#import "RNPermissionHandlerMotion.h"

#import <CoreMotion/CoreMotion.h>

@interface RNPermissionHandlerMotion()

@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation RNPermissionHandlerMotion

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSMotionUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.MOTION";
}

- (RNPermissionStatus)currentStatus {
  if (![CMMotionActivityManager isActivityAvailable]) {
    return RNPermissionStatusNotAvailable;
  }

  switch ([CMMotionActivityManager authorizationStatus]) {
    case CMAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case CMAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case CMAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case CMAuthorizationStatusAuthorized:
      return RNPermissionStatusAuthorized;
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CMMotionActivityManager isActivityAvailable]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  _activityManager = [CMMotionActivityManager new];
  _operationQueue = [NSOperationQueue new];
  _operationQueue.maxConcurrentOperationCount = 1;

  NSDate *now = [NSDate new];

  [_activityManager queryActivityStartingFromDate:now
                                           toDate:now
                                          toQueue:_operationQueue
                                      withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
    if (error != nil && error.code != CMErrorNotAuthorized && error.code != CMErrorMotionActivityNotAuthorized) {
      return reject(error);
    }

    if (error != nil) {
      return resolve(RNPermissionStatusDenied);
    }
    if (activities) {
      return resolve(RNPermissionStatusAuthorized);
    }

    return resolve(RNPermissionStatusNotDetermined);
  }];
}

@end