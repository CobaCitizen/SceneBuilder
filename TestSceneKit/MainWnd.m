//
//  MainWnd.m
//  TestSceneKit
//
//  Created by Coba on 10/19/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import "MainWnd.h"
#import "ViewScene.h"
#import "M3DX3djsLoader.h"
#import "M3DXAnimation.h"

@implementation MainWnd
{
    SCNScene* _scene;
    SCNNode* _selectedNode;
//	NSMutableDictionary *_scenes;
	M3DXAnimation *_animator;

}


-(void)awakeFromNib
{
	[super awakeFromNib];

	_sceneStateIndex = [NSNumber numberWithInt:0];

    _scene = [[SCNScene alloc] init];
//	_scenes = [NSMutableDictionary dictionary];
	_animator = [[M3DXAnimation alloc] init];
	
    self.viewLeft.allowsCameraControl = YES;
    self.viewBottom.allowsCameraControl = YES;
    self.viewTop.allowsCameraControl = YES;

    self.viewPerspective.scene = _scene;
    self.viewLeft.scene = _scene;
    self.viewBottom.scene = _scene;
    self.viewTop.scene = _scene;
    
    self.viewPerspective.showsStatistics = YES;
    self.viewPerspective.delegate = self;
 
    
}
#pragma mark ViewScene Delegate
-(void)selectionNodeDidChanged:(SCNNode *)selectedNode {
    
    if(_selectedNode != selectedNode) {
        SCNMaterial *material = [SCNMaterial material];
        material.diffuse.contents = [NSImage imageNamed:@"checker.jpg"];
        _selectedNode.geometry.materials = [[NSArray alloc] initWithObjects:material, nil];
    }
    _selectedNode = selectedNode;
}
-(void)transformModeDidChanged:(NSString*)text
{
	[_fldTransformMode setStringValue:text];
}
-(IBAction)actOpenFile:(id)sender {
    
    NSOpenPanel* openPanel = [[NSOpenPanel alloc] init];
    [openPanel runModal];
    
    NSDictionary *dic = @{SCNSceneSourceCreateNormalsIfAbsentKey:[NSNumber numberWithBool:YES]};
    NSError *error;
    SCNScene *scene = [SCNScene sceneWithURL:openPanel.URLs[0] options:dic error:&error];
    

//	SCNNode *node = [SCNNode node];
//
//	[node addChildNode:scene.rootNode];
//	
//	[_scene.rootNode addChildNode:node];
//	return;
    for (SCNNode *child in scene.rootNode.childNodes) {
        [_scene.rootNode addChildNode:child];
    }

	return;
	
    SCNSceneSource* sceneSource = [SCNSceneSource sceneSourceWithURL:openPanel.URLs[0] options:dic];
    NSArray *array =  [sceneSource identifiersOfEntriesWithClass:[CAAnimation class]];
    
    int cnt = 0;
	
    for(NSString *animName in array) {
        CAAnimation  *animationObject = [sceneSource entryWithIdentifier:animName withClass:[CAAnimation class]];
        [self.btnAnimations addItemWithTitle:animName];
        NSString *key  = [[NSString alloc] initWithFormat:@"%s%d", "ident", ++cnt];
        animationObject.repeatCount = INFINITY;
        [_scene.rootNode addAnimation:animationObject forKey:key];
    }
}
-(IBAction)actSceneStateChanged:(id)sender
{
	[_animator saveScene:_scene state:_sceneStateIndex.integerValue];
}
-(IBAction)actLoad3djsFile:(id)sender
{
	static int ident = 0;
	
	NSOpenPanel* openPanel = [[NSOpenPanel alloc] init];
	[openPanel runModal];

	NSURL *srcUrl =openPanel.URLs[0];
	M3DX3djsLoader *loader = [[M3DX3djsLoader alloc] init];
	NSString *sceneKey = [NSString stringWithFormat:@"Scene%d",ident++];

	M3DXScene *sc = [loader loadFromUrl:srcUrl];
	//[_scenes setValue:sc forKey:sceneKey];
	
	for (SCNNode *child in sc.scnScene.rootNode.childNodes) {
		[_scene.rootNode addChildNode:child];
	}
	

}
-(IBAction)actRemoveAllObjects:(id)sender {
    for(SCNNode* node in _scene.rootNode.childNodes) {
        [node removeFromParentNode];
    }
}

