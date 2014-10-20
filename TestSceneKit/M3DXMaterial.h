//
//  M3DXMaterial.h
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 20/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface M3DXMaterial : NSObject

@property (nonatomic) NSInteger ident;
@property (nonatomic) NSInteger specularMap;
@property (nonatomic) NSInteger normalMap;
@property (nonatomic) NSInteger bumpMap;
@property (nonatomic) NSInteger diffuseMap;
@property (nonatomic) SCNMaterial *scnMaterial;

@end
