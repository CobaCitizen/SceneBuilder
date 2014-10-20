//
//  M3DX3djsLoader.m
//  TestSceneKit
//
//  Created by Vasyl Bukshovan on 20/10/14.
//  Copyright (c) 2014 cobasoft. All rights reserved.
//
#import <SceneKit/SceneKit.h>
#import "M3DX3djsLoader.h"
#import "M3DXCoder.h"


@implementation M3DX3djsLoader

-(void)unpackTextures:(NSDictionary*)texturesData toFolder:(NSString*)texturesFolder
{
	
	//Если нет данных текстур - нечего сохранять
	if (!texturesData)
	{
		return;
	}
	
	NSError *error = nil;
	
	if(![[NSFileManager defaultManager] createDirectoryAtPath:texturesFolder withIntermediateDirectories:YES attributes:nil error:&error])
	{
		NSLog(@"Failed to create directory \"%@\". Error: %@", texturesFolder, error);
	}
	
	for (NSString* theKey in texturesData.allKeys)
	{
		
		//Получить путь к файлу с текстурой, theKey - имя файла
		NSString* theOutputFilePath = [texturesFolder stringByAppendingPathComponent:theKey];
		
		//Если файл уже создан - не пересоздавать его
		if ([[NSFileManager defaultManager] fileExistsAtPath:theOutputFilePath]) continue;
		
		//Получить закодированный в base64 файл текстуры
		NSString* theTextureBase64String = texturesData[theKey];
		
		//Разделить base64 строку на заголовок с общими данными и тело
		NSArray* theBase64Components = [theTextureBase64String componentsSeparatedByString:@";base64,"];
		//NSString* theBase64Header = theBase64Components[0];
		NSString* theBase64Body = theBase64Components[1];
		
		//Преобразовать тело base64 строки в NSData
		NSData* theFileData = [[NSData alloc] initWithBase64EncodedString:theBase64Body options:NULL];
		
		[theFileData writeToFile:theOutputFilePath atomically:YES];
	}
	
}
- (SCNGeometry*)loadGeomatry:(NSDictionary *)dic
{
	
	//--Decode faces type
	if(dic[@"faceType"])
	{
		//NSLog(@"1.faceType : %@",dic[@"faceType"]);
	}
	
	//--Decode vertices
	NSMutableArray* theVertices = dic[@"vertices"];
	SCNVector3 *vertices = malloc(sizeof(SCNVector3) *theVertices.count);
	SCNVector3 *p = vertices;
	
	long verticesCount =theVertices.count/3;
	
	for(int i=0; i < theVertices.count;i+=3)
	{
		p->x =[theVertices[i] floatValue];
		p->y =[theVertices[i+1] floatValue];
		p->z = [theVertices[i+2] floatValue];
		p++;
	}
	
	SCNGeometrySource *vertexSource =[SCNGeometrySource geometrySourceWithVertices:vertices count:verticesCount];
	
	//--Decode face indices
	NSMutableArray* theIndices = dic[@"faces"];
	int *indices = malloc(sizeof(int) * theIndices.count);
	int *pi = indices;
	
	long indicesCount = theIndices.count/3;
	
	for (int i=0; i<theIndices.count; i++)
	{
		pi[i] = (int)[theIndices[i] integerValue];
	}
	NSData *indexData = [NSData dataWithBytes:indices  length:sizeof(int) * theIndices.count];
	
	SCNGeometryElement *element =
	[SCNGeometryElement geometryElementWithData:indexData
								  primitiveType:SCNGeometryPrimitiveTypeTriangles
								 primitiveCount:indicesCount
								  bytesPerIndex:sizeof(int)];
	
	
	
	NSMutableArray* theNormals = dic[@"normals"];
	SCNVector3 *normals = malloc(sizeof(SCNVector3) *theNormals.count);
	p = normals;
	
	long normalsCount =theNormals.count/3;
	
	for(int i=0; i < theNormals.count;i+=3)
	{
		p->x =[theNormals[i] floatValue];
		p->y =[theNormals[i+1] floatValue];
		p->z =[theNormals[i+2] floatValue];
		p++;
	}
	

	SCNGeometrySource *normalSource =[SCNGeometrySource geometrySourceWithNormals:normals count:normalsCount];

	
	SCNGeometry *geometry =	[SCNGeometry geometryWithSources:@[vertexSource, normalSource] elements:@[element]];
	/*
	//--Decode normals
	NSMutableArray* theNormals = dic[@"normals"];
	float* dataNormals = malloc(sizeof(float)*theNormals.count);
	for(int i=0; i<theNormals.count;i++)
	{
		dataNormals[i] = [theNormals[i] floatValue];
	}
	NSData* _normals = [NSData dataWithBytesNoCopy:dataNormals length:sizeof(float)*theNormals.count];
	
	//--Decode UVs coord types
	NSArray* theUVTypes = dic[@"uvsTypes"];
	NSMutableArray* theUVsTypesAll = [NSMutableArray array];
	for (NSString* theUVTypeString in theUVTypes)
	{
		//wwM3DTypeUVCoords theUVCoordType = (M3DTypeUVCoords)[[[M3DGeometry uvsTypesMap] allKeysForObject:	theUVTypeString][0] integerValue];
		//[theUVsTypesAll addObject:@(theUVCoordType)];
	}
	
	//--Decode UVs coords
	NSArray* theUVs = dic[@"uvs"];
	//Для каждого текстурного канала - создать NSData с float значениями координат
	for (NSArray* theUVsArray in theUVs)
	{
		if (theUVsArray.count == 0) continue;
		
		//Создать и заполнить буфер с UV координатами
		float* theUVsBuf = malloc(sizeof(float)*theUVsArray.count);
		for (int i=0; i<theUVsArray.count; i++)
			theUVsBuf[i] = [theUVsArray[i] floatValue];
		
		//Создать NSData с UV координатами
		NSData* theUVsData = [NSData dataWithBytesNoCopy:theUVsBuf length:sizeof(float)*theUVsArray.count];
		
		//ww/NSUInteger theCurChannel = self.countUVChannels;
		//Создать канал текстуры из UV-координат и типа UV-координат
		//w[self addUVCoords:theUVsData coordsType:(M3DTypeUVCoords)[theUVsTypesAll[theCurChannel] integerValue]];
	}
	*/
	return geometry;
}
-(SCNNode*)loadNode:(NSDictionary *)dic withScene:(M3DXScene *)scene
{
	SCNNode* node = [[SCNNode alloc] init];
	
	if (dic[@"transform"])
	{

		//  setTransform:[M3DObject decodeGLKMatrix4ForKey:@"transform" withDictionary:dic]
		NSArray *arrTrans = dic[@"transform"];
		[node setTransform:[M3DXCoder CATransform3DFromNSArray:arrTrans]];
	}
	else
	{
		//Decode separate node transforms
		if (dic[@"piv"])
		{
			//ww[node setPivot:<#(CATransform3D)#> setPivot:[M3DObject decodeGLKVector3ForKey:@"piv" withDictionary:dic] ];
		}
		if (dic[@"scl"])
		{
			//CATransform3D value = CATransform3DMakeScale(<#CGFloat sx#>, <#CGFloat sy#>, <#CGFloat sz#>)
			//[self setScale:[M3DObject decodeGLKVector3ForKey:@"scl" withDictionary:dic]];
		}
		if (dic[@"pos"])
		{
			//[self setPosition:[M3DObject decodeGLKVector3ForKey:@"pos" withDictionary:dic]];
		}
		if (dic[@"rot"])
		{
			//[self setRotation:[M3DObject decodeGLKVector4ForKey:@"rot" withDictionary:dic]];
		}
	}
	
	if(dic[@"camera"])
	{
		//_camera = [[M3DCamera alloc] initWithDictionary:dic[@"camera"]];
	}
	if(dic[@"light"])
	{
		//_light = [[M3DLight alloc] initWithDictionary:dic[@"light"]];
	}
	if(dic[@"sceneObj"])
	{
		NSInteger ident = [M3DXCoder decodeIntegerForKey:@"mesh" withDictionary:dic[@"sceneObj"]] ;
		NSString *key = [NSString stringWithFormat:@"K%ld",ident];
		node.geometry = [scene.geomatries objectForKey:key];
		NSArray *matList =dic[@"sceneObj"][@"matList"];
		NSMutableArray *materials = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < matList.count;i++)
		{
			NSString *key = [NSString stringWithFormat:@"K%ld", [[matList objectAtIndex:i] integerValue]];
			M3DXMaterial *m  = [scene.materials objectForKey:key];
			if(m)
			{
				node.geometry.materials = [[NSArray alloc] initWithObjects:m.scnMaterial, nil];
				node.geometry.firstMaterial =m.scnMaterial;
				break;
			}
		}
		
//	    node.geometry.materials = [[NSArray alloc] initWithArray:materials];
		//_sceneObj = [[M3DSceneObject alloc]initWithDictionary:dic[@"sceneObj"]];
	}
	
	if(dic[@"child"])
	{
		//Decode child nodes
		NSArray *childs =dic[@"child"];
		for (NSMutableDictionary* item in childs)
		{
			SCNNode *child = [self loadNode:item withScene:scene];
			[node addChildNode:child];
		//	M3DNode *child = [[M3DNode alloc] initWithDictionary:item];
		//	[self addChildNode:child];
		}
	}
  return node;
}
-(M3DXScene*)loadFromUrl:(NSURL*)srcUrl
{

	NSString* theFileName = [[srcUrl path] stringByDeletingPathExtension];
	NSString *texturePath = [NSString stringWithFormat:@"%@/textures/",theFileName];

	M3DXScene* scene = [[M3DXScene alloc]init];

	scene.scnScene = [[SCNScene alloc]init];
	
	scene.geomatries = [NSMutableDictionary dictionary];
	scene.materials = [NSMutableDictionary dictionary];
	scene.textures = [NSMutableDictionary dictionary];
	
	NSError* error;
	
	NSString* json = [NSString stringWithContentsOfFile:[srcUrl path]
											   encoding:NSUTF8StringEncoding
												  error:&error];
	
	if (error)
	{
		NSLog(@"[M3DModelMain] openScene error accured: %@", [error localizedDescription]);
		return nil;
	}
	
	NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
														 options: NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
														   error:&error];
	
	
	if (error)
	{
		NSLog(@"[M3DModelMain] openScene error accured: %@", [error localizedDescription]);
		return nil;
	}

	[self unpackTextures: dic[@"TexturesData"] toFolder:texturePath];
	
	
	NSMutableDictionary *data = dic[@"Metadata"];
	//_metadata = [[M3DSceneMetadata alloc] initWithDictionary:data];
	
	NSArray *arr = dic[@"Textures"];
	int i = 0;
	for(NSMutableDictionary *item in arr)
	{
		M3DXImage *img = [[M3DXImage alloc] init];
		img.ident = [M3DXCoder decodeIntegerForKey:@"id" withDictionary:item] ;
		NSString *key = [NSString stringWithFormat:@"K%ld",img.ident];
		NSString *file = item[@"files"][0];
		img.path = [NSString stringWithFormat:@"%@%@",texturePath,file];

		img.image = [[NSImage alloc] initWithContentsOfFile:img.path];
		
		[scene.textures setValue:img forKey:key];
		
		//M3DTexture *texture = [[M3DTexture alloc] initWithDictionary:item andTextureFolder:texturesFolder];
		//[artextures setObject:texture atIndexedSubscript:i++];
	//	[texture bindWithScene:self];
	//	[_textures addObject:texture];
		//[self registerTexture:texture];
	}
	
	//_textures = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"Textures"]];

	NSArray *materials = dic[@"Materials"];
	for(NSMutableDictionary *item in materials)
	{
		M3DXMaterial *material = [[M3DXMaterial alloc]init];
		M3DXImage *img;
		
		material.ident = [M3DXCoder decodeIntegerForKey:@"id" withDictionary:item] ;
		material.specularMap = [M3DXCoder decodeIntegerForKey:@"specularMap" withDictionary:item] ;
		material.normalMap = [M3DXCoder decodeIntegerForKey:@"normalMap" withDictionary:item] ;
		material.bumpMap = [M3DXCoder decodeIntegerForKey:@"bumpMap" withDictionary:item] ;
		material.diffuseMap = [M3DXCoder decodeIntegerForKey:@"diffuseMap" withDictionary:item];

		NSInteger ident = [M3DXCoder decodeIntegerForKey:@"id" withDictionary:item] ;
		NSString *key = [NSString stringWithFormat:@"K%ld",ident];
		
		material.scnMaterial = [SCNMaterial material];
		
		NSString *imgKey = [NSString stringWithFormat:@"K%ld",material.diffuseMap];
		img = [scene.textures objectForKey:imgKey];
		if(img)
		{
			material.scnMaterial.diffuse.contents = img.image;
		}
		imgKey = [NSString stringWithFormat:@"K%ld",material.specularMap];
		img = [scene.textures objectForKey:imgKey];
		if(img)
		{
			material.scnMaterial.specular.contents = img.image;
		}
		imgKey = [NSString stringWithFormat:@"K%ld",material.normalMap];
		img = [scene.textures objectForKey:imgKey];
		if(img)
		{
			//material.scnMaterial.normal.contents = img.image;
		}
		[scene.materials setValue:material forKey:key];

	}
	
	//ww/_materials = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"Materials"]];
	arr = dic[@"Geometries"];
	for(NSMutableDictionary *item in arr)
	{
		NSInteger ident = [M3DXCoder decodeIntegerForKey:@"id" withDictionary:item] ;
		NSString *key = [NSString stringWithFormat:@"K%ld",ident];
		SCNGeometry *geometry = [self loadGeomatry:item];
		[scene.geomatries setValue:geometry forKey:key];
	}
	//_geometries = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"Geometries"]];
	/*
	arr = dic[@"SkinControllers"];
	for(NSMutableDictionary *item in arr)
	{
		M3DSkinController *skin = [[M3DSkinController alloc] initWithDictionary:item];
		[_skinControllers addObject:skin];
	}
	 */
	arr = dic[@"Scene"];
	
	id sc = dic[@"Scene"];
	if([sc isKindOfClass:[NSArray class]])
	{
		for(NSMutableDictionary *item in arr)
		{
			SCNNode *node = [self loadNode:item withScene:scene];
			[scene.scnScene.rootNode addChildNode:node];
		}
	}
	else
	{
		SCNNode *node = [self loadNode:sc withScene:scene];
//		for (M3DNode* node in parent.childNodes)
//		{
//			[_rootNode addChildNode:node];
//			[node bindWithScene:self];
//		}
	}
	/*
	for (M3DSkinController* theSkinController in _skinControllers)
	{
		[theSkinController bindWithScene:self];
	}
	
	for(M3DTexture *texture in artextures)
	{
		[self registerTexture:texture];
	}
	
	BOOL isSkinStructValide = YES;//ww/+
	
	//_skinControllers = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"SkinControllers"]];
	if (dic[@"SkyBox"])
	{
		_skyBox = [[M3DSkyBox alloc] initWithDictionary:dic[@"SkyBox"]];
		if (_skyBox)
		{
			[_skyBox bindWithScene:self];
		}
	}
	
	//Wrap lights to primitives
	NSArray* theLightNodes = [_rootNode childNodesPassingTest:^BOOL(M3DNode *child, BOOL *stop) {
		return (nil != child.light);
	}];
	for (M3DNode* theLightNode in theLightNodes)
		[self wrapLightNodeToPrimitive:theLightNode];
	
	//Wrap cameras to primitives
	NSArray* theCameraNodes = [_rootNode childNodesPassingTest:^BOOL(M3DNode *child, BOOL *stop) {
		return (nil != child.camera);
	}];
	
	for (M3DNode* theCameraNode in theCameraNodes){
		M3DNode *theNewCameraNode = [self wrapCameraNodeToPrimitive:theCameraNode];
		
		//Назначить камеру по умолчанию
		if (theNewCameraNode.camera.mID == _metadata.defaultCameraID)
			_defaultCamera = theNewCameraNode;
	}
	
	
	//Обновить доп. информацию в скелетных моделях
	if(isSkinStructValide)//ww/+
	{
		[self isolateSkeletonModelRoots];
	}
*/
	return scene;
}

@end
