//
//  SudachiGameInformation.h
//  Sudachi
//
//  Created by Jarrod Norwell on 1/20/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SudachiInformation : NSObject
@property (nonatomic, strong) NSString *developer;
@property (nonatomic, strong) NSData *iconData;
@property (nonatomic) BOOL isHomebrew;
@property (nonatomic) uint64_t programID;
@property (nonatomic, strong) NSString *title, *version;

-(SudachiInformation *) initWithDeveloper:(NSString *)developer iconData:(NSData *)iconData isHomebrew:(BOOL)isHomebrew programID:(uint64_t)programID title:(NSString *)title version:(NSString *)version;
@end

@interface SudachiGameInformation : NSObject
+(SudachiGameInformation *) sharedInstance NS_SWIFT_NAME(shared());

-(SudachiInformation *) informationForGame:(NSURL *)url NS_SWIFT_NAME(information(for:));
@end

NS_ASSUME_NONNULL_END
