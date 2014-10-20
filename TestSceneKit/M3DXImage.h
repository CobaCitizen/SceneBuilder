//
//  M3DXImage.h
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 20/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3DXImage : NSObject

@property (nonatomic) NSInteger ident;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,retain) NSImage *image;

@end
