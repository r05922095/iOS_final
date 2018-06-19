/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`VirtualFaceContent` provides an interface for the content in this sample to update in response to
 tracking changes.
*/

import ARKit
import SceneKit

protocol VirtualFaceContent {
    @available(iOS 11.0, *)
    func update(withFaceAnchor: ARFaceAnchor)
}

typealias VirtualFaceNode = VirtualFaceContent & SCNNode

// MARK: Loading Content

@available(iOS 9.0, *)
func loadedContentForAsset(named resourceName: String) -> SCNNode {
    let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "Models.scnassets")!
    let node = SCNReferenceNode(url: url)!
    node.load()
    
    return node
}
