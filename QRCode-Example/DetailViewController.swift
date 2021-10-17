//
//  DetailViewController.swift
//  QRCode-Example
//
//  Created by judongseok on 2021/09/30.
//  Copyright © 2021 Hans Knoechel. All rights reserved.
//

import UIKit
import Photos

class DetailViewController: UIViewController {
    @IBOutlet weak var imageVIew: UIImageView!
    
    @IBAction func backBtn(_ sender: Any) {
        DispatchQueue.main.async {
            (self.presentingViewController as? ViewController)!.index = nil
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func deleteBtn(_ sender: Any) {
        if let paramAsset = paramAsset {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets([paramAsset] as NSArray)
            }
        }
    }
    public var paramImage: UIImage?
    public var paramAsset: PHAsset?
    public var paramFetchResult: PHFetchResult<PHAsset>?
    
    override func viewDidLoad() {
        PHPhotoLibrary.shared().register(self)
        if let image = paramImage{
            imageVIew.image = image
        }
    }
}

extension DetailViewController: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: paramFetchResult!) else {
            return
        }
        
        paramFetchResult = changes.fetchResultAfterChanges
        
        print("변화감지")
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
