//
//  MovieViewController.m
//  Rotten Tomators
//
//  Created by Taomin Chang on 9/13/14.
//  Copyright (c) 2014 Taomin Chang. All rights reserved.
//

#import "MovieViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "MBProgressHUD.h"

NSString* const apikey = @"mcbsgchmqhgtmrrgqgnntb75";
@interface MovieViewController () {
    //private members
    UIRefreshControl *refreshControl;                                
}
@property (strong, nonatomic) IBOutlet UITableView *movieTable;
@property (strong, nonatomic) NSArray *movies;
@end

@implementation MovieViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Movies";
    self.movieTable.delegate = self;
    self.movieTable.dataSource = self;
    [self.movieTable registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
     
    self.movieTable.rowHeight = 100;
    self.movies = @[]; // give an initial value
    
    // setup refresh control
    self->refreshControl = [UIRefreshControl new];
    [self.movieTable addSubview:refreshControl];
    [self->refreshControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    
    [self reloadTable];

}

- (void)reloadTable {
    //reload movie list
    
    // setup loading image
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=%@", apikey];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        [self->refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!connectionError) {
            //callback here
            NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.movies = object[@"movies"];
            [self.movieTable reloadData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                            message:@"You must be connected to the internet to use this app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *movie = self.movies[indexPath.row];
    
    MovieCell *movieCell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];

    movieCell.headline.text = movie[@"title"];
    movieCell.summary.text = movie[@"synopsis"];
    [movieCell.thumbnail setImageWithURL:[NSURL URLWithString:[movie valueForKeyPath:   @"posters.thumbnail"]]];
    return movieCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *movie = self.movies[indexPath.row];
    MovieDetailsViewController *movieDetailsVC = [MovieDetailsViewController new];
    [movieDetailsVC setMovieDetails:movie];
    [self.navigationController pushViewController:movieDetailsVC animated:YES];

}

@end
