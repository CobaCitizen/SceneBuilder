//
//  ViewScene.m
//  TestSceneKit
//
//  Created by Coba on 10/20/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import "ViewScene.h"

#define DEGREES_TO_RADIANS  (180.0 * M_PI)
#define RADIANS_TO_DEGREES  (M_PI/180)

enum ScenTransformMode
{
	TransformModePosition,
	TransformModeRotation,
	TransformModeScale,
	TransformModePivot
};
enum SceneTransformAxis
{
	TransformAxisX,
	TransformAxisY,
	TransformAxisZ
};

@implementation ViewScene
{
	SCNNode* _selectedNode;
	enum ScenTransformMode _transformMode;
	enum SceneTransformAxis _transformAxis;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	_strTransformMode = @"position";
	_transformMode = TransformModePosition;
	_transformAxis = TransformAxisX;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)keyDown:(NSEvent *)theEvent
{
	NSString *text;
	switch (theEvent.keyCode) {
	  case 35://p position
		_transformMode = TransformModePosition;
		_strTransformMode = @"position";
        [self.delegate transformModeDidChanged:_strTransformMode];
		break;
	case 15://r rotation
		_transformMode = TransformModeRotation;
		_strTransformMode = @"rotation";
		[self.delegate transformModeDidChanged:_strTransformMode];
		break;
	case 1://s scale
		_transformMode = TransformModeScale;
		_strTransformMode = @"scale";
		[self.delegate transformModeDidChanged:_strTransformMode];
		break;

			
	case 7://x
		_transformAxis = TransformAxisX;
		text = [NSString stringWithFormat:@"%@ Axis:X",_strTransformMode];
		[self.delegate transformModeDidChanged:text];
		break;
	case 16://y
		_transformAxis = TransformAxisY;
		text = [NSString stringWithFormat:@"%@ Axis:Y",_strTransformMode];
		[self.delegate transformModeDidChanged:text];
		break;
	case 6://z
		_transformAxis = TransformAxisZ;
		text = [NSString stringWithFormat:@"%@ Axis:Z",_strTransformMode];
		[self.delegate transformModeDidChanged:text];
		break;
	case 124: // RIGHT
	case 126: // UP
		[self doTransform:1];
		break;
	case 123:// LEFT
	case 125:// DOWN
		[self doTransform:-1];
		break;
  default:
    	NSLog(@"1.Key : %d",theEvent.keyCode);
		break;
	}
  // [super keyDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    CGPoint p = [self convertPoint:theEvent.locationInWindow fromView: nil];
    NSDictionary* options = @{
							  SCNHitTestSortResultsKey : [NSNumber numberWithBool:YES],
							  SCNHitTestBoundingBoxOnlyKey : [NSNumber numberWithBool:YES],
							  SCNHitTestIgnoreChildNodesKey: [NSNumber numberWithBool:NO]
							  };
    
    NSArray *hitResults = [self hitTest:p options: options];
    
	_selectedNode = nil;
    if (hitResults.count > 0)
	{

        id result = hitResults[0];
        if([result isKindOfClass:[SCNHitTestResult class]])
		{
			
            SCNHitTestResult* selection = result;
			
		//	NSLog(@"1.Hit geom:%ld", selection.geometryIndex);
			
            _selectedNode = selection.node;
			_selectedNode.scale = SCNVector3Make(1, 1, 1);
			[_selectedNode removeAllAnimations];

            SCNMaterial *material = [SCNMaterial material];
            material.diffuse.contents = [NSColor redColor];
            _selectedNode.geometry.firstMaterial = material;
        }
    }
    [self.delegate selectionNodeDidChanged:_selectedNode];
    [super mouseDown:theEvent];
}
-(void)changePosition:(int)delta
{
	SCNVector3 position = _selectedNode.position;

	switch (_transformAxis) {
	  case TransformAxisX:
			position.x += delta * 1;
			break;
		case TransformAxisY:
			position.y += delta * 1;
			break;
		case TransformAxisZ:
			position.z += delta*1;
			break;
  default:
			break;
	}
	_selectedNode.position =position;
}
-(void)changeRotation:(int)delta
{
	
	float angleDelta =delta * M_PI / 180;

	switch (_transformAxis) {
		case TransformAxisX:
			_selectedNode.transform = CATransform3DRotate(_selectedNode.transform, angleDelta, 1, 0, 0);
			break;
		case TransformAxisY:
			_selectedNode.transform = CATransform3DRotate(_selectedNode.transform, angleDelta, 0, 1, 0);
			break;
		case TransformAxisZ:
			_selectedNode.transform = CATransform3DRotate(_selectedNode.transform, angleDelta, 0, 0, 1);
			break;
  default:
		break;
	}
//	_selectedNode.transform =
//    CATransform3DRotate(CATransform3DRotate(CATransform3DRotate(_selectedNode.transform, angleX, 1, 0, 0), angleY, 0, 1, 0), angleZ, 0, 0, 1);

}
-(void)changeScale:(int)delta
{

	float koef = delta * .333;
	switch (_transformAxis) {
		case TransformAxisX:
			_selectedNode.transform = CATransform3DScale(_selectedNode.transform, _selectedNode.scale.x + koef, 1, 1);
			break;
		case TransformAxisY:
			_selectedNode.transform = CATransform3DScale(_selectedNode.transform, 1, _selectedNode.scale.y + koef, 1);
			break;
		case TransformAxisZ:
			_selectedNode.transform = CATransform3DScale(_selectedNode.transform, 1, 1, _selectedNode.scale.z + koef);
			break;
  default:
			break;
	}
	//	_selectedNode.transform =
	//    CATransform3DRotate(CATransform3DRotate(CATransform3DRotate(_selectedNode.transform, angleX, 1, 0, 0), angleY, 0, 1, 0), angleZ, 0, 0, 1);
	
}

-(void)doTransform:(int)delta
{
	if(!_selectedNode)
	{
		return;
	}
	switch (_transformMode)
	{
		case TransformModePosition:
			[self changePosition:delta];
			break;
		case TransformModeRotation:
			[self changeRotation:delta];
			break;
		case TransformModeScale:
			[self changeScale:delta];
			break;
  default:
			break;
	}
}
@end
