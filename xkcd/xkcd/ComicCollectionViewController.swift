//
//  ViewController.swift
//  xkcd
//
//  Created by Clay Reimann on 6/9/15.
//  Copyright (c) 2015 Clay Reimann. All rights reserved.
//

import UIKit

class ComicCollectionViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top:8, left:16, bottom:0, right:16)
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 8;
            layout.minimumInteritemSpacing = 8;
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //
    //  CollectionViewDataSource
    //
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ComicCell", forIndexPath: indexPath) as! ComicCell
        cell.labelComic.text = "\(indexPath.row)";

        return cell;
    }

}

