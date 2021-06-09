//
//  ListLocationViewController.swift
//  wemap
//
//  Created by Nguyen Hoan on 07/06/2021.
//

import UIKit
import WeMapSDK
import CoreLocation

enum typePositions {
    case CircleK
    case Fuel
    case FixMotobike
}

class ListLocationViewController: UIViewController {
    @IBOutlet weak var btnBack: UIButton!
    
    let wemapView: WeMapView = WeMapView()
    let centerMyhome: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 20.993893749513248, longitude: 105.82176090675364)
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let wemapView = WeMapView(frame: view.bounds)
        wemapView.setCenter(centerMyhome, zoomLevel: 15, animated: false)
        wemapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(wemapView)
        wemapView.delegate = self
        view.bringSubviewToFront(btnBack)
        // Do any additional setup after loading the view.
    }
    
}


extension ListLocationViewController: WeMapViewDelegate {
    func WeMapViewDidFinishLoadingMap(_ wemapView: WeMapView) {
        let coordinates = [
            centerMyhome
        ]
        
        // Fill an array with point annotations and add it to the map.
        var pointAnnotations = [WeMapPointAnnotation]()
        for coordinate in coordinates {
            let point = WeMapPointAnnotation(coordinate)
            point.title = "\(coordinate.latitude), \(coordinate.longitude)"
            pointAnnotations.append(point)
        }
        // Create a data source to hold the point data
        let shapeSource = WeMapShapeSource(identifier: "home-source", points: pointAnnotations)

        // Create a style layer for the symbol
        let shapeLayer = WeMapSymbolStyleLayer(identifier: "home-symbols", source: shapeSource)

        // Add the image to the style's sprite
        if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: "circlebadge.fill") {
                wemapView.setImage(image, forName: "icon-house")
            }
        } else {
            // Fallback on earlier versions
        }

        // Tell the layer to use the image in the sprite
        shapeLayer.iconImageName = NSExpression(forConstantValue: "icon-house")

        // Add the source and style layer to the map
        wemapView.addSource(shapeSource)
        wemapView.addLayer(shapeLayer)
    }
}
