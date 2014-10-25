//
//  M3DXAnimation.m
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 24/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import "M3DXAnimation.h"
@implementation M3DXNodeInfo

-(id) initWithName:(NSString*)name andTransform:(CATransform3D)transform
{

	self = [super init];
	if(self)
	{
		_name = name;
		_transform = transform;
	}
	return self;
}
-(id) initWithName:(NSString*)name andPosition:(SCNVector3)position
{
	
	self = [super init];
	if(self)
	{
		_name = name;
	//	_position = SCNVector3Make(position.x, position.y, position.z);
		_transform = CATransform3DMakeTranslation(position.x, position.y, position.z);

	}
	return self;
}

@end

@implementation M3DXAnimation
{
	NSMutableDictionary *_sceneStates;
	int _statesCount;
	NSInteger _currentStateIndex;
	int _nextNodeIdent;
}

-(id)init
{
	self = [super init];
	if(self)
	{
		_statesCount = 10;
		_currentStateIndex = 0;
		_nextNodeIdent = 1;
		
		_sceneStates = [NSMutableDictionary dictionary];
		for(int i =0;i < _statesCount;i++)
		{
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			[_sceneStates setObject:dic forKey:[NSNumber numberWithInt:i]];
		}
		
	}
	return self;
}
-(NSString*) makeName
{
	return [NSString stringWithFormat:@"Node%d",_nextNodeIdent++];
}

-(CATransform3D)cloneTransform:(CATransform3D)src
{

	CATransform3D d;
	d.m11 = src.m11;
	d.m12 = src.m12;
	d.m13 = src.m13;
	d.m14 = src.m14;
	d.m21 = src.m21;
	d.m22 = src.m22;
	d.m23 = src.m23;
	d.m24 = src.m24;
	d.m31 = src.m31;
	d.m32 = src.m32;
	d.m33 = src.m33;
	d.m41 = src.m41;
	d.m42 = src.m42;
	d.m43 = src.m43;
	d.m44 = src.m44;
	
	return d;
}
-(void) saveSceneTransforms:(NSMutableDictionary*)dic fromNode:(SCNNode*)parent
{
	if(!parent)
	{
		return;
	}
	if(!parent.name)
	{
		parent.name = [self makeName];
	}
	M3DXNodeInfo *info = [[M3DXNodeInfo alloc] initWithName:parent.name andTransform:[self cloneTransform:parent.transform]];
//	M3DXNodeInfo *info = [[M3DXNodeInfo alloc] initWithName:parent.name andPosition:parent.position];
	[dic setObject:info  forKey:parent.name];
//		NSLog(@"1.Save name:%@ x:%.2f y:%.3f z:%.3f",info.name,info.position.x,info.position.y,info.position.z);

	for(SCNNode *child in parent.childNodes)
	{
		[self saveSceneTransforms:dic fromNode:child];
	}
}

-(void) applaySceneTransforms:(NSMutableDictionary*)dic fromNode:(SCNNode*)parent
{
	if(!parent)
	{
		return;
	}
	if(!parent.name)
	{
		parent.name = [self makeName];
	}
	if(dic[parent.name])
	{
		M3DXNodeInfo *info = dic[parent.name];
		parent.transform = info.transform;
	//	parent.position = info.position;
	//		NSLog(@"2.Applay name:%@ x:%.2f y:%.3f z:%.3f",info.name,info.position.x,info.position.y,info.position.z);
	}
	for(SCNNode *child in parent.childNodes)
	{
		[self applaySceneTransforms:dic fromNode:child];
	}
	
}

-(void)removeAnimation:(SCNNode*)node
{
	if(!node)
	{
		return;
	}
	[node removeAllAnimations];
	for(SCNNode *child in node.childNodes)
	{
		[self removeAnimation:child];
	}
	
}
-(void) saveScene:(SCNScene*)scene state:(NSInteger)state
{
	NSNumber *index = [NSNumber numberWithInteger: _currentStateIndex];
	NSLog(@"1.Save state:%ld",[index integerValue]);
	
    NSMutableDictionary *currentState = [_sceneStates objectForKey:index];
	[currentState removeAllObjects];
	[self saveSceneTransforms:currentState fromNode:scene.rootNode];

	
	index = [NSNumber numberWithInteger: state];
	NSLog(@"1.Applay state:%ld",[index integerValue]);

	NSMutableDictionary *sceneState = [_sceneStates objectForKey:index];

	[self applaySceneTransforms:sceneState fromNode:scene.rootNode];
	_currentStateIndex = state;
	
}

