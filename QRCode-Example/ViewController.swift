//
//  ViewController.swift
//  QRCode-Example
//
//  Created by Hans Knöchel on 09.06.17.
//  Copyright © 2017 Hans Knoechel. All rights reserved.
//

import AVKit
import UIKit
import Vision
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var barcodeDatas: [UIImage] = []
    
    private func scanImage(data: Data) {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { [self] request, error in
            self.reportResults(results: request.results, data: data)
            
        })
        let handler = VNImageRequestHandler(data: data, options: [.properties: ""])
        
        guard let _ = try? handler.perform([barcodeRequest]) else {
            return print("Could not perform barcode-request!")
        }
    }
    
    private func reportResults(results: [Any]?, data: Data) {
        // Loop through the found results
        guard let results = results else {
            return print("No results found.")
        }
        
        if results.count > 0 {
            print("바코드 확인")
        }
        
        for result in results {
            
            // Cast the result to a barcode-observation
            if let barcode = result as? VNBarcodeObservation {
                
                if let payload = barcode.payloadStringValue {
                    print("Payload: \(payload)")
                }
                
                // Print barcode-values
                print("Symbology: \(barcode.symbology.rawValue)")
                if barcode.symbology.rawValue == "VNBarcodeSymbologyCode128"{
                    barcodeDatas.append(UIImage(data: data)!)
                }
                
                if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
                    let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
                    
                    // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
                    print("Payload: \(String(describing: content))")
                    print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
                    print("Symbol-Version: \(desc.symbolVersion)")
                }
            }
        }
    }
    
    private func setPhotoLibraryImage() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchPhotos = PHAsset.fetchAssets(with: fetchOption)
        print(fetchPhotos.count)
        DispatchQueue.main.async {
            for i in 0 ..< fetchPhotos.count {
                let photo = fetchPhotos.object(at: i)
                ImageManager.shared.requestImage(from: photo, thumnailSize: CGSize(width: 300, height: 300)) { image in
                // 가져온 이미지로 (image 파라미터) 하고싶은 행동
                    if let image = image{
                        let data = UIImagePNGRepresentation(image)
                        self.scanImage(data: data!)
                        
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return barcodeDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CSCollectionViewCell
                
        cell.backgroundColor = .lightGray
        cell.image.image = barcodeDatas[indexPath.row]
        
        return cell
    }
}

// cell layout
extension ViewController: UICollectionViewDelegateFlowLayout {

    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width / 3 - 1 ///  3등분하여 배치, 옆 간격이 1이므로 1을 빼줌
        let size = CGSize(width: width, height: width)
        return size
    }
}

// MARK: UIViewControllerDelegate

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized: break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized: break
                case .notDetermined: break
                case .restricted: break
                case .denied: break
                case .limited: break
                @unknown default: break
                }
            }
        case .denied: break
        case .limited: break
        case .restricted: break
        @unknown default:
            fatalError()
        }
        setPhotoLibraryImage()
    }
}