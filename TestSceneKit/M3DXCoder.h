//
//  M3DXCoder.h
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 20/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface M3DXCoder : NSObject

+(CATransform3D) CATransform3DFromNSArray:(NSArray*) array;

+(NSString*)decodeStringForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(BOOL)decodeBoolForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(int)decodeIntForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(NSInteger)decodeIntegerForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(float)decodeFloatForKey:(NSString *)key withDictionary:(NSDictionary*)dic;

+(GLKVector2)decodeGLKVector2ForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(GLKVector3)decodeGLKVector3ColorForKey:(NSString *)key  withDictionary:(NSDictionary*)dic;
+(GLKVector4)decodeGLKVector4ColorForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(GLKMatrix4)decodeGLKMatrix4ForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(GLKVector3)decodeGLKVector3ForKey:(NSString *)key withDictionary:(NSDictionary*)dic;
+(GLKVector4)decodeGLKVector4ForKey:(NSString *)key withDictionary:(NSDictionary*)dic;



+(NSArray *)encodeGLKVector2:(GLKVector2)vector;
+(NSArray *)encodeGLKVector3Color:(GLKVector3)vector;
+(NSArray *)encodeGLKVector4Color:(GLKVector4)vector;

+(NSNumber*)encodeInteger:(NSInteger)value;
+(NSString*)encodeString:(NSString*)value;
+(NSNumber*)encodeBool:(BOOL)value;
+(NSNumber*)encodeDouble:(double)value;
+(NSNumber*)encodeFloat:(float)value;
+(NSNumber*)encodeInt:(int)value;
+(NSNumber*)encodeInt64:(int64_t)value;

@end
