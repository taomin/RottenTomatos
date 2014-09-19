//
//  MovieViewController.m
//  Rotten Tomators
//
//  Created by Taomin Chang on 9/13/14.
//  Copyright (c) 2014 Taomin Chang. All rights reserved.
//

//#import "AppDelegate.h"
#import "MovieViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "MBProgressHUD.h"

NSString* const apikey = @"mcbsgchmqhgtmrrgqgnntb75";
@interface MovieViewController () {
    //private members
    UIRefreshControl *refreshControl;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
    BOOL showHud;
}
@property (strong, nonatomic) IBOutlet UITableView *movieTable;
@property (strong, nonatomic) NSArray *movies;
@property (copy) NSArray *moviesBackup;
@property (strong, nonatomic) UILabel *errorMessage;
@end

@implementation MovieViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Movies";
    self.movieTable.delegate = self;
    self.movieTable.dataSource = self;
    [self.movieTable registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
     
    self.movieTable.rowHeight = 100;
    self.movieTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.movies = @[]; // give an initial value
    CGRect labelRect = CGRectMake(0, 63, 320, 30);
    
    self.errorMessage = [[UILabel alloc] initWithFrame:labelRect];
    self.errorMessage.TextAlignment = NSTextAlignmentCenter;
    self.errorMessage.textColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1.0];
    self.errorMessage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.errorMessage.text = @"Failed to load content";
    self.errorMessage.hidden = YES;
    [self.view insertSubview:self.errorMessage aboveSubview:self.movieTable];
    // setup refresh control
    self->refreshControl = [UIRefreshControl new];
    
    [self.movieTable addSubview:refreshControl];
    [self->refreshControl addTarget:self action:@selector(reloadTable:) forControlEvents:UIControlEventValueChanged];
    
    
    self->searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self->searchBar.delegate = self;
    self.movieTable.tableHeaderView = self->searchBar;
    
    self->searchController = [[UISearchDisplayController alloc] initWithSearchBar:self->searchBar contentsController:self];
    self->searchController.searchResultsDataSource = self;
    self->searchController.searchResultsDelegate = self;
    [self->searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    self->searchController.searchResultsTableView.rowHeight = 100;
    self->searchController.delegate = self;
    
    self->showHud = YES;
    [self reloadTable:self];
    self->showHud = NO;
}
- (void)reloadTable:(MovieViewController*)sender {
    //reload movie list
    
    // setup loading image
    
    if (sender->showHud) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
    }
    
    self.errorMessage.hidden = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=%@", apikey];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        [self->refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!connectionError) {
            //callback here
            NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.movies = self.moviesBackup = object[@"movies"];
            
            [self.movieTable reloadData];
        } else {
            self.errorMessage.hidden = NO;
            [self.view bringSubviewToFront:self.errorMessage];
        }
    }];
        
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=%@&q=%@", apikey, searchString];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!connectionError) {
            //callback here
            NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.movies = object[@"movies"];
            [self->searchController.searchResultsTableView reloadData];
        } else {
            self.errorMessage.hidden = NO;
            [self.view bringSubviewToFront:self.errorMessage];
        }
    }];

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    self.movies = self.moviesBackup;
    [self.movieTable reloadData];

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

    NSLog(@"after get movie cell, %@", movieCell);
    
    movieCell.headline.text = movie[@"title"];
    movieCell.summary.text = movie[@"synopsis"];
    [movieCell.thumbnail setImageWithURL:[NSURL URLWithString:[movie valueForKeyPath:   @"posters.thumbnail"]]];
    NSLog(@"set movie cell, %@", movieCell);
    return movieCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *movie = self.movies[indexPath.row];
    MovieDetailsViewController *movieDetailsVC = [MovieDetailsViewController new];
    [movieDetailsVC setMovieDetails:movie];
    [self.navigationController pushViewController:movieDetailsVC animated:YES];

}

@end
