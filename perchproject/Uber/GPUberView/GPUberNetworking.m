//
//  GPUberNetworking.m
//  GPUberViewDemo
//
//  Created by George Polak on 2/9/15.
//  Copyright (c) 2015 George Polak. All rights reserved.
//

#import "GPUberNetworking.h"
#import "AFNetworking.h"
#import "JSONModel.h"
#import "GPUberPrice.h"
#import "GPUberProduct.h"
#import "GPUberTime.h"

@implementation GPUberNetworking

NSString *const GP_UBER_VIEW_DOMAIN = @"GP_UBER_VIEW_DOMAIN";

+ (NSURL *)urlWithEndpoint:(NSString *)endpoint {
    NSString *base = @"https://api.uber.com";
    NSURL *baseURL = [NSURL URLWithString:base];
    return [NSURL URLWithString:endpoint relativeToURL:baseURL];
}

+ (NSError *)errorWithError:(NSError *)oldError operation:(AFHTTPRequestOperation *)operation {
    // preserve original values
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:oldError.userInfo];
    [userInfo setObject:[NSNumber numberWithInteger:oldError.code] forKey:@"original_status"];
    
    // add sane status code
    NSError *error = [NSError errorWithDomain:oldError.domain
                                         code:operation.response.statusCode
                                     userInfo:userInfo];
    
    return error;
}

+ (BFTask *)GETWithEndpoint:(NSString *)endpoint serverToken:(NSString *)serverToken params:(NSDictionary *)params {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:[NSString stringWithFormat:@"Token %@", serverToken] forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = requestSerializer;
    
    NSURL *url = [self urlWithEndpoint:endpoint];
    
    [manager GET:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {        
        if ([responseObject isKindOfClass:[NSDictionary class]] || [responseObject isKindOfClass:[NSArray class]]) {
            [taskSource setResult:responseObject];
        } else {
            NSError *error = [NSError errorWithDomain:@"GPUberView"
                                                 code:0
                                             userInfo:[NSDictionary dictionaryWithObject:@"unable to parse response" forKey:NSLocalizedDescriptionKey]];
            [taskSource setError:error];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // translate error
        NSError *translatedError = [self errorWithError:error operation:operation];
        [taskSource setError:translatedError];
    }];
    
    return taskSource.task;
}

+ (BFTask *)productsForStart:(CLLocationCoordinate2D)start serverToken:(NSString *)serverToken {
    NSString *endpoint = @"v1/products";
    
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    NSDictionary *params = @{@"latitude": [NSNumber numberWithDouble:start.latitude],
                             @"longitude": [NSNumber numberWithDouble:start.longitude]
                             };
    
    [[self GETWithEndpoint:endpoint serverToken:serverToken params:params] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"%@", task.error);
            [taskSource setError:task.error];
        } else {
            NSMutableArray *products = [NSMutableArray new];
            NSArray *rawProducts = [task.result objectForKey:@"products"];
            for (NSDictionary *rawProduct in rawProducts) {
                NSError *error;
                GPUberProduct *product = [[GPUberProduct alloc] initWithDictionary:rawProduct error:&error];
                if (error)
                    NSLog(@"unable to parse product element:%@", error);
                else
                    [products addObject:product];
            }
            
            [taskSource setResult:products];
        }
        
        return nil;
    }];
    
    return taskSource.task;
}

+ (BFTask *)pricesForStart:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end serverToken:(NSString *)serverToken {
    NSString *endpoint = @"v1/estimates/price";
    
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    NSDictionary *params = @{@"start_latitude": [NSNumber numberWithDouble:start.latitude],
                             @"start_longitude": [NSNumber numberWithDouble:start.longitude],
                             @"end_latitude": [NSNumber numberWithDouble:end.latitude],
                             @"end_longitude": [NSNumber numberWithDouble:end.longitude]};
    
    [[self GETWithEndpoint:endpoint serverToken:serverToken params:params] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"%@", task.error);
            [taskSource setError:task.error];
        } else {
            NSMutableArray *prices = [NSMutableArray new];
            NSArray *rawPrices = [task.result objectForKey:@"prices"];
            for (NSDictionary *rawPrice in rawPrices) {
                NSError *error;
                GPUberPrice *price = [[GPUberPrice alloc] initWithDictionary:rawPrice error:&error];
                if (error)
                    NSLog(@"unable to parse price element:%@", error);
                else
                    [prices addObject:price];
            }
            
            [taskSource setResult:prices];
        }
        
        return nil;
    }];
    
    return taskSource.task;
}

+ (BFTask *)timeEstimatesForStart:(CLLocationCoordinate2D)start serverToken:(NSString *)serverToken {
    NSString *endpoint = @"v1/estimates/time";
    
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    NSDictionary *params = @{@"start_latitude": [NSNumber numberWithDouble:start.latitude],
                             @"start_longitude": [NSNumber numberWithDouble:start.longitude]
                             };
    
    [[self GETWithEndpoint:endpoint serverToken:serverToken params:params] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"%@", task.error);
            [taskSource setError:task.error];
        } else {
            NSMutableArray *times = [NSMutableArray new];
            NSArray *rawTimes = [task.result objectForKey:@"times"];
            for (NSDictionary *rawTime in rawTimes) {
                NSError *error;
                GPUberTime *time = [[GPUberTime alloc] initWithDictionary:rawTime error:&error];
                if (error)
                    NSLog(@"unable to parse time element:%@", error);
                else
                    [times addObject:time];
            }
            
            [taskSource setResult:times];
        }
        
        return nil;
    }];
    
    return taskSource.task;
}

@end
