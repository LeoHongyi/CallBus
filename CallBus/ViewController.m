//
//  ViewController.m
//  CallBus
//
//  Created by hongyi liu on 16/3/12.
//  Copyright (c) 2016年 hongyi liu. All rights reserved.
//
//To do
/**
 1. annotation deploy on the map
 2. navigation route
 3. call system map
 */
#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD+HM.h"
#import "CBAnno.h"


@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *navBtn;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(strong,nonatomic) CLLocationManager *lM;
@property (weak, nonatomic) IBOutlet UITextField *destionationField;
@property(nonatomic,strong)CLGeocoder *geocoder;


@property(nonatomic,strong)CLLocation *startLoc;
@property(nonatomic,strong)CLLocation *endLoc;

@property(nonatomic,strong)CLPlacemark *startCLPlacemark;
@property(nonatomic,strong)CLPlacemark *endCLPlacemark;
@property(nonatomic,strong)NSString *expected;
@property(nonatomic,strong)CBAnno *anno1;
@property(nonatomic,strong)CBAnno *anno2;
@property(nonatomic,strong)CBAnno *anno3;
@property(nonatomic,strong)CBAnno *anno4;
@property(nonatomic,strong)MKPolyline *polyline;
@property (weak, nonatomic)IBOutlet UILabel *expeectedTime;
@property(nonatomic,assign)BOOL res;
@property(nonatomic,strong)NSArray *locArr;
@property(nonatomic,strong)NSArray *annoArr;
@property(nonatomic,assign)int i;
@property(nonatomic,assign)float deltaI;





@end

@implementation ViewController

-(CLLocationManager *)lM
{
    if (!_lM) {
        _lM = [[CLLocationManager alloc]init];
        if([_lM respondsToSelector:@selector(requestAlwaysAuthorization)]){
           _lM.delegate = self;
           _lM.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
           [_lM requestWhenInUseAuthorization];
        }
    }
    return _lM;
}



-(CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self lM];
    
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsTraffic = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    self.mapView.delegate = self;
    self.navBtn.enabled = NO;
    
    
    self.anno1= [[CBAnno alloc]init];
    self.anno1.coordinate = CLLocationCoordinate2DMake(40.746551, -74.2271787);
    CLLocation *loc1 = [[CLLocation alloc]initWithLatitude:self.anno1.coordinate.latitude longitude:self.anno1.coordinate.longitude];
    self.anno1.title = @"Destionation";
    [self.mapView addAnnotation:self.anno1];
    
    self.anno2= [[CBAnno alloc]init];
    self.anno2.coordinate = CLLocationCoordinate2DMake(40.747573,  -74.263375);
    CLLocation *loc2 = [[CLLocation alloc]initWithLatitude:self.anno2.coordinate.latitude longitude:self.anno2.coordinate.longitude];
    self.anno2.title = @"Destionation";
    [self.mapView addAnnotation:self.anno2];
    
    self.anno3= [[CBAnno alloc]init];
    self.anno3.coordinate = CLLocationCoordinate2DMake(40.746368,  -74.227077);
    CLLocation *loc3 = [[CLLocation alloc]initWithLatitude:self.anno3.coordinate.latitude longitude:self.anno3.coordinate.longitude];
    self.anno3.title = @"Destionation";
    [self.mapView addAnnotation:self.anno3];
    
    self.anno4 = [[CBAnno alloc]init];
    self.anno4.coordinate = CLLocationCoordinate2DMake(40.743400,  -74.176042);
    CLLocation *loc4 = [[CLLocation alloc]initWithLatitude:self.anno4.coordinate.latitude longitude:self.anno4.coordinate.longitude];
    self.anno4.title = @"Destionation";
    [self.mapView addAnnotation:self.anno4];
    
    self.locArr = @[loc1,loc2,loc3,loc4];
    self.annoArr = @[self.anno1,self.anno2,self.anno3,self.anno4];
    for(int i = 0;i < self.locArr.count;i++){
        NSLog(@"%@",self.locArr[i]);
    }

    //[self call:@"9737800848"];
   
    self.i = 0;
    self.deltaI = 0.0003;
    
   
}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
//    //获取系统默认定位的经纬度跨度
//    NSLog(@"维度跨度:%f,经度跨度:%f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
////    self.latitudeDelta = mapView.region.span.latitudeDelta;
////    self.longitudeDelta = mapView.region.span.longitudeDelta;
//}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.065404, 0.059154);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [self.mapView setRegion:region animated:YES];
    
    // self.count = 0;
    userLocation.title = @"current location";
   
    self.startLoc = userLocation.location;
    
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil) {
            CLPlacemark *placemark = [placemarks firstObject];
            
            self.startCLPlacemark = placemark;
            
           
                [self.geocoder reverseGeocodeLocation:self.locArr[self.i] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    NSLog(@"%@",self.locArr[self.i]);
                    if (error == nil) {
                        self.endCLPlacemark = [placemarks firstObject];
                       
                        [self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
                        
                        
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           
                            
                            NSLog(@"%d",[self.expected intValue]);
                            if ([self.expected intValue] <= 4 && (self.res == false) &&[self.expected intValue] >1 && self.i % 2== 0 ) {
                                [self call:@"862-368-8630"];
                                NSLog(@"434-806-3152");
                                NSLog(@"%d",self.res);
                                
                               
                            }
                            if ([self.expected intValue] <= 4 && (self.res == false) &&[self.expected intValue] >1 && self.i % 2 != 0) {
                                [self call:@"862-368-863011"];
                                //NSLog(@"434-806-3152");
                                NSLog(@"uuu 973-780-0848");
                                NSLog(@"%d",self.res);
                                
                            }
                            
                            
                            if ([self.expected intValue] <= 1 && self.res == true ) {
                                NSLog(@"new self I %d",self.i);
                                if (self.i < 4) {
                                    self.i += 1;
                                    NSLog(@"%d",self.i);
                                }
                                if (self.i == 4) {
                                    return;
                                }
                                //[self.mapView removeAnnotation:self.annoArr[self.i]];
                                self.res = false;
                                NSLog(@"refresh%d ", self.res);
                                
                                
                            }
                        });
                        
                        
                        
                    }
                }];
      
            
            
            
        
        }
    }];
    
    
    
    
    
}


