//
//  M3DXCoder.m
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 20/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import "M3DXCoder.h"

@implementation M3DXCoder

GLKMatrix4 GKLMatrix4FromNSArray(NSArray* array)
{
	return
	GLKMatrix4Make([array[0] floatValue], [array[1] floatValue],
				   [array[2] floatValue], [array[3] floatValue],
				   [array[4] floatValue], [array[5] floatValue],
				   [array[6] floatValue], [array[7] floatValue],
				   [array[8] floatValue], [array[9] floatValue],
				   [array[10] floatValue], [array[11] floatValue],
				   [array[12] floatValue], [array[13] floatValue],
				   [array[14] floatValue], [array[15] floatValue]);
}

+(CATransform3D) CATransform3DFromNSArray:(NSArray*) array
{
	CATransform3D t;
	t.m11 = [array[0] floatValue];
	t.m12 = [array[1] floatValue];
	t.m13 = [array[2] floatValue];
	t.m14 = [array[3] floatValue];
	t.m21 = [array[4] floatValue];
	t.m22 = [array[5] floatValue];
	t.m23 = [array[6] floatValue];
	t.m24 = [array[7] floatValue];
	t.m31 = [array[8] floatValue];
	t.m32 = [array[9] floatValue];
	t.m33 = [array[10] floatValue];
	t.m34 = [array[11] floatValue];
	t.m41 = [array[12] floatValue];
	t.m42 = [array[13] floatValue];
	t.m43 = [array[14] floatValue];
	t.m44 = [array[15] floatValue];

	return t;
}


+ (NSString*)decodeStringForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	return [NSString stringWithString:dic[key]];
}
+(BOOL)decodeBoolForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	return [dic[key] boolValue];
}

+ (int)decodeIntForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	//TODO check, if hibernate can send a wrong format
	NSNumber * value = dic[key];
	return [value intValue];
}
+(NSInteger)decodeIntegerForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	NSDecimalNumber * value = dic[key];
	return [value integerValue];
}

+(float)decodeFloatForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	NSDecimalNumber *floatStr = dic[key];//[[self topJsonObject] valueForKey:key];
	return [floatStr floatValue];
}
+(GLKVector3)decodeGLKVector3ColorForKey:(NSString *)key  withDictionary:(NSDictionary*)dic
{
	NSArray* theFloatArray3 = dic[key];
	return GLKVector3Make([theFloatArray3[0] floatValue]/255, [theFloatArray3[1] floatValue]/255, [theFloatArray3[2] floatValue]/255);
}
+(GLKVector2)decodeGLKVector2ForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	NSArray* theFloatArray2 = dic[key];
	return GLKVector2Make([theFloatArray2[0] floatValue], [theFloatArray2[1] floatValue]);
}
+(GLKVector4)decodeGLKVector4ColorForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	NSArray* theFloatArray4 = dic[key];
	return GLKVector4Make([theFloatArray4[0] floatValue]/255, [theFloatArray4[1] floatValue]/255, [theFloatArray4[2] floatValue]/255, [theFloatArray4[3] floatValue]/255);
}
+(GLKVector3)decodeGLKVector3ForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	NSArray* theFloatArray3 = dic[key];
	return GLKVector3Make([theFloatArray3[0] floatValue], [theFloatArray3[1] floatValue], [theFloatArray3[2] floatValue]);
}

+(GLKMatrix4)decodeGLKMatrix4ForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	NSArray* theFloatArray16 = dic[key];
	return GKLMatrix4FromNSArray(theFloatArray16);
}

+(GLKVector4)decodeGLKVector4ForKey:(NSString *)key withDictionary:(NSDictionary*)dic
{
	NSArray* theFloatArray4 = dic[key];
	return GLKVector4Make([theFloatArray4[0] floatValue], [theFloatArray4[1] floatValue], [theFloatArray4[2] floatValue], [theFloatArray4[3] floatValue]);
}

//
//  encoding
//

+(NSArray*)encodeGLKVector2:(GLKVector2)vector
{
	return @[@(vector.x),@(vector.y)];
}

+(NSArray *)encodeGLKVector3Color:(GLKVector3)vector
{
	return @[@(round(vector.x*255)),@(round(vector.y*255)),@(round(vector.z*255))];
}

+(NSArray *)encodeGLKVector4Color:(GLKVector4)vector
{
	return @[@(round(vector.r*255)),@(round(vector.g*255)),@(round(vector.b*255)),@(round(vector.a*255))];
}

+(NSNumber*)encodeInteger:(NSInteger)value
{
	return [NSNumber numberWithInteger:value];
}
+(NSString*)encodeString:(NSString*)value
{
	return [NSString stringWithString:value];
}
+(NSNumber*)encodeBool:(BOOL)value
{
	return [NSNumber numberWithBool:value];
}

+(NSNumber*)encodeDouble:(double)value
{
	return [NSNumber numberWithDouble:value];
}

+(NSNumber*)encodeFloat:(float)value
{
	return [NSNumber numberWithFloat:value];
}

+(NSNumber*)encodeInt:(int)value
{
	return [NSNumber numberWithInt:value];
}


+(NSNumber*)encodeInt64:(int64_t)value
{
	return [NSNumber numberWithLong:value];
}

@end
