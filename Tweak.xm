#include <substrate.h>

@class GCDAsyncSocket;
@class NSXMLElement;

static NSDate * (*_orig_WAAppExpirationDate)();
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
    return @"2.23.21.0";
}

static NSString *_new_WABuildHash() {
    NSLog(@"_new_WABuildHash called");
    NSString *originalVersion = _orig_WABuildHash();
    NSLog(@"Original build hash: %@", originalVersion);
    // Modify the version or do whatever you want here
    return @"442cdfcc3ea7cc1ec566bcc948196e85";
}

%ctor {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *frameworkPath = [bundlePath stringByAppendingPathComponent:@"Frameworks/SharedModules.framework/SharedModules"];
    MSImageRef image = MSGetImageByName([frameworkPath UTF8String]);
    
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
    } else {
        NSLog(@"Failed to load image at path: %@", frameworkPath);
    }
}

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
/*
WACreateUserAgent
WASubmitMessageSendEvent
WAChatServers
WAStreamVersion
WACreateClientPayload*/