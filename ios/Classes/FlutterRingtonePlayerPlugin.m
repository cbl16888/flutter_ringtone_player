#import "FlutterRingtonePlayerPlugin.h"
#import <AudioToolbox/AudioToolbox.h>

@interface FlutterRingtonePlayerPlugin ()

@property (nonatomic, strong) NSNumber *soundId;

@end


@implementation FlutterRingtonePlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_ringtone_player"
                                     binaryMessenger:[registrar messenger]];
    FlutterRingtonePlayerPlugin* instance = [[FlutterRingtonePlayerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"play" isEqualToString:call.method]) {
        self.soundId = (NSNumber *)call.arguments[@"ios"];
        AudioServicesPlaySystemSound([self.soundId intValue]);
        result(nil);
    } else if ([@"stop" isEqualToString:call.method]) {
        if (self.soundId != nil) {
            AudioServicesDisposeSystemSoundID(self.soundId.intValue);
            self.soundId = nil;
        }
        result(nil);
    } else if ([@"loadRingtone" isEqualToString:call.method]) {
        NSURL *directoryURL = [NSURL fileURLWithPath:@"/Library/Ringtones" isDirectory:YES];
        NSArray<NSURL *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:@[NSURLFileResourceTypeDirectory] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
        NSMutableDictionary *ringtoneDict = [NSMutableDictionary dictionary];
        for (NSURL *url in files) {
            [ringtoneDict setValue:[url absoluteString] forKey:[url lastPathComponent]];
        }
        result(ringtoneDict);
    } else if ([@"playSystemRingtone" isEqualToString:call.method]) {
        if (self.soundId != nil) {
            AudioServicesDisposeSystemSoundID(self.soundId.intValue);
            self.soundId = nil;
        }
        NSString *ringtonePath = (NSString *)call.arguments[@"ringtonePath"];
        NSURL *url = [NSURL URLWithString:ringtonePath];
        SystemSoundID soundId = 0;
        OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundId);
        if (status == kAudioServicesNoError) {
            self.soundId = [NSNumber numberWithInt:soundId];
            AudioServicesPlaySystemSound(soundId);
        }
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
