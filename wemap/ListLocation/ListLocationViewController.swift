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
    var destPlaces: [WeMapPlace] = [] {
        didSet {
            self.wemapView.selectAnnotation(WeMapPointAnnotation(self.centerMyhome), animated: false) {
                print("done add")
            }
        }
    }
    var typePositions: typePositions = .CircleK
    let centerMyhome: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 20.993893749513248, longitude: 105.82176090675364)
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let wemapView = WeMapView(frame: view.bounds)
        wemapView.setCenter(centerMyhome, zoomLevel: 10, animated: false)
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
        
//        self.wemapView.removeall
        
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
        
        let wemapSearch = WeMapSearch()

        //gioi han so luong du lieu tra ve
        let wemapOptions = WeMapSearchOptions(100, focusPoint: CLLocationCoordinate2D(latitude: 21.031772, longitude: 105.799508), latLngBounds: WeMapLatLonBounds(minLon: 104.799508, minLat: 20.031772, maxLon: 105.799508, maxLat: 21.031772))
        var searchText = "circle k"
        if typePositions == .CircleK {
            searchText = "circle k"
        }
        if typePositions == .FixMotobike {
            searchText = "sửa xe"
        }
        if typePositions == .Fuel {
            searchText = "trạm xăng"
        }
        wemapSearch.search(searchText, wemapSearchOptions: wemapOptions ) {[weak self] wemapPlace in
            guard let `self` = self else {return}
            print("number palace \(wemapPlace.count) \(searchText)")
            self.destPlaces = wemapPlace
//            self.wemapView.selectAnnotation(WeMapPointAnnotation(self.centerMyhome), animated: false, completionHandler: {})
            
//            for place in wemapPlace {
//                self.wemapView.selectAnnotation(WeMapPointAnnotation(place.location), animated: false, completionHandler: {})
//                print(place.location)
//            }
//
        }
        
        
    }
}
