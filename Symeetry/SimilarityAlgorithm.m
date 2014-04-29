//
//  SimilarityAlgorithm.m
//  Symeetry
//
//  Created by user on 4/28/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "SimilarityAlgorithm.h"
#import "ParseManager.h"

@implementation SimilarityAlgorithm

/*
 *
 *@return void
 */
- (void)getUserWithSimlarityRank:(NSArray*)regions
{
    //NSLog(@"begin asynch call for similarity");
    
    [self getCurrentUserInterestWithCompletion:^(PFObject *object, NSError *error)
     {
         //PFUser* user = object;
         
         if(object)
         {
             NSDictionary* currentUserInterests = [ParseManager convertPFObjectToNSDictionary:object[@"interests"]];
             [self calculateSimilarity:currentUserInterests forRegions:regions];
         }
     }];
}


/*
 *@param NSDictionary
 *@return void
 */
- (void)calculateSimilarity:(NSDictionary*)currentUserInterests forRegions:(NSArray*)activeRegions
{
    
    //NSLog(@"calculateSimilarity currentUserInterests");
    [self calculateSimilarity:currentUserInterests forRegions:activeRegions withCompletion:^(NSArray *objects, NSError *error)
     {
         
         NSDictionary* otherUserInterests = nil;
         
         //NSLog(@"begin For Loop for user comparison");
         
         for(PFObject* user in objects)
         {
             //get the interest for each user in the list of objects returned from the search
             otherUserInterests = [ParseManager convertPFObjectToNSDictionary:user[@"interests"]];
             
             //only calculate the similarity if there other user has intersts
             if(otherUserInterests)
             {
                 
                 /*
                  * Block to calculate the similarity between two different users. This block
                  * compares the values between two differnet NSDictionary objects, and for every
                  * pair of values that are the same, the similarity index is increased by 1
                  */
                 int (^similarityCalculation)(NSDictionary*, NSDictionary*) = ^(NSDictionary* currUser, NSDictionary* otherUser)
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
                 };
                 
                 //call a block function to calculate the similarity of the two users
                 //NSLog(@"begin similary calculation");
                 
                 user[@"similarityIndex"] = [NSNumber numberWithInt:similarityCalculation(currentUserInterests,otherUserInterests)];
                 
                 //NSLog(@"end similary calculation");
             }
         }
         
//         self.users = [objects sortedArrayUsingComparator:^NSComparisonResult(id user1, id user2)
//                       {
//                           //covert each object to a PFObject and retrieve the similarity index
//                           NSNumber *first =  ((PFObject*) user1)[@"similarityIndex"];
//                           NSNumber *second = ((PFObject*) user2)[@"similarityIndex"];
//                           return [second compare:first];
//                       }];
         
         
         dispatch_async(dispatch_get_main_queue(), ^{
             //[self.availableUsersTableView reloadData];
             //NSLog(@"user retrieval complete");
         });
         
     }];
    
}


//get the list of user by region asyncronously from parse
- (void)calculateSimilarity:(NSDictionary*)interest forRegions:(NSArray*)regions withCompletion:(MyCompletion)completion
{
    
    //NSLog(@"regions value %@", self.activeRegions);
    
    if (regions.count)//if there are no regions, then stop
    {
        [ParseManager retrieveUsersInLocalVicinityWithSimilarity:regions WithComplettion:^(NSArray *objects, NSError *error)
         {
             //NSLog(@"calculateSimilarity: regions completion inside block ");
             //NSLog(@"calculateSimilarity: regions completion block error %@",[error userInfo]);
             completion(objects,error);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 //NSLog(@"reload data calculateSimilarity forRegions withCompletion block return");
//                 [self.availableUsersTableView reloadData];
                 
             });
         }];
    }
}



- (void)getCurrentUserInterestWithCompletion:(InterestCompletion)completion
{
    //NSLog(@"getCurrentUserInterestWithComplettion");
    [ParseManager getUserInterest:[PFUser currentUser] WithCompletion:^(PFObject *object, NSError *error)
     {
         //NSLog(@"getCurrentUserInterestWithComplettion completion inside block");
         //NSLog(@"getCurrentUserInterestWithComplettion completion block error %@",[error userInfo]);
         completion(object,error);
     }];
    
}


@end
