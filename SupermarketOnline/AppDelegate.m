//
//  AppDelegate.m
//  SupermarketOnline
//
//  Created by LYD on 16/10/24.
//  Copyright © 2016年 lyd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Core Data 相关操作
- (void)insertCoreDataWithObjectItem:(NSDictionary *)objectDict
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    CityDistrictsCoreObject *cityDistricts = [NSEntityDescription insertNewObjectForEntityForName:@"CityDistrictsCoreObject" inManagedObjectContext:context];
    cityDistricts.isopen = STRING(objectDict[@"isopen"]);
    cityDistricts.areaId = STRING(objectDict[@"areaId"]);
    cityDistricts.areaName = STRING(objectDict[@"areaName"]);
    cityDistricts.pyName = STRING(objectDict[@"pyName"]);
    cityDistricts.level = STRING(objectDict[@"level"]);
    cityDistricts.current_code = STRING(objectDict[@"current_code"]);
    cityDistricts.parentID = STRING(objectDict[@"parentID"]);
    
    NSError *error;
    if(![context save:&error])
    {
        NSLog(@"不能保存：%@",[error localizedDescription]);
    }
}

- (void) deleteAllObjects
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityDistrictsCoreObject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [_managedObjectContext deleteObject:managedObject];
    }
    if (![self.managedObjectContext save:&error]) {
    }
}

- (NSArray *) selectAllCoreObject    //读取数据库中所有数据
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityDistrictsCoreObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"pyName" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"[fetchedObjects count]:%lu",(unsigned long)[fetchedObjects count]);
    //    for (CityDistrictsCoreObject *cityDistricts in fetchedObjects) {
    //
    //        NSLog(@"isopen: %@", cityDistricts.isopen);
    //        NSLog(@"areaId: %@", cityDistricts.areaId);
    //        NSLog(@"areaName: %@", cityDistricts.areaName);
    //        NSLog(@"pyName: %@", cityDistricts.pyName);
    //        NSLog(@"level: %@", cityDistricts.level);
    //        NSLog(@"current_code: %@", cityDistricts.current_code);
    //        NSLog(@"parentID: %@", cityDistricts.parentID);
    //    }
    //    CityDistrictsCoreObject *cityDistricts = [fetchedObjects firstObject];
    //    NSLog(@"isopen: %@", cityDistricts.isopen);
    //    NSLog(@"areaId: %@", cityDistricts.areaId);
    //    NSLog(@"areaName: %@", cityDistricts.areaName);
    //    NSLog(@"pyName: %@", cityDistricts.pyName);
    //    NSLog(@"level: %@", cityDistricts.level);
    //    NSLog(@"current_code: %@", cityDistricts.current_code);
    //    NSLog(@"parentID: %@", cityDistricts.parentID);
    //
    //    CityDistrictsCoreObject *cityDistricts2 = [fetchedObjects lastObject];
    //    NSLog(@"isopen2: %@", cityDistricts2.isopen);
    //    NSLog(@"areaId2: %@", cityDistricts2.areaId);
    //    NSLog(@"areaName2: %@", cityDistricts2.areaName);
    //    NSLog(@"pyName2: %@", cityDistricts2.pyName);
    //    NSLog(@"level2: %@", cityDistricts2.level);
    //    NSLog(@"current_code2: %@", cityDistricts2.current_code);
    //    NSLog(@"parentID2: %@", cityDistricts2.parentID);
    
    return fetchedObjects;
}

- (NSArray *) selectDataWithLevel:(NSString*)level {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityDistrictsCoreObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //[fetchRequest setFetchLimit:1];
    //[fetchRequest setFetchBatchSize:1];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(level = %@)",level];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"pyName" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

- (CityDistrictsCoreObject *) selectDataWithName:(NSString*)name {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityDistrictsCoreObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //[fetchRequest setFetchLimit:1];
    //[fetchRequest setFetchBatchSize:1];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(areaName = %@)",name];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"pyName" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects firstObject];
}

- (NSArray *) selectDataWithParentID:(NSString*)parentID {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityDistrictsCoreObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //[fetchRequest setFetchLimit:1];
    //[fetchRequest setFetchBatchSize:1];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentID = %@)",parentID];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"pyName" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
