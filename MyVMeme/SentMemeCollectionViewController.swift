//
//  SentMemeCollectionViewController.swift
//  MyVMeme
//
//  Created by Vedarth Solutions on 6/22/18.
//  Copyright © 2018 Vedarth Solutions. All rights reserved.
//

import Foundation

import UIKit

class SentMemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var memes = [Meme]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        self.collectionView?.reloadData()
    }
    
   override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SentMemeCollectionViewCell", for: ((indexPath as NSIndexPath) as IndexPath)) as! SentMemeCollectionViewCell
        let thisMeme = memes[indexPath.row]
        cell.memeTitle?.text = "\(thisMeme.topText) - \(thisMeme.bottomText)"
        cell.memeImageView?.image = thisMeme.memedImage
        cell.memeImageView.contentMode = .scaleAspectFit
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "SentMemeDetailViewController") as! SentMemeDetailViewController
        
        detailController.meme = memes[(indexPath as NSIndexPath).row]
        navigationController!.pushViewController(detailController, animated:true)
    }
    
    func setupFlowLayout() -> Void {
        let space:CGFloat = 3.0
        let dimension = (view.frame.width - (2 * space)) / 3.0
        let lateral = (view.frame.height - (2 * space)) / 3.0
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: lateral)
    }
}
