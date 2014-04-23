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

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray* nearbyUsers;


@end

@implementation MapViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadHeaderView];
    
    //make sure we are the delegate of the map view
    self.mapView.delegate = self;
    
    //allow the user's location to be shown
    self.mapView.showsUserLocation = YES;

    //self.nearbyUsers = [ParseManager retrieveSymeetryUsersForMapView];
    [self retrieveSymeetryUsersForMapView];
}


/*
 * Load the custom view used for the users profile
 */
- (void)loadHeaderView
{
    //create the view from a xib file
    ProfileHeaderView *headerView =  [ProfileHeaderView newViewFromNib:@"ProfileHeaderView"];
    
    //quick hack to make the view appear in the correct location
    CGRect frame = CGRectMake(0.0, 0.60f, headerView.frame.size.width, headerView.frame.size.height);
    
    //set the frame
    headerView.frame = frame;
    
    //update the profile header details
    headerView.nameTextField.text = [[PFUser currentUser]username];
    NSNumber* age  = [[PFUser currentUser]objectForKey:@"age"];
    
    headerView.ageTextField.text = age.description;
    headerView.genderTextField.text = [[PFUser currentUser]objectForKey:@"gender"];
    
    //convert the file to a UIImage
    PFFile* file = [[PFUser currentUser]objectForKey:@"photo"];
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             headerView.imageView.image = [UIImage imageWithData:data];
             
         }
         else
         {
             //do something, like load a default image
         }
     }];
    
    //add the new view to the array of subviews
    [self.view addSubview:headerView];
}

/*
 * Retrieve 50 users closest to the current user based on their last known geopoint. This
 * method uses two asynchronous blocks, one to get the users current location and a second
 * to retrieve the users in close proximity (based on geopoint)
 * @return void
 */
- (void)retrieveSymeetryUsersForMapView
{
    [ParseManager retrieveSymeetryUsersForMapView:^(NSArray *objects, NSError *error)
    {
        self.nearbyUsers = objects;
        
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
    }];
}



- (void)annotateMapWithNearByUserLocations
{
    for (PFUser* user in self.nearbyUsers)
    {
        //create a pin for the map
        SymeetryPointAnnotation* symeetryAnnotation = [SymeetryPointAnnotation new];
        
        //assign user to the annotation
        symeetryAnnotation.user = user;
        
        PFGeoPoint* geopoint  = user[@"location"];
        //NSLog(@"geopoint lat:%f long:%f", geopoint.longitude, geopoint.longitude);
        
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

    SymeetryPointAnnotation *annotation = (id)view.annotation;

    //create the view from a xib file
    MapCallOutView *annotationView =  [MapCallOutView newViewFromNib:@"MapCallOutView"];
    
    CGRect frame = CGRectMake(0.0, 00.0f, 130.0f, 40.0f);
    
    //set the frame
    annotationView.frame = frame;
    
    //update the profile header details
    annotationView.nameTextField.text = annotation.user.username;
    
    
    PFFile* file = annotation.user[@"thumbnail"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        UIImage* image = [UIImage imageWithData:data];
        UIImage* resizedImage = [self resizeImage:image toWidth:30.0f andHeight:30.0f];
        annotationView.imageView.image = resizedImage;
    }];

    //add custom view to pin
   [view addSubview:annotationView];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
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
    NSLog(@"view is %@", view);
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
