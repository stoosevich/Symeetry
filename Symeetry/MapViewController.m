//
//  MapViewController.m
//  Symeetry
//
//  Created by user on 4/18/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "ParseManager.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray* nearbyUsers;

@end

@implementation MapViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nearbyUsers = [ParseManager retrieveSymeetryUsersNearCurrentUser];
    
    //allow the user's location to be shown
    self.mapView.showsUserLocation = YES;
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
    {
        
        //create a 2D coordinate for the map view
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        
        //determine the size of the map area to show around the location
        MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.01, 0.01);
        
        //create the region of the map that we want to show
        MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);
        
        
        //update the map view
        self.mapView.region = region;
        
        [self annotateMapWithNearByUserLocations];
        
    }];

}

- (void)annotateMapWithNearByUserLocations
{
    for (PFUser* user in self.nearbyUsers)
    {
        //create a pin for the map
        MKPointAnnotation* symeetryAnnotation =[MKPointAnnotation new];
        
        PFGeoPoint* geopoint  = user[@"location"];
        NSLog(@"geopoint lat:%f long:%f", geopoint.longitude, geopoint.longitude);
        
        CLLocationCoordinate2D userCoordinate =  CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude);
        
        //set the coordinate and title of the pin
        symeetryAnnotation.coordinate =  userCoordinate;
        symeetryAnnotation.title  = user[@"username"];
        
        //update map with pin
        [self.mapView addAnnotation:symeetryAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
 
    //create a PinAnnotationView
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    
    //set the pin's image
    //pin.image = [UIImage imageNamed:@"mobilemakers"];
    
    //set call to true (required in the delegate method)
    pin.canShowCallout = YES;
    
    //add an info button to the callout
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return pin;

}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"info button tapped");
}



@end
