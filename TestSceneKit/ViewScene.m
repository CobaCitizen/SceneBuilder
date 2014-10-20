//
//  ViewScene.m
//  TestSceneKit
//
//  Created by Coba on 10/20/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//

#import "ViewScene.h"

@implementation ViewScene

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}


- (void)mouseDown:(NSEvent *)theEvent {
    
    CGPoint p = [self convertPoint:theEvent.locationInWindow fromView: nil];
    NSDictionary* options = @{SCNHitTestSortResultsKey : [NSNumber numberWithBool:YES], SCNHitTestBoundingBoxOnlyKey : [NSNumber numberWithBool:YES]};
    
    NSArray *hitResults = [self hitTest:p options: options];
    
    SCNNode* selectedNode = nil;
    if (hitResults.count > 0){

        id result = hitResults[0];
        if([result isKindOfClass:[SCNHitTestResult class]]) {
            SCNHitTestResult* selection = result;
            selectedNode = selection.node;
            SCNMaterial *material = [SCNMaterial material];
            material.diffuse.contents = [NSColor redColor];
            selectedNode.geometry.firstMaterial = material;
        }
    }
    [self.delegate selectionNodeDidChanged:selectedNode];
    [super mouseDown:theEvent];
}
@end
