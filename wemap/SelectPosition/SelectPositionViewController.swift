//
//  SelectPositionViewController.swift
//  wemap
//
//  Created by Nguyen Hoan on 11/06/2021.
//

import UIKit
import WeMapSDK
import CoreLocation

protocol SelectPositionViewControllerDelegate: class {
    func getPosition(coordinate: CLLocationCoordinate2D, isDest: Bool)
}

class SelectPositionViewController: UIViewController {


    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var btnDone: UIButton!
    weak var delegate: SelectPositionViewControllerDelegate? = nil
    var wemapView = WeMapView()
    
    var isDest: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wemapView.delegate = self
        wemapView = WeMapView(frame: view.bounds)
        wemapView.setCenter(CLLocationCoordinate2D(latitude: 21.0266469, longitude: 105.7615744), zoomLevel: 4, animated: false)
                wemapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(wemapView)
        // Do any additional setup after loading the view.
        view.bringSubviewToFront(imgLocation)
        view.bringSubviewToFront(btnDone)
        view.bringSubviewToFront(btnBack)
    }
    @IBAction func done(_ sender: Any) {
        let screenSize = view.bounds.size
        let center: CGPoint = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        let coordinate = wemapView.convert(center, toCoordinateFrom: self.view)
        
        self.delegate?.getPosition(coordinate: coordinate, isDest: self.isDest)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension SelectPositionViewController: WeMapViewDelegate {
    func WeMapViewDidFinishLoadingMap(_ wemapView: WeMapView) {
        print("done laod")
    }
}
