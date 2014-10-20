//
//  M3DXScene.h
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 20/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface M3DXScene : NSObject

@property (nonatomic) SCNScene* scnScene;
@property (nonatomic,retain) NSMutableDictionary *geomatries;
@property (nonatomic,retain) NSMutableDictionary *materials;
@property (nonatomic,retain) NSMutableDictionary *textures;


@end
