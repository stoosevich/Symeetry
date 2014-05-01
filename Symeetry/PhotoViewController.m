//
//  PhotoViewController.m
//  Symeetry
//
//  Created by Steve Toosevich on 4/28/14.
//  Copyright (c) 2014 Steve Toosevich. All rights reserved.
//

#import "PhotoViewController.h"
#import "CameraViewController.h"
#import "ParseManager.h"
#import "Utilities.h"
#import "UIView+Circlify.h"


@interface PhotoViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;

@end

@implementation PhotoViewController


// crash fixed
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userImage.image = [UIImage imageNamed:@"ic_welcome_profile.png"];
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Device has no camera"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.editing) {
        PFFile* file = [[ParseManager currentUser] objectForKey:@"photo"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.userImage.image = [UIImage imageWithData:data];
        }];
    }
}


- (IBAction)onTakePhotoButtonPressed:(id)sender
{
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}


- (IBAction)onSelectPhotoButtonPressed:(id)sender
{
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];}

#pragma mark -- Image Picker Controller delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.userImage.image = chosenImage;
    self.photo = self.userImage.image;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onComfirmButtonPressed:(id)sender
{
    if (self.editing)
    {
        self.selectPhotoButton.enabled = NO;
        self.confirmButton.enabled = NO;
        self.takePhotoButton.enabled = NO;
        [ParseManager saveInfo:[PFUser currentUser]
                   objectToSet:[ParseManager convertUIImageToPFFile:self.userImage.image]
                        forKey:@"photo"
               completionBlock:^{
               }];
        [ParseManager saveInfo:[PFUser currentUser]
                   objectToSet:[ParseManager convertUIImageToPFFile:[Utilities resizeImage:self.userImage.image withWidth:40 andHeight:40]]
                        forKey:@"thumbnail"
               completionBlock:^{
               }];
        self.selectPhotoButton.enabled = YES;
        self.confirmButton.enabled = YES;
        self.takePhotoButton.enabled = YES;
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else{
        self.selectPhotoButton.enabled = NO;
        self.confirmButton.enabled = NO;
        self.takePhotoButton.enabled = NO;
        [ParseManager saveInfo:[PFUser currentUser]
                   objectToSet:[ParseManager convertUIImageToPFFile:self.userImage.image]
                        forKey:@"photo"
               completionBlock:^{
               }];
        [ParseManager saveInfo:[PFUser currentUser]
                   objectToSet:[ParseManager convertUIImageToPFFile:[Utilities resizeImage:self.userImage.image withWidth:40 andHeight:40]]
                        forKey:@"thumbnail"
               completionBlock:^{
               }];
        [[CameraViewController sharedCameraViewController].myImageView circlify];
        [CameraViewController sharedCameraViewController].myImageView.image = self.userImage.image;
        self.selectPhotoButton.enabled = YES;
        self.confirmButton.enabled = YES;
        self.takePhotoButton.enabled = YES;
        [self dismissViewControllerAnimated:YES completion:NULL];
    }

}


@end
