//
//  AppDelegate.h
//  SupermarketOnline
//
//  Created by LYD on 16/10/24.
//  Copyright © 2016年 lyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CityDistrictsCoreObject.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)insertCoreDataWithObjectItem:(NSDictionary *)objectDict;
- (void) deleteAllObjects;
- (NSArray *) selectAllCoreObject;
- (NSArray *) selectDataWithLevel:(NSString*)level;
- (CityDistrictsCoreObject *) selectDataWithName:(NSString*)name;   //通过城市名获取需要的对象
- (NSArray *) selectDataWithParentID:(NSString*)parentID;  //通过父ID获取需要的对象


@end

