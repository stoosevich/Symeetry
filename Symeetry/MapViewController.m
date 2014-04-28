//
//  MapViewController.m
//  Symeetry
//
//  Created by Symeetry Team on 4/18/14.
//  Copyright (c) 2014 SSymeetry Team. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "ParseManager.h"
#import "SymeetryPointAnnotation.h"
#import "SymeetryAnnotationView.h"
#import "ProfileHeaderView.h"
#import "MapCallOutView.h"
#import "UIView+Circlify.h"
#import "Utilities.h"


@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray* nearbyUsers;

//define a block for the call back
typedef void (^MapCompletion)(PFGeoPoint *object, NSError *error);
typedef void (^MyCompletion)(NSArray *objects, NSError *error);

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //make sure we are the delegate of the map view
    self.mapView.delegate = self;
    
    //allow the user's location to be shown
    self.mapView.showsUserLocation = YES;

    [self retrieveSymeetryUsersForMapView];
}



- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveSymeetryUsersForMapView];
}


/*
 * Retrieve 50 users closest to the current user based on their last known geopoint. This
 * method uses two asynchronous blocks, one to get the users current location and a second
 * to retrieve the users in close proximity (based on geopoint)
 * @return void
 */
- (void)retrieveSymeetryUsersForMapView
{
    
    [self retrieveSymeetryUsersForMapView:^(NSArray *objects, NSError *error)
    {
        self.nearbyUsers = objects;
        [self getUsersCurrentLocation];
    }];
}


-(void)getUsersCurrentLocation
{
    
    [self getUsersCurrentLocation:^(PFGeoPoint *object, NSError *error)
    {

        //create a 2D coordinate for the map view, centered on the current user
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(object.latitude,object.longitude);
        
        
        //determine the size of the map area to show around the location
        MKCoordinateSpan coordinateSpan = [self calculateTheSpanOfTheUserCoordinates:object];
       
        
        //create the region of the map that we want to show
        MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);
        
        //update the map view
        self.mapView.region = region;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self annotateMapWithNearByUserLocations];
        });
    }];

}

-(void)getUsersCurrentLocation:(MapCompletion)completion
{
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
     {
         completion(geoPoint,error);

     }];
}

/*
 * Retrieve 50 users using Parse geopoint location query. This process uses an
 * asynchronous block to retrive the users
 * @param MyCompletion block
 * @return void
 */
- (void)retrieveSymeetryUsersForMapView:(MyCompletion)completion
{
    [ParseManager retrieveSymeetryUsersForMapView:^(NSArray *objects, NSError *error)
    {
        completion(objects,error);
    }];
}



- (void)annotateMapWithNearByUserLocations
{

    int count = 0;
    
    for (PFUser* user in self.nearbyUsers)
    {
        //create a pin for the map
        SymeetryPointAnnotation* symeetryAnnotation = [SymeetryPointAnnotation new];
        symeetryAnnotation.index =  count++;
        
        //assign user to the annotation
        symeetryAnnotation.user = user;
        
        PFGeoPoint* geopoint  = user[@"location"];
        
        CLLocationCoordinate2D userCoordinate =  CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude);
        
        //set the coordinate and title of the pin
        symeetryAnnotation.coordinate =  userCoordinate;
        
        //symeetryAnnotation.title = symeetryAnnotation.user.username;

        //update map with pin
        [self.mapView addAnnotation:symeetryAnnotation];
    }
}

//map view delegate call back
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

    if ([view isKindOfClass:[MKUserLocation class]])
    {
        return;
    }
    
    SymeetryPointAnnotation *annotation = (id)view.annotation;

    //create the view from a xib file
    MapCallOutView *annotationView =  [MapCallOutView newViewFromNib:@"MapCallOutView"];
    
    CGRect frame = CGRectMake(20.0, -20.0f, 130.0f, 40.0f);
    
    //set the frame
    annotationView.frame = frame;
    
    if (annotation.user)
    {
        annotationView.nameTextField.text = annotation.user.username;
        PFFile* file = annotation.user[@"thumbnail"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             UIImage* image = [UIImage imageWithData:data];
             UIImage* resizedImage = [self resizeImage:image toWidth:30.0f andHeight:30.0f];
             annotationView.imageView.image = resizedImage;
             NSNumber* index = (NSNumber*)annotation.user[@"similarityIndex"];
             
             NSLog(@"sim index %@",index);
             [annotationView.imageView.layer setBorderColor:[Utilities colorBasedOnSimilarity:[index intValue]]];
             
             [annotationView.imageView circlify];
         }];
        
        //add custom view above pin
        [view addSubview:annotationView];
    }

}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
    if ([view isKindOfClass:[MKUserLocation class]])
    {
        return;
    }
    
    if ([view isKindOfClass:[MKPinAnnotationView class]])
    {
        for (UIView* subview in view.subviews)
        {
            if([subview isKindOfClass:[MapCallOutView class]])
            {
                [subview removeFromSuperview];
            }
        }
    }
}

//
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    //do not alter the pin for the current user
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    if ([annotation isKindOfClass:[SymeetryAnnotationView class]])
    {
        static NSString *annotationIdentifier = @"SymeetryAnnotation";
        
        SymeetryAnnotationView *annotationView = [[SymeetryAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        
        if (!annotationView)
        {
            annotationView = [[SymeetryAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
            annotationView.canShowCallout = NO;
        }
        else
        {
            annotationView.annotation =  annotation;
        }
        return annotationView;
    }
    return nil;
}





-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view isKindOfClass:[MKUserLocation class]])
    {
        return;
    }
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
-(MKCoordinateSpan)calculateTheSpanOfTheUserCoordinates:(PFGeoPoint*)userLocation
{
    MKCoordinateSpan corrdinateSpan = MKCoordinateSpanMake(0.0, 0.0);

    float minLatitude = MAXFLOAT;
    float minLongitude = MAXFLOAT;
    
    float maxLatitude = -200;
    float maxLongitude = -200;
    
    PFGeoPoint *point = nil;
    
    for (PFUser *user in self.nearbyUsers)
    {
        point = ((PFGeoPoint*)user[@"location"]);
        
        if (point.latitude < minLatitude)
        {
            minLatitude = point.latitude;
        }
        if (point.latitude > maxLatitude)
        {
            maxLatitude = point.latitude;
        }
        
        if (point.longitude < minLongitude)
        {
            minLongitude = point.longitude;
        }
        if (point.longitude > maxLongitude)
        {
            maxLongitude = point.longitude;
        }
    }
    
    
    //include the users location in the calculation of the span
    if (userLocation.latitude < minLatitude)
    {
        minLatitude = userLocation.latitude;
    }
    if (userLocation.latitude > maxLatitude)
    {
        maxLatitude = userLocation.latitude;
    }
    
    if (userLocation.longitude < minLongitude)
    {
        minLongitude = userLocation.longitude;
    }
    if (userLocation.longitude > maxLongitude)
    {
        maxLongitude = userLocation.longitude;
    }
    
    
    float latitudeRange = maxLatitude - minLatitude + 0.005;
    float longitudeRange = maxLongitude - minLongitude + 0.005;
    
    corrdinateSpan.latitudeDelta = latitudeRange;
    corrdinateSpan.longitudeDelta = longitudeRange;
    
//    NSLog(@"max lat: %f long:%f",maxLatitude,maxLongitude);
//    NSLog(@"min lat: %f long:%f",minLatitude,minLongitude);
//    NSLog(@"span lat: %f long:%f",corrdinateSpan.latitudeDelta,corrdinateSpan.longitudeDelta);
    
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
