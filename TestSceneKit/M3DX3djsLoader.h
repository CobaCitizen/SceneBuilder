//
//  M3DX3djsLoader.h
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 20/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3DXMaterial.h"
#import "M3DXImage.h"
#import "M3DXScene.h"

@interface M3DX3djsLoader : NSObject

-(M3DXScene*)loadFromUrl:(NSURL*)srcUrl;

@end
