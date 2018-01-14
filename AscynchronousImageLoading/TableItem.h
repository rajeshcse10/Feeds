//
//  TableItem.h
//  AscynchronousImageLoading
//
//  Created by Rajesh's MacBook Pro  on 1/13/18.
//  Copyright © 2018 MacBook Pro Retina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableItem : NSObject
@property (nonatomic,strong) NSNumber *itemId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *profieImageUrl;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *statusImageUrl;
@property (nonatomic,assign) int64_t timeStamp;
@property (nonatomic,strong) NSString *url;
@end
