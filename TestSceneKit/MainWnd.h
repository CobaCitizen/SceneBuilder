//
//  MainWnd.h
//  TestSceneKit
//
//  Created by Coba on 10/19/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>
#import "ViewScene.h"

@interface MainWnd : NSWindow

@property (nonatomic, retain) IBOutlet SCNView* viewLeft;
@property (nonatomic, retain) IBOutlet SCNView* viewTop;
@property (nonatomic, retain) IBOutlet SCNView* viewBottom;
@property (nonatomic, retain) IBOutlet ViewScene* viewPerspective;
@property (nonatomic, retain) IBOutlet SCNView* cameraPreview;

@property (nonatomic, retain) IBOutlet NSPopUpButton* btnAnimations;
@property (nonatomic, retain) IBOutlet NSOutlineView* ovTree;

-(IBAction)actOpenFile:(id)sender;
-(IBAction)actAddCamera:(id)sender;
-(IBAction)actAddBox:(id)sender;
-(IBAction)actAddLight:(id)sender;
-(IBAction)actRemoveAllObjects:(id)sender;

- (IBAction)actPlay:(id)sender;
- (IBAction)actPause:(id)sender;
- (IBAction)actStop:(id)sender;

-(IBAction)setValueX:(id)sender;
@end


