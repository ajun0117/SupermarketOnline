//
//  MJRefreshConst.m
//  MJRefresh
//
//  Created by mj on 14-1-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

const CGFloat MJRefreshViewHeight = 64.0;
const CGFloat MJRefreshFastAnimationDuration = 0.25;
const CGFloat MJRefreshSlowAnimationDuration = 0.4;

NSString *const MJRefreshFooterPullToRefresh = @"加载更多...";//上拉可以加载更多数据
NSString *const MJRefreshFooterReleaseToRefresh = @"加载更多...";
NSString *const MJRefreshFooterRefreshing = @"加载更多...";

NSString *const MJRefreshHeaderPullToRefresh = @"下拉可以刷新";
NSString *const MJRefreshHeaderReleaseToRefresh = @"松开立即刷新";
NSString *const MJRefreshHeaderRefreshing = @"努力加载中...";
NSString *const MJRefreshHeaderTimeKey = @"MJRefreshHeaderView";

NSString *const MJRefreshContentOffset = @"contentOffset";
NSString *const MJRefreshContentSize = @"contentSize";