-(void) getAllSceneNodes:(NSMutableDictionary*)dic fromNode:(SCNNode*)parent
{
	if(!parent)
	{
		return;
	}
	if(parent.name)
	{
		dic[parent.name] = parent;
	}
	for(SCNNode *child in parent.childNodes)
	{
		[self getAllSceneNodes:dic fromNode:child];
	}
	
}

-(void) bindAnimationsWithScene:(SCNScene*)scene
{
	
//	[CATransaction begin];
//	[CATransaction setAnimationDuration:2.0f];
//	[animationLayer setFrame:CGRectMake(100.0f, 100.0f, 100.0f, 100.0f)];
	NSMutableDictionary *sceneState = [_sceneStates objectForKey:0];
	[self applaySceneTransforms:sceneState fromNode:scene.rootNode];

	NSMutableDictionary* dic = [NSMutableDictionary dictionary];
	[self getAllSceneNodes:dic fromNode:scene.rootNode];
	
	NSString *animName;
	for(SCNNode *node in dic.allValues)
	{
		NSString *key = node.name;
		CFTimeInterval beginTime = CACurrentMediaTime();
		CFTimeInterval duration = 1.0;
		for(int i = 0 ; i < _statesCount-1;i++)
		{
			NSMutableDictionary *first = [_sceneStates objectForKey:[NSNumber numberWithInteger: i]];
            NSMutableDictionary *second = [_sceneStates objectForKey:[NSNumber numberWithInteger: i]];
			if(first.count > 0 && second.count > 0)
			{
				M3DXNodeInfo *infoFirst = first[key];
				M3DXNodeInfo *infoSecond = second[key];
				CABasicAnimation* anim =
				   [self makeAnimationFrom:infoFirst.transform to:infoSecond.transform beginTime:beginTime duration:duration];
				
				animName = [NSString stringWithFormat:@"%@_%d", node.name,i];
				//animName = [NSString stringWithFormat:@"%@_Animation", node.name];
				[node addAnimation:anim  forKey:animName];

				beginTime += duration;
			}
		}
	}
//	[CATransaction commit];
}

-(void) bindAnimationsWithScene:(SCNScene*)scene stateIndex:(int)stateIndex beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
{
	
	//	[CATransaction begin];
	//	[CATransaction setAnimationDuration:2.0f];
	//	[animationLayer setFrame:CGRectMake(100.0f, 100.0f, 100.0f, 100.0f)];
	NSMutableDictionary *sceneState = [_sceneStates objectForKey:[NSNumber numberWithInt:stateIndex]];
	[self applaySceneTransforms:sceneState fromNode:scene.rootNode];
	
	NSMutableDictionary* dic = [NSMutableDictionary dictionary];
	[self getAllSceneNodes:dic fromNode:scene.rootNode];
	
	NSString *animName;
	for(SCNNode *node in dic.allValues)
	{
		NSString *key = node.name;
//		CFTimeInterval beginTime = CACurrentMediaTime();
//		CFTimeInterval duration = 1.0;
		NSMutableDictionary *first = [_sceneStates objectForKey:[NSNumber numberWithInteger: stateIndex]];
		NSMutableDictionary *second = [_sceneStates objectForKey:[NSNumber numberWithInteger: stateIndex+1]];
		if(first.count > 0 && second.count > 0)
		{
			M3DXNodeInfo *infoFirst = first[key];
			M3DXNodeInfo *infoSecond = second[key];
			CABasicAnimation* anim =
			[self makeAnimationFrom:infoFirst.transform to:infoSecond.transform beginTime:beginTime duration:duration];
			
			animName = [NSString stringWithFormat:@"%@_%d", node.name,stateIndex];
			//animName = [NSString stringWithFormat:@"%@_Animation", node.name];
			[node addAnimation:anim  forKey:animName];
			
//			beginTime += duration;
		}
	}
	//	[CATransaction commit];
}

-(CABasicAnimation*)makeAnimationFrom:(CATransform3D)from to:(CATransform3D)to beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
{
	// Rotating the box
	CABasicAnimation *anim =[CABasicAnimation animationWithKeyPath:@"transform"];
	anim.fromValue =[NSValue valueWithCATransform3D:from];
	anim.toValue = [NSValue valueWithCATransform3D:to];
	anim.beginTime =  beginTime;//CACurrentMediaTime() +
	anim.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; //kCAMediaTimingFunctionLinear];
	anim.repeatCount = 1;
	anim.removedOnCompletion = YES;
//	anim.fillMode = kCAFillModeForwards;
	anim.duration = duration;
	
	anim.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	return  anim;
	

}
@end
