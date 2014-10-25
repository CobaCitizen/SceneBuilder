//
//  ViewScene.h
//  TestSceneKit
//
//  Created by Coba on 10/20/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@protocol ViewSceneDelegate;

@interface ViewScene : SCNView
@property (nonatomic,retain) NSString *strTransformMode;

@property (nonatomic, retain) id<ViewSceneDelegate> delegate;
@end

@protocol ViewSceneDelegate <NSObject>
-(void)selectionNodeDidChanged:(SCNNode*)selectedNode;
-(void)transformModeDidChanged:(NSString*)text;
@end