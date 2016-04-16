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
@property(nonatomic,assign)BOOL res;


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
    //self.anno = [[CBAnno alloc]init];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsTraffic = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    self.mapView.delegate = self;
    self.navBtn.enabled = NO;
    //self.res = false;

    NSArray *locArr = @[@"573 S Clinton St East Orange NJ",@"11 N Ridgewood Rd South Orange NJ",@"573 S Clinton St East Orange NJ",@"16 Sussex Ave Newark NJ"];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    //CLGeocoder *geocoder1 = [[CLGeocoder alloc]init];
    //CLGeocoder *geocoder2 = [[CLGeocoder alloc]init];
    //NSArray *geocoders = @[geocoder1,geocoder2];
    
//    int i = 0;
   
    
    for (int i = 0; i < locArr.count; i++) {
         CLGeocoder *geocoder1 = [[CLGeocoder alloc]init];
        [arr addObject:geocoder1];
       // NSLog(@"%@",arr);
        //NSLog(@"%@",locArr[i]);
        
        [arr[i] geocodeAddressString:locArr[i] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if (error == nil) {
                CLPlacemark *placemark = [placemarks firstObject];
               // NSLog(@"%@",placemark);
                CBAnno *anno1 = [[CBAnno alloc]init];
                anno1.coordinate = placemark.location.coordinate;
                anno1.title = @"Destionation";
                
                
                [self.mapView addAnnotation:anno1];
                
                
            }
            
            
            
        }];
    }

}



-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.endLoc = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
   
   // NSLog(@"%d",self.count);
    //self.count = 0;
    NSLog(@"select");
    NSLog(@"select %d",self.res);
    
    
    
    [self.geocoder reverseGeocodeLocation:self.endLoc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
       
        if (error == nil) {
            CLPlacemark *endplacemark1 = [placemarks firstObject];
            self.endCLPlacemark = endplacemark1;
            
            if (self.res == false) {
                [self startDirectionsWithstartCLPlacemark:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
                NSLog(@"start");
                
            }else {
                [self startDirectionsWithstartCLPlacemark1:self.startCLPlacemark endCLPlacemark:self.endCLPlacemark];
                NSLog(@"start1");
                
            }
            
            
            if (self.startCLPlacemark == self.endCLPlacemark) {
                [self.mapView removeOverlay:self.polyline];
                [self.mapView removeAnnotation:view.annotation];
            }
            
            
            
        }
    }];
    
    
}








-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
   // NSLog(@"user location");
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
//    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
//    [self.mapView setRegion:region];
   // self.count = 0;
    userLocation.title = @"current location";
    
    
    self.startLoc = userLocation.location;
    
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil) {
            CLPlacemark *placemark = [placemarks firstObject];
            
            self.startCLPlacemark = placemark;
            //NSLog(@"%@",self.startCLPlacemark);
            NSLog(@"user location is %d",self.res);
            if (self.endCLPlacemark != NULL && self.res == false) {
                [self startDirectionsWithstartCLPlacemark:placemark endCLPlacemark:self.endCLPlacemark];
                NSLog(@"user location start");
                
            } else {
                [self startDirectionsWithstartCLPlacemark1:placemark endCLPlacemark:self.endCLPlacemark];
                
            }
            
            
            if (self.startCLPlacemark == self.endCLPlacemark) {
                self.res = false;
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
                    self.res = false;
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
           
        
            if ([self.expected intValue] == 0) {
                //self.startCLPlacemark = self.endCLPlacemark;
                self.res = false;
            }
            
            if ([self.expected intValue] <= 5 && [self.expected intValue] > 0) {
                
                
                    [self call];
                    self.res = true;

                
            } else {
            
                    self.res = false;
            }
           
           
            
            
            
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
                self.res = false;
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


- (void)call{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"input the phone number" message:nil preferredStyle:UIAlertControllerStyleAlert];
   
    [alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        self.res = true;
    }]];
    
     [alert addAction:[UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         NSString * phoneNum = [alert.textFields[0] text];
         
         self.res = true;
         //NSLog(@"%@",phoneNum);
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
                 //if (str != nil) {
                     self.res = true;
                 //}
                 
             }];
        
         
         
     }]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
       textField.placeholder = @"please input phone number";
        self.res = true;
        
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
    
   
   
    

    

    
    
    
}




 

@end
