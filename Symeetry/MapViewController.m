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
    
    //self.nearbyUsers = [ParseManager retrieveSymeetryUsersNearCurrentUser];
    
    
    //allow the user's location to be shown
    self.mapView.showsUserLocation = YES;
    
    //create a 2D coordinate for the map view
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(41.89373984, -87.63532979);
    
    //determine the size of the map area to show around the location
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.01, 0.01);
    
    //create the region of the map that we want to show
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);
    
    
    //update the map view
    self.mapView.region = region;

    
}



@end
