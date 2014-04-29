//
//  SimilarityAlgorithm.m
//  Symeetry
//
//  Created by user on 4/28/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "SimilarityAlgorithm.h"
#import "ParseManager.h"

@interface SimilarityAlgorithm()
@property NSMutableArray* users;
@property NSDictionary* currentUserInterests;
@property PFGeoPoint* currentLocation;

@end

//define a block for the call back
typedef void (^CompletionArray)(NSArray *objects, NSError *error);

//define a block for the call back for single PFObject
typedef void (^CompletionObject)(PFObject *object, NSError *error);

//define a block for the call back for single geopoint
typedef void (^CompletionPoint)(PFGeoPoint *object, NSError *error);

@implementation SimilarityAlgorithm

/*
 *
 *@return void
 */


//get the list of user by region asyncronously from parse
- (void)findUsersInRegions:(NSArray*)regions withCompletion:(CompletionArray)completion
{
    
    //NSLog(@"regions value %@", self.activeRegions);
    
    if (regions.count)//if there are no regions, then stop
    {
        [ParseManager retrieveUsersInLocalVicinityWithSimilarity:regions WithComplettion:^(NSArray *objects, NSError *error)
         {
             //NSLog(@"calculateSimilarity: regions completion inside block ");
             //NSLog(@"calculateSimilarity: regions completion block error %@",[error userInfo]);
             completion(objects,error);
             
         }];
    }
}


//get the users interest from parse
- (void)getCurrentUserInterestWithCompletion:(CompletionObject)completion
{
    //NSLog(@"getCurrentUserInterestWithComplettion");
    [ParseManager getUserInterest:[PFUser currentUser] WithCompletion:^(PFObject *object, NSError *error)
     {
         //NSLog(@"getCurrentUserInterestWithComplettion completion inside block");
         //NSLog(@"getCurrentUserInterestWithComplettion completion block error %@",[error userInfo]);
         completion(object,error);
     }];
    
}




//calculate the similarity between two users
- (int)calculateSimilarityCurrentUser:(NSDictionary*)currUser otherUser:(NSDictionary*)otherUser
{
    int similarity = 0;
    
    //loop throught the current user's dictionary of interests and compare
    //each value to the other user. For each match increase the count by 1
    int count = 0;
    for (NSDictionary* item in currUser)
    {
        count++;
        if (![item isEqual:@"userid"] && ![item isEqual:@"user"])
        {
            //both users need to have interest presents to avoid nil objects, and we
            //need to skip the user Id in the dictionary object
            if([currUser objectForKey:item] != nil && [otherUser objectForKey:item] != nil
               )
            {
                int currentUserCategoryValue = [[currUser objectForKey:item] intValue];
                int otherUserCategoryValue = [[otherUser objectForKey:item] intValue];
                
                int categoryValue  = abs( abs(currentUserCategoryValue - otherUserCategoryValue) - 5);
                similarity += categoryValue;
            }
        }
        
    }
    return similarity;
}

#pragma mark - LocationRelated Methods

//get the users location from Parse
- (void)getUsersCurrentLocationWithCompletion:(CompletionPoint)completion
{
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
     {
         completion(geoPoint,error);
     }];
}


//get the users current location anddetermine the distance between the current user and another user
-(void)calculateDistanceBetweenCurrentUserandOtherUser:(PFGeoPoint*)otherUser
{
    //get the users current location
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
     {
         [self calculateDistanceBetweenGeoPointOne:geoPoint geoPointTwo:otherUser];
         
     }];
}

- (float)calculateDistanceBetweenGeoPointOne:(PFGeoPoint*)currentUser geoPointTwo:(PFGeoPoint*)nearbyUser
{
    /*
     λ = latittude
     φ = longitude
     R = earth's radius 6,371
     x = Δλ.cos(φ) //differnece in latitude times cos-sign of longitude
     y = Δφ        //change in longitude
     d = R.√x² + y² //distance times earh radius
     */
    
    
    float latitudeDelta = currentUser.latitude -  nearbyUser.latitude;
    float longitudeDelta = currentUser.longitude -  nearbyUser.longitude;
    
    float radius = 6371.00;
    float x = latitudeDelta * cos((currentUser.longitude + nearbyUser.longitude)/2);
    float y = longitudeDelta;
    float d = sqrt(x*x + y*y) * radius;
    
    return d;
    
}


@end
