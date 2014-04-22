//
//  SymeetryAnnotationView.h
//  Symeetry
//
//  Created by user on 4/21/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface SymeetryAnnotationView : MKAnnotationView
@property PFUser* user;
@end
