//
//  ViewController.h
//  xkcd
//
//  Created by Christopher Reimann on 1/8/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

@import UIKit;

@interface CRComicMainViewController : UIViewController <UICollectionViewDataSource>

@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) IBOutlet UISearchBar *searchBar;

@end

