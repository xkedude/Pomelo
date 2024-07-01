//
//  NSObject+JITDetector.h
//  Sudachi
//
//  Created by Stossy11 on 1/7/2024.
//

#ifdef __cplusplus
extern "C" {
#endif

void SaveBoolToUserDefaults(const char* key, bool value);
bool GetBoolFromUserDefaults(const char* key);

#ifdef __cplusplus
}
#endif
