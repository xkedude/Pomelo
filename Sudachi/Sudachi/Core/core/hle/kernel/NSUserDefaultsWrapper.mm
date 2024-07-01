//
//  NSObject+JITDetector.m
//  Sudachi
//
//  Created by Stossy11 on 1/7/2024.
//

#import <Foundation/Foundation.h>

extern "C" {
    void SaveBoolToUserDefaults(const char* key, bool value) {
        NSString* nsKey = [NSString stringWithUTF8String:key];
        [[NSUserDefaults standardUserDefaults] setBool:value forKey:nsKey];
    }

    bool GetBoolFromUserDefaults(const char* key) {
        NSString* nsKey = [NSString stringWithUTF8String:key];
        return [[NSUserDefaults standardUserDefaults] boolForKey:nsKey];
    }
}
