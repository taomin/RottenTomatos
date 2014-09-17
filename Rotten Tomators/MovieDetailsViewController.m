//
//  MovieDetailsViewController.m
//  Rotten Tomators
//
//  Created by Taomin Chang on 9/14/14.
//  Copyright (c) 2014 Taomin Chang. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController () {
    NSDictionary *movieDetails;

}
@property (strong, nonatomic) IBOutlet UILabel *movieTitle;
@property (strong, nonatomic) IBOutlet UIImageView *moviePoster;
@property (strong, nonatomic) IBOutlet UITextView *movieDescription;
@property (strong, nonatomic) IBOutlet UIView *ContentView;
@property (strong, nonatomic) IBOutlet UIScrollView *ScrollView;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Movie Details";
    [self initMovieView];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self.ScrollView layoutIfNeeded];
    [self.movieDescription sizeToFit];
    CGRect contentRect = CGRectZero;
    
    for (UIView *subview in self.ContentView.subviews) {
        contentRect = CGRectUnion(contentRect, subview.frame);
    }

    self.ScrollView.contentSize = contentRect.size;
    
}

- (void)setMovieDetails:(NSDictionary *)movie {
    self->movieDetails = movie;
    
}

- (void)initMovieView {
    
    self.movieTitle.text = self->movieDetails[@"title"];
    self.movieDescription.text = self->movieDetails[@"synopsis"];

    NSString *thumbnailUrl = [movieDetails valueForKeyPath:@"posters.thumbnail"];
    
    // set a low resolution image first. They are being loaded by previous screen so can be loaded instantly.
    
    NSString *originalImageUrl = [thumbnailUrl stringByReplacingOccurrencesOfString:@"tmb" withString:@"org"];
    
    [self.moviePoster setImageWithURL:[NSURL URLWithString:originalImageUrl] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]]]];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
