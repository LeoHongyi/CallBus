//
//  ViewController.m
//  CallBus
//
//  Created by hongyi liu on 16/3/12.
//  Copyright (c) 2016年 hongyi liu. All rights reserved.
//

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
@property(nonatomic,strong)CBAnno *anno;
@property(nonatomic,strong)MKPolyline *polyline;
@property (weak, nonatomic)IBOutlet UILabel *expeectedTime;


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
    self.anno = [[CBAnno alloc]init];
   
    self.mapView.showsUserLocation = YES;
    self.mapView.showsTraffic = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    self.mapView.delegate = self;
    self.navBtn.enabled = NO;
    
    
  
    
    
}



-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.054021, 0.040568);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [self.mapView setRegion:region];
    userLocation.title = @"current location";
    
    
    self.startLoc = userLocation.location;
    
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil) {
            CLPlacemark *placemark = [placemarks firstObject];
            
            self.startCLPlacemark = placemark;
            NSLog(@"%@",self.startCLPlacemark);
            
            if (self.endCLPlacemark != NULL) {
                [self startDirectionsWithstartCLPlacemark:placemark endCLPlacemark:self.endCLPlacemark];
            }
            
            
            if (self.startCLPlacemark == self.endCLPlacemark) {
                [self.mapView removeOverlay:self.polyline];
            }
        }
    }];
   
    
    
    
    
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{

    self.navBtn.enabled = YES;
    
    [self.geocoder geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count == 0) return;
        
        self.endCLPlacemark = [placemarks firstObject];
        //self.coordinate = self.endCLPlacemark.location.coordinate;
        [self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
        
        
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
        
    //view.annotation.coordinate
        self.endLoc = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
        [self.geocoder reverseGeocodeLocation:self.endLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            
            if (error == nil) {
                CLPlacemark *endplacemark1 = [placemarks firstObject];
                self.endCLPlacemark = endplacemark1;
                [self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
                
                if (self.startCLPlacemark == self.endCLPlacemark) {
                    [self.mapView removeOverlay:self.polyline];
                }
                
                
                
            }
        }];
        
        
        
        
        
        
        
//        [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
//            
//            if (error == nil) {
//                CLPlacemark *placemark = [placemarks firstObject];
//                
//                if (self.endCLPlacemark != NULL) {
//                    [self startDirectionsWithstartCLPlacemark:placemark endCLPlacemark:self.endCLPlacemark];
//                }
//                
//                
//                if (self.startCLPlacemark == self.endCLPlacemark) {
//                    [self.mapView removeOverlay:self.polyline];
//                }
//            }
//        }];

        
        //[self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
        
    }
    
}

-(void)startDirectionsWithstartCLPlacemark:(CLPlacemark *)startCLPlacemark endCLPlacemark:(CLPlacemark *)endCLPlacemark
{
    
    //NSLog(@"--------------------");
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
            NSLog(@"%f",obj.expectedTravelTime);
            
            //        self.expected = [NSString stringWithFormat:@"%@ sec",@(response.expectedTravelTime).stringValue];
            //        NSLog(@"%@",self.expected);
            NSLog(@"%f",obj.expectedTravelTime / 60);
            self.expeectedTime.text = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime /60];
            self.expected = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime / 60];
            if ([self.expected intValue] < 5) {
                [self call];
            }
            
            
            self.anno.coordinate =  endCLPlacemark.location.coordinate;
            // NSLog(@"%f,%f",self.coordinate.longitude,self.coordinate.latitude);
            //NSLog(@"%@",self.expected);
            self.anno.title = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime / 60];
            [self.mapView addAnnotation:self.anno];
            
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
    
    //NSLog(@"--------------------");
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
            NSLog(@"%f",obj.expectedTravelTime);
            
            
            NSLog(@"%f",obj.expectedTravelTime / 60);
            self.expeectedTime.text = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime /60];
            self.expected = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime / 60];
            
            
            self.anno.coordinate =  endCLPlacemark.location.coordinate;
           
            self.anno.title = [NSString stringWithFormat:@"%.1f min",obj.expectedTravelTime / 60];
            [self.mapView addAnnotation:self.anno];
            

            
            
        }];
    }];
    
    
   [self.mapView addAnnotation:self.anno];
    //    }];
    
    
    
    
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay
{
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    
    render.lineWidth = 5;
    render.lineCap = kCGLineCapSquare;
    
    
    render.strokeColor = [UIColor blueColor];
    
    return render;
}


//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
//{
//    MKPolylineView *thePolylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
//    thePolylineView.strokeColor = [UIColor purpleColor]; // <-- So important stuff here
//    thePolylineView.lineWidth = 10.0;
//    return thePolylineView;
//}

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


- (void)call{
//    NSURL *url  = [NSURL URLWithString:@"http://chuan.resource.campus.njit.edu:8080/MyWebAppTest/CallTest"];
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
//    request.timeoutInterval = 5;
//    request.HTTPMethod = @"post";
//    NSString *param = [NSString stringWithFormat:@"number=%s","8623688630"];
//    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
//    NSOperationQueue *queue = [NSOperationQueue mainQueue];
//    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        
//        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
//        
//    }];
    
    
    
    
    [MBProgressHUD showSuccess:@"success"];
    //NSLog(@"calling");
    

    
    
    
}




 

@end
