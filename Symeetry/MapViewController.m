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
@property NSMutableDictionary* userPins;

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
        
        //create a 2D coordinate for the map view, centered on the current user
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        
        //determine the size of the map area to show around the location
        MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.02,0.02);

        
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
        symeetryAnnotation.subtitle = @"interest";
        
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
    
    PFUser* user = self.nearbyUsers.lastObject;
    PFFile* file = user[@"photo"];
    NSData* imageData = [file getData];
    UIImage* image = [UIImage imageWithData:imageData];
    UIImage* resizedImage = [self resizeImage:image toWidth:20.0f andHeight:30.0f];
    
    UIImageView* iconImage = [[UIImageView alloc]initWithImage:resizedImage];
    
    pin.leftCalloutAccessoryView = iconImage;
    
    //add an info button to the callout
    //pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;

}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"view is %@", view);
    
//    PFUser* user = self.nearbyUsers.lastObject;
//    PFFile* file = user[@"photo"];
//    NSData* imageData = [file getData];
//    UIImage* image = [UIImage imageWithData:imageData];
//    UIImage* resizedImage = [self resizeImage:image toWidth:40.0f andHeight:60.0f];
//    view.image = resizedImage;

}



/*
 * calculate the average ot the points
 * create CLCoordianteMake averageCoordinate
 * iterate over all items adding the lat and long to the average
 * divide by the number (count) of items in the array
 */
-(CLLocationCoordinate2D)calculateTheAverageCoordiantes
{
    CLLocationCoordinate2D averageCoordinate = CLLocationCoordinate2DMake(0.0,0.0);
    
    for (PFUser *user in self.nearbyUsers)
    {
        averageCoordinate.latitude += ((PFGeoPoint*)user[@"location"]).latitude;
        averageCoordinate.longitude += ((PFGeoPoint*)user[@"location"]).longitude;
    }
    
    averageCoordinate.latitude = averageCoordinate.latitude / self.nearbyUsers.count;
    averageCoordinate.longitude = averageCoordinate.longitude / self.nearbyUsers.count;
    return averageCoordinate;
}

/*
 * calculate the span of the points
 * create MKCoordinateSpan averageCoordinate
 * iterate over all items adding the lat and long to the average
 * divide by the number (count) of items in the array
 */
-(MKCoordinateSpan)calculateTheSpanOfTheUserCoordinates
{
    MKCoordinateSpan corrdinateSpan = MKCoordinateSpanMake(0.0, 0.0);

    float minLatitude = -10000.0f;
    float minLongitude = -10000.0f;
    
    float maxLatitude = 10000.0f;
    float maxLongitude = -10000.0f;
    
    for (PFUser *user in self.nearbyUsers)
    {
        if (((PFGeoPoint*)user[@"location"]).latitude < minLatitude)
        {
            minLatitude = ((PFGeoPoint*)user[@"location"]).latitude;
        }
        else if (((PFGeoPoint*)user[@"location"]).latitude > maxLatitude)
        {
            maxLatitude = ((PFGeoPoint*)user[@"location"]).latitude;
        }
        
        if (((PFGeoPoint*)user[@"location"]).longitude < minLongitude)
        {
            minLongitude = ((PFGeoPoint*)user[@"location"]).longitude;
        }
        else if (((PFGeoPoint*)user[@"location"]).longitude > maxLongitude)
        {
            maxLatitude = ((PFGeoPoint*)user[@"location"]).longitude;
        }
    }
    
    float latitudeRange = maxLatitude - minLatitude;
    float longitudeRange = maxLongitude - minLongitude;
    
    corrdinateSpan.latitudeDelta = latitudeRange;
    corrdinateSpan.longitudeDelta = longitudeRange;
    
    return corrdinateSpan;
}


- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
