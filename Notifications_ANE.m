//
//  Notifications_ANE.m
//  Notifications ANE
//
//  Created by Christopher Nassar on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Notifications_ANE.h"
#import "objc/objc.h"
#import "objc/runtime.h"

@implementation Notifications_ANE
@synthesize context;

FREContext g_ctx_Notification;
static  NSString *event_name_success = @"NOTIFICATION_SUCCESS";
static  NSString *event_name_fail = @"NOTIFICATION_FAILED";

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{}


void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication* application, NSData* deviceToken)
{
        
	NSLog(@"My token is: %@", deviceToken);
    NSString* devicestr = [NSString stringWithFormat:@"%@",deviceToken];
    FREDispatchStatusEventAsync(g_ctx_Notification, (uint8_t*)[event_name_success UTF8String], (uint8_t*)[devicestr UTF8String]);
}

void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication* application, NSError* error)
{
    //UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Failed to  Register Token" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[av show];
     
	NSLog(@"Failed to get token, error: %@", error);
    FREDispatchStatusEventAsync(g_ctx_Notification, (uint8_t*)[event_name_fail UTF8String], (uint8_t*)[[error localizedDescription] UTF8String]);
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

FREObject InitializeNotificationToken()
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSLog(@"3) InitializeNotificationToken called");
    
    return nil;
}

void NotificationContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    Class objectClass = object_getClass(delegate);
    
    NSString *newClassName = [NSString stringWithFormat:@"Custom_%@", NSStringFromClass(objectClass)];
    Class modDelegate = NSClassFromString(newClassName);
    if (modDelegate == nil) {
        // this class doesn't exist; create it
        // allocate a new class
        modDelegate = objc_allocateClassPair(objectClass, [newClassName UTF8String], 0);
        
        SEL selectorToOverride1 = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
        
        SEL selectorToOverride2 = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
        
        // get the info on the method we're going to override
        Method m1 = class_getInstanceMethod([Notifications_ANE class], selectorToOverride1);
        Method m2 = class_getInstanceMethod([Notifications_ANE class], selectorToOverride2);
        
        // add the method to the new class
        class_addMethod(modDelegate, selectorToOverride1, (IMP)didRegisterForRemoteNotificationsWithDeviceToken, method_getTypeEncoding(m1));
        
        class_addMethod(modDelegate, selectorToOverride2, (IMP)didFailToRegisterForRemoteNotificationsWithError, method_getTypeEncoding(m2));
        
        // register the new class with the runtime
        objc_registerClassPair(modDelegate);
    }
    // change the class of the object
    object_setClass(delegate, modDelegate);
    
    
    NSLog(@"completed crazy swap w/o bombing  w00t");
    
    ///////// end of delegate injection / modification code

    *numFunctionsToTest = 1;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * 1);
    func[0].name = (const uint8_t*) "InitializeNotificationToken";
    func[0].functionData = NULL;
    func[0].function = &InitializeNotificationToken;
    
    *functionsToSet = func;
    
    g_ctx_Notification = ctx;
    
    NSLog(@"2) Context Initializer called");
}

// ContextFinalizer()
//
// The context finalizer is called when the extension's ActionScript code
// calls the ExtensionContext instance's dispose() method.
// If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls
// ContextFinalizer().

void NotificationContextFinalizer(FREContext ctx) {
    
    return;
}

// ExtInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.
void iOSNotExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                    FREContextFinalizer* ctxFinalizerToSet) {
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &NotificationContextInitializer;
    *ctxFinalizerToSet = &NotificationContextFinalizer;
    
    NSLog(@"1) ExtInitializer called");    
}

// ExtFinalizer()
//
// The extension finalizer is called when the runtime unloads the extension. However, it is not always called.
void iOSNotExtFinalizer(void* extData) {
    
    return;
}

@end