//-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    self.endLoc = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
//   
//   // NSLog(@"%d",self.count);
//    //self.count = 0;
//    NSLog(@"select");
//    NSLog(@"select %d",self.res);
//    
//    
//    
//    [self.geocoder reverseGeocodeLocation:self.endLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        
//       
//        if (error == nil) {
//            CLPlacemark *endplacemark1 = [placemarks firstObject];
//            self.endCLPlacemark = endplacemark1;
//            
//            if (self.res == false) {
//                [self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
//                NSLog(@"start");
//                
//            }else {
//                [self startDirectionsWithstartCLPlacemark1:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
//                NSLog(@"start1");
//                
//            }
//            
//            
//            if (self.startCLPlacemark == self.endCLPlacemark) {
//                [self.mapView removeOverlay:self.polyline];
//                [self.mapView removeAnnotation:view.annotation];
//            }
//            
//            
//            
//        }
//    }];
//    
//    
//}















-(BOOL)textFieldShouldReturn:(UITextField *)textField
{

    self.navBtn.enabled = YES;
    
    [self.geocoder geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count == 0) return;
        
        self.endCLPlacemark = [placemarks firstObject];
        //self.coordinate = self.endCLPlacemark.location.coordinate;
        
        
        [self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
        CBAnno *anno = [[CBAnno alloc]init];
        anno.coordinate =  self.endCLPlacemark.location.coordinate;
        //anno.title = [NSString stringWithFormat:@"%@ min",self.expected];
        anno.title = @"destination";
        [self.mapView addAnnotation:anno];
        
    }];
    
    
    
    
    [self.view endEditing:YES];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.lM startUpdatingLocation];
    [self.view endEditing:YES];
    
}



-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) {
        NSLog(@"drag");
        NSLog(@"drag %d",self.res);
    //view.annotation.coordinate
        self.endLoc = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
        [self.geocoder reverseGeocodeLocation:self.endLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            
            if (error == nil) {
                CLPlacemark *endplacemark1 = [placemarks firstObject];
                self.endCLPlacemark = endplacemark1;
               // [self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
               // NSLog(@"%@",self.endCLPlacemark);
                NSLog(@"tttt-----%f",self.startCLPlacemark.location.coordinate.latitude - self.endCLPlacemark.location.coordinate.latitude);
                if (self.startCLPlacemark  == self.endCLPlacemark) {
                    //self.res = false;
                    [self.mapView removeOverlay:self.polyline];
                    NSLog(@"%d",self.res);
                   // [self.mapView removeAnnotation:view.annotation];
                    
                }
                
                if (self.startCLPlacemark == self.endCLPlacemark) {
                    [self.mapView removeOverlay:self.polyline];
                    self.endLoc = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
                    [self.geocoder reverseGeocodeLocation:self.endLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                        
                        
                        if (error == nil) {
                            CLPlacemark *endplacemark1 = [placemarks firstObject];
                            self.endCLPlacemark = endplacemark1;
                            NSLog(@"%@",self.endCLPlacemark);
                            NSLog(@"tttt-----%f",self.startCLPlacemark.location.coordinate.latitude - self.endCLPlacemark.location.coordinate.latitude);

                            
                            
                            
                            
                        }
                    }];
                }
                
                
                
            }
        }];
        
        
    }
    
}

