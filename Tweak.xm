#include <substrate.h>

@class GCDAsyncSocket;
@class NSXMLElement;

static NSDate * (*_orig_WAAppExpirationDate)();

static NSDate * (*_orig_WADeprecatedPlatformCutOffDate)();

static NSDate * (*_orig_WABuildDate)();
static NSString * (*_orig_WABuildVersion)(void *, void *);
static NSString * (*_orig_WABuildHash)();

static NSDate *_new_WAAppExpirationDate() {
    NSLog(@"_new_WAAppExpirationDate called");
    NSDate *originalDate = _orig_WAAppExpirationDate();
    NSLog(@"Original expiration date: %@", originalDate);
    // Modify the date or do whatever you want here
    return [NSDate dateWithTimeIntervalSinceNow:31536000];
}

static NSDate *_new_WADeprecatedPlatformCutOffDate() {
    NSLog(@"_new_WADeprecatedPlatformCutOffDate called");
    NSDate *originalDate = _orig_WADeprecatedPlatformCutOffDate();
    NSLog(@"Original expiration date: %@", originalDate);
    // Modify the date or do whatever you want here
    return [NSDate dateWithTimeIntervalSinceNow:31536000];
}


static NSDate *_new_WABuildDate() {
    NSLog(@"_new_WABuildDate called");
    NSDate *originalDate = _orig_WABuildDate();
    NSLog(@"Original build date: %@", originalDate);
    // Modify the date or do whatever you want here
    return [NSDate date];
}

static NSString *_new_WABuildVersion(void *arg1, void *arg2) {
    NSLog(@"_new_WABuildVersion called");
    NSString *originalVersion = _orig_WABuildVersion(arg1, arg2);
    NSLog(@"Original build version: %@", originalVersion);
    // Modify the version or do whatever you want here
    return @"2.25.14.7";
}

static NSString *_new_WABuildHash() {
    NSLog(@"_new_WABuildHash called");
    NSString *originalVersion = _orig_WABuildHash();
    NSLog(@"Original build hash: %@", originalVersion);
    // Modify the version or do whatever you want here
    return @"30168ac5ccce84897eb26120ea54d4df";
}

%ctor {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *frameworkPath = [bundlePath stringByAppendingPathComponent:@"Frameworks/SharedModules.framework/SharedModules"];
    MSImageRef image = MSGetImageByName([frameworkPath UTF8String]);
    
    /* %init(WAIsPlatformDeprecated =
         MSFindSymbol(NULL, "WAIsPlatformDeprecated")); Somebody please fix this */

    if (image) {
        void * _WAAppExpirationDate = MSFindSymbol(image, "_WAAppExpirationDate");
        if (_WAAppExpirationDate) {
            // Cast the void pointer to a function pointer and call it
            NSDate * (*func)() = (NSDate *(*)())_WAAppExpirationDate;
            NSDate *result = func();
            NSLog(@"Function result: %@", result);

            MSHookFunction(_WAAppExpirationDate, (void *)&_new_WAAppExpirationDate, (void **)&_orig_WAAppExpirationDate);
        } else {
            NSLog(@"Failed to find _WAAppExpirationDate");
        }

		void * _WABuildDate = MSFindSymbol(image, "_WABuildDate");
        if (_WABuildDate) {
            // Cast the void pointer to a function pointer and call it
            NSDate * (*func)() = (NSDate *(*)())_WABuildDate;
            NSDate *result = func();
            NSLog(@"Function result: %@", result);

            MSHookFunction(_WABuildDate, (void *)&_new_WABuildDate, (void **)&_orig_WABuildDate);
        } else {
            NSLog(@"Failed to find _WABuildDate");
        }

        void * _WABuildVersion = MSFindSymbol(image, "_WABuildVersion");
        if (_WABuildVersion) {
            // Cast the void pointer to a function pointer and call it
            NSString * (*func)(void *, void *) = (NSString *(*)(void *, void *))_WABuildVersion;
            NSString *result = func((void*)@"", (void*)@""); // Pass NULL for the arguments if you don't know what to pass
            NSLog(@"Function result: %@", result);

            MSHookFunction(_WABuildVersion, (void *)&_new_WABuildVersion, (void **)&_orig_WABuildVersion);
        } else {
            NSLog(@"Failed to find _WABuildVersion");
        }

		void * _WABuildHash = MSFindSymbol(image, "_WABuildHash");
        if (_WABuildHash) {
            // Cast the void pointer to a function pointer and call it
            NSString * (*func)() = (NSString *(*)())_WABuildHash;
            NSString *result = func(); // Pass NULL for the arguments if you don't know what to pass
            NSLog(@"Function result: %@", result);

            MSHookFunction(_WABuildHash, (void *)&_new_WABuildHash, (void **)&_orig_WABuildHash);
        } else {
            NSLog(@"Failed to find _WABuildHash");
        }

        void * _WADeprecatedPlatformCutOffDate = MSFindSymbol(image, "_WADeprecatedPlatformCutOffDate");
        if (_WADeprecatedPlatformCutOffDate) {
            // Cast the void pointer to a function pointer and call it
            NSDate * (*func)() = (NSDate *(*)())_WADeprecatedPlatformCutOffDate;
            NSDate *result = func();
            NSLog(@"Function result: %@", result);

            MSHookFunction(_WADeprecatedPlatformCutOffDate, (void *)&_new_WADeprecatedPlatformCutOffDate, (void **)&_orig_WADeprecatedPlatformCutOffDate);
        } else {
            NSLog(@"Failed to find _WADeprecatedPlatformCutOffDate");
        }

    } else {
        NSLog(@"Failed to load image at path: %@", frameworkPath);
    }
}

/* Somebody please fix this
%hookf(BOOL, WAIsPlatformDeprecated, void) {
    NSLog(@"[logos] WAIsPlatformDeprecated called");
    // call the original implementation
    bool orig = %orig();
    NSLog(@"[logos] original returned: %d", orig);
    // override it
    bool override = false;
    NSLog(@"[logos] overriding return to: %d", override);
    return override;
} */

%hook WALogWriter

-(NSString*)formatLogText:(NSString*)ar1 withLevel:(int)ar2 {
	NSString *result = %orig;
	NSLog(@"WALog: %@", result);
	return result;
}

%end

%hook WAPBClientPayload_UserAgent_AppVersion

-(void)setPrimary:(int)i {
	%orig(2);
}

-(void)setSecondary:(int)i {
	%orig(99);
}

-(void)setTertiary:(int)i {
	%orig(21);
}

-(void)setQuaternary:(int)i {
	%orig(0);
}

%end

%hook WARootViewController

-(bool)isBuildExpired {
    return false;
}

%end

/*
WACreateUserAgent
WASubmitMessageSendEvent
WAChatServers
WAStreamVersion
WACreateClientPayload*/
