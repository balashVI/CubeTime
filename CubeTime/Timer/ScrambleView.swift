import Foundation
import SwiftUI
import SVGKit

// swiftui views
struct DefaultScrambleView: View {
    let svg: OrgWorldcubeassociationTnoodleSvgliteSvg?
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        DefaultScrambleSVGViewRepresentable(svg: svg!, width: width, height: height)
    }
}

struct AsyncScrambleView: View {
    @State var svg = ""
    var puzzle: OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry
    var scramble: String

    var width: CGFloat
    var height: CGFloat
    
    
    var body: some View {
        Group {
            if svg == "" {
                ProgressView()
            } else {
                AsyncScrambleSVGViewRepresentable(svg: svg, width: width, height: height)
                    .aspectRatio(contentMode: .fit)
            }
        }.task {
            let task = Task.detached(priority: .userInitiated) { () -> String in
                #if DEBUG
                NSLog("ismainthread \(Thread.isMainThread)")
                #endif
                
                return JavaUtilObjects.toString(withId: puzzle.getScrambler().drawScramble(with: scramble, with: nil))
            }
            let result = await task.result
            svg = try! result.get()
        }
    }
}

// uikit wrappers
struct DefaultScrambleSVGViewRepresentable: UIViewRepresentable {
    var svg: OrgWorldcubeassociationTnoodleSvgliteSvg
    var width: CGFloat
    var height: CGFloat
    
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgstr = JavaUtilObjects.toString(withId: svg)
        let svgImage = SVGKImage(data: svgstr.data(using: .utf8))!
        svgImage.scaleToFit(inside: CGSize(width: width, height: height))
        
        let imageView = SVGKFastImageView(svgkImage: svgImage)!
//        imageView.backgroundColor = UIColor.green
//        imageView.setContentHuggingPriority(.required, for: .horizontal)
//        imageView.setContentHuggingPriority(.required, for: .vertical)
//        imageView.frame(forAlignmentRect: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        
        
        return imageView
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        
    }
}

struct AsyncScrambleSVGViewRepresentable: UIViewRepresentable {
    var svg: String
    var width: CGFloat
    var height: CGFloat
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(data: svg.data(using: .utf8))
        svgImage!.scaleToFit(inside: CGSize(width: width, height: height))
        return SVGKFastImageView(svgkImage: svgImage!)!
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        let svgImage = SVGKImage(data: svg.data(using: .utf8))
        svgImage?.scaleToFit(inside: CGSize(width: width, height: height))
        uiView.image = svgImage
    }
}