-(void)startDirectionsWithstartCLPlacemark:(CLPlacemark *)startCLPlacemark endCLPlacemark:(CLPlacemark *)endCLPlacemark
{
    
    NSLog(@"1111111");
    MKPlacemark *startPlacemark = [[MKPlacemark alloc]initWithPlacemark:startCLPlacemark];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlacemark];
    
    MKPlacemark *endPlacemark = [[MKPlacemark alloc]initWithPlacemark:endCLPlacemark];
    //NSLog(@"endPlacemark is %@",endCLPlacemark);
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlacemark];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    
    request.source = startItem;
    
    request.destination = endItem;
    
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            self.expeectedTime.text = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime /60];
            self.expected = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime / 60];
           
        
//            if ([self.expected intValue] <= 1) {
//                //self.startCLPlacemark = self.endCLPlacemark;
//                self.res = false;
//            }
//            
//            if ([self.expected intValue] <= 5 && [self.expected intValue] > 0) {
//                
//                
//                
//                    self.res = true;
//
//                
//            } else {
//            
//                    self.res = false;
//            }
           
           
            
            
            
            if (self.polyline != nil) {
                [self.mapView removeOverlay:self.polyline];
            }
            
            
            self.polyline = obj.polyline;
            [self.mapView addOverlay:self.polyline];
            
            
        }];
    }];
    

}




-(void)startDirectionsWithstartCLPlacemark1:(CLPlacemark *)startCLPlacemark endCLPlacemark:(CLPlacemark *)endCLPlacemark
{
    
    NSLog(@"--------------------");
    NSLog(@"res is %d",self.res);
    MKPlacemark *startPlacemark = [[MKPlacemark alloc]initWithPlacemark:startCLPlacemark];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlacemark];
    
    MKPlacemark *endPlacemark = [[MKPlacemark alloc]initWithPlacemark:endCLPlacemark];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlacemark];
    
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    
    request.source = startItem;
    
    request.destination = endItem;
    
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            self.expeectedTime.text = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime /60];
            self.expected = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime / 60];
            if ([self.expected intValue] == 0) {
                //self.startCLPlacemark = self.endCLPlacemark;
                //self.res = false;
            }
            
            
            if (self.polyline != nil) {
                [self.mapView removeOverlay:self.polyline];
            }
            
            
            self.polyline = obj.polyline;
            [self.mapView addOverlay:self.polyline];
            
        }];
    }];
    

    
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay
{
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    
    render.lineWidth = 5;
    render.lineCap = kCGLineCapSquare;
    
    
    render.strokeColor = [UIColor blueColor];
    
    return render;
}




-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    static NSString *id = @"destination";
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:id];
    if (pin == nil) {

        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:id];
        
    }
    pin.pinTintColor = [UIColor greenColor];

  
    pin.canShowCallout = YES;
    pin.animatesDrop = YES;
    pin.draggable = YES;
    
    return pin;
}


- (IBAction)startNav:(id)sender {
    [self startNavigationWithCLPlacemark:self.startCLPlacemark  endCLPlacemark:self.endCLPlacemark];
    
}

-(void)startNavigationWithCLPlacemark:(CLPlacemark *)startCLPlacemark endCLPlacemark:(CLPlacemark *)endCLPlacemark
{
    MKPlacemark *startPlacemark = [[MKPlacemark alloc]initWithPlacemark:startCLPlacemark];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlacemark];

    MKPlacemark *endPlacemark = [[MKPlacemark alloc]initWithPlacemark:endCLPlacemark];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlacemark];


    NSArray *items = @[startItem,endItem];

    NSMutableDictionary *md = [NSMutableDictionary dictionary];

    md[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving;
    md[MKLaunchOptionsMapTypeKey] = @(MKMapTypeHybrid);

    [MKMapItem openMapsWithItems:items launchOptions:md];
}


- (void)call:(NSString*)phoneNum{
         
         self.res = true;
         NSLog(@"make call %@",phoneNum);
             NSURL *url  = [NSURL URLWithString:@"http://chuan.resource.campus.njit.edu:8080/MyWebAppTest/CallTest"];
             NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
             request.timeoutInterval = 5;
             request.HTTPMethod = @"post";
             NSString *param = [NSString stringWithFormat:@"number=%@",phoneNum];
             request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
             NSOperationQueue *queue = [NSOperationQueue mainQueue];
             [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         
                 NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                 NSLog(@"%@",str);
    
                     self.res = true;
            
                 
             }];
    

    
}




 

@end