-(IBAction)actAddLight:(id)sender {
    SCNLight *spotLight = [SCNLight light];
    spotLight.type = SCNLightTypeOmni;
    spotLight.color = [NSColor redColor];
    _lightNode = [SCNNode node];
    _lightNode.light = spotLight;
    _lightNode.position = SCNVector3Make(10, 30, 0);

    [_scene.rootNode addChildNode:_lightNode];
}

- (IBAction)actPlay:(id)sender {
    [self.viewPerspective play:sender];
}

-(IBAction)actPause:(id)sender {
       [self.viewPerspective pause:sender];
}

-(IBAction)actStop:(id)sender {
    [self.viewPerspective stop:sender];
}

- (IBAction)actAddCamera:(id)sender {
    SCNCamera *camera = [[SCNCamera alloc] init];
    camera.usesOrthographicProjection = YES;
    camera.orthographicScale = 9;
    camera.zNear = 0;
    camera.zFar = 100;
    
    _cameraNode = [[SCNNode alloc] init];
    _cameraNode.camera = camera;
    _cameraNode.position = SCNVector3Make(30, 30, 30);
    
    [_scene.rootNode addChildNode:_cameraNode];
    self.viewPerspective.pointOfView.camera = camera;
}

-(IBAction)actAddBox:(id)sender {
	
    SCNBox *box = [[SCNBox alloc] init];
    box.width = 20.f;
    box.height = 20.f;
    box.length = 20.f;
    box.chamferRadius = 3;
	
    _boxNode = [[SCNNode alloc] init];
	_boxNode.name = [_animator makeName];
    _boxNode.geometry = box;
	
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSImage imageNamed:@"checker.jpg"];
    _boxNode.geometry.materials = [[NSArray alloc] initWithObjects:material, nil];
    [_scene.rootNode addChildNode:_boxNode];
}

- (IBAction)actAnimationStop:(id)sender
{
	[_animator removeAnimation:_scene.rootNode];
}
-(void)doAnimationStep:(int)stateIndex beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
{
//	CFTimeInterval duration = 5.0;
	
	[CATransaction begin];
	[CATransaction setValue: [NSNumber numberWithBool: YES]	 forKey: kCATransactionDisableActions];
	
	if(self.animationCurrentSate < 3)
	{
		[CATransaction setCompletionBlock:^{
			self.animationCurrentSate++;
			self.beginTime += duration;
			[self doAnimationStep:self.animationCurrentSate beginTime:self.beginTime duration:duration];
		}];
	}
	[_animator bindAnimationsWithScene:_scene stateIndex:stateIndex beginTime:beginTime duration:duration];
	[CATransaction commit];
}
- (IBAction)actAnimationStart:(id)sender
{
	[self.viewPerspective setPlaying:YES];
	
	self.animationCurrentSate = 0;
	
	self.beginTime = CACurrentMediaTime();
	CFTimeInterval duration = 2.0;

//	[CATransaction begin];
//	[CATransaction setValue: [NSNumber numberWithBool: YES]	 forKey: kCATransactionDisableActions];
//
//	[CATransaction setCompletionBlock:^{
//		self.animationCurrentSate = 1;
//		self.beginTime += duration;
//    	[self doAnimationStep:self.animationCurrentSate beginTime:self.beginTime duration:duration];
//	}];
	[self actAnimationStop:nil];
	
	//[_animator bindAnimationsWithScene:_scene];
	[self doAnimationStep:self.animationCurrentSate beginTime:self.beginTime duration:duration];
	
	
//	[CATransaction commit];
	[self.viewPerspective setPlaying:NO];
	return;
	
	[self actAnimationStop:nil];

	CABasicAnimation *colorRed = [CABasicAnimation animationWithKeyPath:@"color"];
	colorRed.fromValue = [NSColor redColor];
	colorRed.toValue = [NSColor blueColor];
	colorRed.duration = 3.0;
	colorRed.repeatCount = INFINITY;
/*
	CAKeyframeAnimation *spotColor =
	[CAKeyframeAnimation animationWithKeyPath:@"color"];
	spotColor.values = @[(id)[NSColor redColor],
						 (id)[NSColor blueColor],
						 (id)[NSColor greenColor],
						 (id)[NSColor redColor]];
	
	spotColor.timingFunction =	[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	spotColor.repeatCount = INFINITY;
	spotColor.duration = 15.0;

*/
	[_lightNode addAnimation:colorRed forKey:@"ChangeTheColorOfTheSpot"];
	
	// Rotating the box
	CABasicAnimation *boxRotation =	[CABasicAnimation animationWithKeyPath:@"transform"];
	boxRotation.toValue =[NSValue valueWithCATransform3D:CATransform3DRotate(_boxNode.transform,	M_PI,1, 1, 0)];
	boxRotation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	boxRotation.repeatCount = INFINITY;
	boxRotation.duration = 2.0;
	
	[_boxNode addAnimation:boxRotation   forKey:@"RotateTheBox"];

}
- (IBAction)actAnimationTest:(id)sender
{
	[CATransaction begin];
	[CATransaction setValue: [NSNumber numberWithBool: YES]	 forKey: kCATransactionDisableActions];

	self.viewPerspective.layer.opacity =  1.0;
	
	if(_selectedNode)
	{
		CABasicAnimation *anim =[CABasicAnimation animationWithKeyPath:@"transform"];
		anim.fromValue=[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,0,-10)];
		anim.toValue =[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,0,-400)];
		anim.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		anim.beginTime = CACurrentMediaTime();
		anim.repeatCount = 1;//INFINITY;
		anim.duration = 5.0;
		[_selectedNode addAnimation:anim forKey:@"test"];
		
