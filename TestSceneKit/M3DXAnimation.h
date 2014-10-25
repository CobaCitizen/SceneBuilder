//
//  M3DXAnimation.h
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 24/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface M3DXNodeInfo : NSObject

@property (nonatomic,retain) NSString *name;
@property (nonatomic) CATransform3D transform;

@property (nonatomic)SCNVector3 position;

-(id) initWithName:(NSString*)name andTransform:(CATransform3D)transform;
-(id) initWithName:(NSString*)name andPosition:(SCNVector3)position;

@end

@interface M3DXAnimation : NSObject

-(void)saveScene:(SCNScene*)scene state:(NSInteger)state;
-(void)removeAnimation:(SCNNode*)node;
-(NSString*) makeName;
-(void) bindAnimationsWithScene:(SCNScene*)scene;
-(void) bindAnimationsWithScene:(SCNScene*)scene stateIndex:(int)stateIndex beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration;
@end
