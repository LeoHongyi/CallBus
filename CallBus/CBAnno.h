//
//  CBAnno.h
//  CallBus
//
//  Created by hongyi liu on 16/3/12.
//  Copyright © 2016年 hongyi liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface CBAnno : NSObject<MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;



// Title and subtitle for use by selection UI.
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


@end
