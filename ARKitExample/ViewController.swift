//
//  ViewController.swift
//  ARKitExample
//
//  Created by Axel Ivan Molina on 15/06/2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "characters", bundle: nil) else {
            fatalError("Not able to load tracking images")
        }
        
        configuration.trackingImages = trackingImages
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Evaluar que exista una referencia del mundo real y el video
        guard let imageAnchor = anchor as? ARImageAnchor, let fileUrlString = Bundle.main.path(forResource: "acaza", ofType: "mp4") else { return }
        
        // Buscar el video
        let videoItem = AVPlayerItem(url: URL(fileURLWithPath: fileUrlString))
        
        let player = AVPlayer(playerItem: videoItem)
        // Iniciar el video con avPlayer
        let videoNode = SKVideoNode(avPlayer: player)
        
        player.play()
        // Añadir observador para que cuando el video termine se vuelva a reproducir
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) {
            (notification) in player.seek(to: CMTime.zero)
            player.play()
            print("Looping video")
        }
        
        // Setear el tamaño del video
        let videoScene = SKScene(size: CGSize(width: 480, height: 360))
        // Centrar el video en la escena
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.yScale = -1.0
        videoScene.addChild(videoNode)
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = videoScene
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -Float.pi / 2
        // Agregar el plano al video
        node.addChildNode(planeNode)
    }
    
}
