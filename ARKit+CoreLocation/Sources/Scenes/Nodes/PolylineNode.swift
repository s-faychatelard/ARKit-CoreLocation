//
//  PolylineNode.swift
//  ARKit+CoreLocation
//
//  Created by Ilya Seliverstov on 11/08/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import SceneKit
import MapKit

@available(iOS 10.0, *)
public class PolylineNode {
    var locationNodes = [LocationNode]()

    private let polyline: [CLLocationCoordinate2D]
    private let altitude: CLLocationDistance
    public var boxColor: UIColor

    private let lightNode: SCNNode = {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = .ambient
        node.light!.intensity = 25
        node.light!.attenuationStartDistance = 100
        node.light!.attenuationEndDistance = 100
        node.position = SCNVector3(x: 0, y: 10, z: 0)
        node.castsShadow = false
        node.light!.categoryBitMask = 3
        return node
    }()

    private let lightNode3: SCNNode = {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = .omni
        node.light!.intensity = 100
        node.light!.attenuationStartDistance = 100
        node.light!.attenuationEndDistance = 100
        node.light!.castsShadow = true
        node.position = SCNVector3(x: -10, y: 10, z: -10)
        node.castsShadow = false
        node.light!.categoryBitMask = 3
        return node
    }()

    public init(polyline: [CLLocationCoordinate2D], altitude: CLLocationDistance, boxColor: UIColor? = nil) {
        self.polyline = polyline
        self.altitude = altitude
        self.boxColor = boxColor ?? .red

        contructNodes()
    }

    fileprivate func contructNodes() {
        for i in 0 ..< polyline.count - 1 {
            let currentLocation = CLLocation(coordinate: polyline[i], altitude: altitude)
            let nextLocation = CLLocation(coordinate: polyline[i + 1], altitude: altitude)

            let distance = currentLocation.distance(from: nextLocation)

            let box = SCNBox(width: 1, height: 0.2, length: CGFloat(distance), chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = self.boxColor

            let bearing = -currentLocation.bearing(between: nextLocation)

            let boxNode = SCNNode(geometry: box)
            boxNode.pivot = SCNMatrix4MakeTranslation(0, 0, 0.5 * Float(distance))
            boxNode.eulerAngles.y = Float(bearing).degreesToRadians
            boxNode.categoryBitMask = 3
            boxNode.addChildNode(lightNode)
            boxNode.addChildNode(lightNode3)

            let locationNode = LocationNode(location: currentLocation)
            locationNode.locationConfirmed = true
//            locationNode.continuallyUpdatePositionAndScale = false
            locationNode.addChildNode(boxNode)

            locationNodes.append(locationNode)
        }

    }
}