//		CABasicAnimation *anim2 =[CABasicAnimation animationWithKeyPath:@"transform"];
//		anim2.fromValue=[NSValue valueWithCATransform3D:CATransform3DMakeRotation(90, 1, 1, 1)];
//		anim2.toValue =[NSValue valueWithCATransform3D:CATransform3DMakeRotation(180, 1, 1, 1)];
//		anim.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//		anim.beginTime = CACurrentMediaTime();
//		anim.repeatCount = 1;//INFINITY;
//		anim.duration = 5.0;
//		[_selectedNode addAnimation:anim forKey:@"test2"];
		
//		CABasicAnimation *alphaAnim = [CABasicAnimation  animationWithKeyPath:@"opacity"];
//		CAKeyframeAnimation *sizeAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//		CAAnimationGroup *group = [CAAnimationGroup animation];
//		group.animations = [NSArray arrayWithObjects:anim,anim2,nil];
//		group.duration = 10.0;
//		group.beginTime = CACurrentMediaTime () + 0.5;
//		//group.timeOffset = 0.5;
//		[_selectedNode addAnimation:group forKey:@"group_test2"];

	}
	[CATransaction commit];

}

-(IBAction)setValueX:(NSTextField*)sender {
    if(_selectedNode) {
        float val = [sender floatValue];
        SCNVector3 vec = _selectedNode.position;
        SCNVector3 vecResult = SCNVector3Make(val, vec.y, vec.z);
        _selectedNode.position = vecResult;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSOutlineViewDataSource
////////////////////////////////////////////////////////////////////////



//----------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (((SCNNode*)item) == _scene.rootNode)
        return YES;
    else
        return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item==nil)
    {
        // Root
        return _scene.rootNode.childNodes.count;
    }
    else
    {
        SCNNode *node = (SCNNode*)item;
        return     node.childNodes.count;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil)
    {
        // Root
        return _scene.rootNode;
    }
    else{
        return _scene.rootNode.childNodes[index];
    }
    
    // File
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)theColumn byItem:(id)item
{
    SCNNode *node = (SCNNode*)item;
    return node.name;
    return nil;
}

@end
