//
//  AppDelegate.h
//  ProductBaseClasses
//
//  Created by 花落永恒 on 2017/7/17.
//  Copyright © 2017年 划落永恒. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

