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

@interface MainWnd() <NSOutlineViewDataSource, NSOutlineViewDelegate, ViewSceneDelegate>
@property (nonatomic, retain) SCNNode* _box;
@property (nonatomic, retain) SCNNode* _camera;

@end

@implementation MainWnd 
{
    SCNScene* _scene;
    SCNNode* _selectedNode;
	NSMutableDictionary *_scenes;
}


-(void)awakeFromNib
{
    _scene = [[SCNScene alloc] init];
	_scenes = [NSMutableDictionary dictionary];
	
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
        //_selectedNode.geometry.materials = [[NSArray alloc] initWithObjects:material, nil];
    }
    _selectedNode = selectedNode;
}

-(IBAction)actOpenFile:(id)sender {
    
    NSOpenPanel* openPanel = [[NSOpenPanel alloc] init];
    [openPanel runModal];
    
    NSDictionary *dic = @{SCNSceneSourceCreateNormalsIfAbsentKey:[NSNumber numberWithBool:YES]};
    NSError *error;
    SCNScene *scene = [SCNScene sceneWithURL:openPanel.URLs[0] options:dic error:&error];
    

    for (SCNNode *child in scene.rootNode.childNodes) {
        [_scene.rootNode addChildNode:child];
    }

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

-(IBAction)actLoad3djsFile:(id)sender
{
	static int ident = 0;
	
	NSOpenPanel* openPanel = [[NSOpenPanel alloc] init];
	[openPanel runModal];

	NSURL *srcUrl =openPanel.URLs[0];
	M3DX3djsLoader *loader = [[M3DX3djsLoader alloc] init];
	NSString *sceneKey = [NSString stringWithFormat:@"Scene%d",ident++];

	M3DXScene *sc = [loader loadFromUrl:srcUrl];
	[_scenes setValue:sc forKey:sceneKey];
	
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
    SCNNode *spotLightNode = [SCNNode node];
    spotLightNode.light = spotLight;
    spotLightNode.position = SCNVector3Make(10, 30, 0);

    [_scene.rootNode addChildNode:spotLightNode];
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
    
    self._camera = [[SCNNode alloc] init];
    self._camera.camera = camera;
    self._camera.position = SCNVector3Make(30, 30, 30);
    
    [_scene.rootNode addChildNode:self._camera];
    self.viewPerspective.pointOfView.camera = camera;
}

-(IBAction)actAddBox:(id)sender {
    SCNBox *box = [[SCNBox alloc] init];
    box.width = 20.f;
    box.height = 20.f;
    box.length = 20.f;
    box.chamferRadius = 0;
    self._box = [[SCNNode alloc] init];
    self._box.geometry = box;
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSImage imageNamed:@"checker.jpg"];
    self._box.geometry.materials = [[NSArray alloc] initWithObjects:material, nil];
    [_scene.rootNode addChildNode:self._box];
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
