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
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBAction func fetchButton(_ sender: Any) {
        activityIndicator.startAnimating()
        OperationQueue().addOperation{ [self] in
//            activityIndicator.startAnimating()
            OperationQueue.main.addOperation{
                activityIndicator.startAnimating()
//                loadingLabel.isHidden = false
            }
            OperationQueue.main.addOperation {
                barcodeDatas = []
                collectionView.reloadData()
                setPhotoLibraryImage()
                collectionView.reloadData()
                activityIndicator.stopAnimating()
            }
        }
    }
    public var results: [PHAsset] = []
    public var fetchPhotos: PHFetchResult<PHAsset>?
    public var index: Int?
    
    let label = UILabel()
    private var barcodeDatas: [UIImage] = []
    
    // 이미지 스캔
    private func scanImage(data: Data, photo: PHAsset) {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { [self] request, error in
            self.reportResults(results: request.results, data: data, photo: photo)
            
        })
        let handler = VNImageRequestHandler(data: data, options: [.properties: ""])
        
        guard let _ = try? handler.perform([barcodeRequest]) else {
            return print("Could not perform barcode-request!")
        }
    }
    
    // 스캔 결과
    private func reportResults(results: [Any]?, data: Data, photo: PHAsset) {
        var check = false
        // Loop through the found results
        guard let results = results else {
            return print("No results found.")
        }
        
        for result in results {
            // Cast the result to a barcode-observation
            if let barcode = result as? VNBarcodeObservation {
                
                if let payload = barcode.payloadStringValue {
                    print("Payload: \(payload)")
                }
                
                // Print barcode-values
                print("Symbology: \(barcode.symbology.rawValue)")
                // QRCode 제외
                if barcode.symbology.rawValue == "VNBarcodeSymbologyCode128"{
                    check = true
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
        
        // 바코드인 경우
        if results.count > 0 && check{
            print("바코드 확인")
            barcodeDatas.append(UIImage(data: data)!)
            self.results.append(photo)
        }
    }
    
    // 사진 앱에서 이미지 가져오기
    private func setPhotoLibraryImage() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchPhotos = PHAsset.fetchAssets(with: fetchOption)
        
        for i in 0 ..< fetchPhotos!.count {
            autoreleasepool {
                var photo: PHAsset? = fetchPhotos!.object(at: i)
                
                var image: UIImage? = getAssetThumbnail(asset: photo!)
                if let image = image{
                    let data = UIImagePNGRepresentation(image)
                    if let data = data{
                        scanImage(data: data, photo: photo!)
                    }
                }
                image = nil
                photo = nil
            }
        }
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.red
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.white
        // Start animation.
        activityIndicator.stopAnimating()
        return activityIndicator }()
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
//        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            if let result = result{
                thumbnail = result
            }
        })
        return thumbnail
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(barcodeDatas.count)
        return barcodeDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CSCollectionViewCell
        
        cell.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        cell.image.image = barcodeDatas[indexPath.row]
        cell.image.contentMode = .scaleAspectFill
        cell.image.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width / 3 - 1, height: collectionView.frame.width / 3 - 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        vcName?.modalTransitionStyle = .coverVertical
        vcName?.modalPresentationStyle = .fullScreen
        vcName?.paramImage = barcodeDatas[indexPath.row]
        vcName?.paramAsset = results[indexPath.row]
        vcName?.paramFetchResult = fetchPhotos
        index = indexPath.row
        self.present(vcName!, animated: true, completion: nil)
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
        self.view.addSubview(self.activityIndicator)
        
        loadingLabel.isHidden = true
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = index{
            barcodeDatas.remove(at: index)
        }
        collectionView.reloadData()
        label.isHidden = true
    }
}
