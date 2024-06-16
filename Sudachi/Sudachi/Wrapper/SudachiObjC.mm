//
//  SudachiObjC.mm
//  Sudachi
//
//  Created by Jarrod Norwell on 1/8/24.
//

#import "SudachiObjC.h"

#import "Config/Config.h"
#import "EmulationSession/EmulationSession.h"
#import "DirectoryManager/DirectoryManager.h"

#include "common/fs/fs.h"
#include "common/fs/path_util.h"
#include "common/settings.h"

#import <mach/mach.h>

@implementation SudachiObjC
-(SudachiObjC *) init {
    if (self = [super init]) {
        _gameInformation = [SudachiGameInformation sharedInstance];
        
        Common::FS::SetAppDirectory(DirectoryManager::SudachiDirectory());
        Config{"config", Config::ConfigType::GlobalConfig};
        
        EmulationSession::GetInstance().System().Initialize();
        EmulationSession::GetInstance().InitializeSystem(false);
        EmulationSession::GetInstance().InitializeGpuDriver();
        
        // YuzuSettings::values.use_asynchronous_shaders.SetValue(true);
        // YuzuSettings::values.astc_recompression.SetValue(YuzuSettings::AstcRecompression::Bc3);
        // YuzuSettings::values.shader_backend.SetValue(YuzuSettings::ShaderBackend::SpirV);
        // YuzuSettings::values.resolution_setup.SetValue(YuzuSettings::ResolutionSetup::Res1X);
        // YuzuSettings::values.scaling_filter.SetValue(YuzuSettings::ScalingFilter::Bilinear);
    } return self;
}

+(SudachiObjC *) sharedInstance {
    static SudachiObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) quit {
    void(EmulationSession::GetInstance().ShutdownEmulation());
}

-(void) configureLayer:(CAMetalLayer *)layer withSize:(CGSize)size {
    _layer = layer;
    _size = size;
    EmulationSession::GetInstance().SetNativeWindow((__bridge CA::MetalLayer*)layer, size);
}

-(void) bootOS {
    EmulationSession::GetInstance().BootOS();
}

-(void) insertGame:(NSURL *)url {
    EmulationSession::GetInstance().InitializeEmulation([url.path UTF8String], [_gameInformation informationForGame:url].programID, true);
}

-(void) insertGames:(NSArray<NSURL *> *)games {
    for (NSURL *url in games) {
        EmulationSession::GetInstance().ConfigureFilesystemProvider([url.path UTF8String]);
    }
}

-(void) step {
    void(EmulationSession::GetInstance().System().Run());
}

-(void) touchBeganAtPoint:(CGPoint)point index:(NSUInteger)index {
    float h_ratio, w_ratio;
    h_ratio = EmulationSession::GetInstance().Window().GetFramebufferLayout().height / (_size.height * [[UIScreen mainScreen] nativeScale]);
    w_ratio = EmulationSession::GetInstance().Window().GetFramebufferLayout().width / (_size.width * [[UIScreen mainScreen] nativeScale]);
    
    EmulationSession::GetInstance().Window().OnTouchPressed([[NSNumber numberWithUnsignedInteger:index] intValue],
                                                            (point.x) * [[UIScreen mainScreen] nativeScale] * w_ratio,
                                                            ((point.y) * [[UIScreen mainScreen] nativeScale] * h_ratio));
}

-(void) touchEndedForIndex:(NSUInteger)index {
    EmulationSession::GetInstance().Window().OnTouchReleased([[NSNumber numberWithUnsignedInteger:index] intValue]);
}

-(void) touchMovedAtPoint:(CGPoint)point index:(NSUInteger)index {
    float h_ratio, w_ratio;
    h_ratio = EmulationSession::GetInstance().Window().GetFramebufferLayout().height / (_size.height * [[UIScreen mainScreen] nativeScale]);
    w_ratio = EmulationSession::GetInstance().Window().GetFramebufferLayout().width / (_size.width * [[UIScreen mainScreen] nativeScale]);
    
    EmulationSession::GetInstance().Window().OnTouchMoved([[NSNumber numberWithUnsignedInteger:index] intValue],
                                                          (point.x) * [[UIScreen mainScreen] nativeScale] * w_ratio,
                                                          ((point.y) * [[UIScreen mainScreen] nativeScale] * h_ratio));
}

-(void) thumbstickMoved:(VirtualControllerAnalogType)analog x:(CGFloat)x y:(CGFloat)y {
    EmulationSession::GetInstance().OnGamepadConnectEvent(0);
    EmulationSession::GetInstance().Window().OnGamepadJoystickEvent(0, [[NSNumber numberWithUnsignedInteger:analog] intValue], CGFloat(x), CGFloat(y));
}

-(void) virtualControllerButtonDown:(VirtualControllerButtonType)button {
    EmulationSession::GetInstance().OnGamepadConnectEvent(0);
    EmulationSession::GetInstance().Window().OnGamepadButtonEvent(0, [[NSNumber numberWithUnsignedInteger:button] intValue], true);
}

-(void) virtualControllerButtonUp:(VirtualControllerButtonType)button {
    EmulationSession::GetInstance().OnGamepadConnectEvent(0);
    EmulationSession::GetInstance().Window().OnGamepadButtonEvent(0, [[NSNumber numberWithUnsignedInteger:button] intValue], false);
}

-(void) orientationChanged:(UIInterfaceOrientation)orientation with:(CAMetalLayer *)layer size:(CGSize)size {
    _layer = layer;
    _size = size;
    EmulationSession::GetInstance().Window().OnSurfaceChanged((__bridge CA::MetalLayer*)layer, size);
}

-(void) settingsChanged {
    Config{"config", Config::ConfigType::GlobalConfig};
}
@end
