//
//  RouteViewController.swift
//  wemap
//
//  Created by Nguyen Hoan on 07/06/2021.
//

import UIKit
import WeMapSDK
import CoreLocation
class RouteViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var vTime: UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    
    var startLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 20.993893749513248, longitude: 105.82176090675364)
    
    var endLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 20.993893749513248, longitude: 105.82176090675364)
    var vehicle = "car"
    var wemapView: WeMapView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wemapView = WeMapView(frame: view.bounds)

        wemapView.setCenter(CLLocationCoordinate2D(latitude: (startLocation.latitude + endLocation.latitude)/2, longitude: (startLocation.longitude + endLocation.longitude)/2), zoomLevel: 10, animated: false)
        wemapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(wemapView)
        wemapView.delegate = self
        view.bringSubviewToFront(btnBack)
//        view.bringSubviewToFront(vTime)
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension RouteViewController: WeMapViewDelegate {
    func WeMapViewDidFinishLoadingMap(_ wemapView: WeMapView) {
            let wemapDirection = WeMapDirection()
            let points = [
                startLocation,
                endLocation
            ]
        
        wemapView.selectAnnotation(WeMapPointAnnotation(startLocation), animated: false, completionHandler: {})
        wemapView.selectAnnotation(WeMapPointAnnotation(endLocation), animated: false, completionHandler: {})
        
        let wemapOptions = WeMapDirectionOptions(vehicle: self.vehicle, instruction: false)
        wemapDirection.route(points, wemapDirectionOptions: wemapOptions) { paths in
                if paths.count > 0 {
                    let path = paths[0]
                    // Create a data source to hold the point data
                    let shapeSource = WeMapShapeSource(identifier: "path-line", data: path.pathLine)

                    // Create new layer for the line.
                    let layer = WeMapLineStyleLayer(identifier: "polyline", source: shapeSource)

                    // Set the line join and cap to a rounded end.
                    layer.lineJoin = NSExpression(forConstantValue: "round")
                    layer.lineCap = NSExpression(forConstantValue: "round")

                    // Set the line color to a constant blue color.
                    layer.lineColor = NSExpression(forConstantValue: UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1))
                    
                    layer.lineWidth = 10
                    // Add the source and style layer to the map
                    wemapView.addSource(shapeSource)
                    wemapView.addLayer(layer)
                    DispatchQueue.main.async {
                        self.lblTime.text = "Thời gian: " + String(path.time)
                    }
                    
                    //Total time
                    print(path.time)
                }
            }

        }
}
