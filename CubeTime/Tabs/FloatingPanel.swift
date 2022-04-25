//
//  FloatingPanel.swift
//  CubeTime
//
//  Created by Tim Xie on 24/04/22.
//

import SwiftUI

struct FloatingPanel<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
        
    var body: some View {
        GeometryReader { proxy in
            FloatingPanelChild(maxHeight: proxy.size.height, stages: [0, 50, 150, proxy.size.height/2, (proxy.size.height - 24)], content: content)
        }
    }
}

struct FloatingPanelChild<Content: View>: View {
    @State var height: CGFloat = 50
    @State var isPressed: Bool = false
    private let minHeight: CGFloat = 0
    
    let content: Content
    
    
    private var maxHeight: CGFloat
    var stages: [CGFloat]
    
    
    
    init(maxHeight: CGFloat, stages: [CGFloat], content: Content) {
        self.maxHeight = maxHeight
        self.stages = stages
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(uiColor: .systemGray6)
                .ignoresSafeArea()
            
            HStack(alignment: .top) {
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .background(.ultraThinMaterial)
                            
                            .frame(width: 360, height: height)
                        
                            .cornerRadius(10, corners: [.topLeft, .topRight])
                        
                       
                        
                        if height == stages[0] {
                            
                        } else if height == stages[1] {
                            
                        } else if height == stages[2] {
                            
                        } else if height == stages[3] {
                            
                        } else if height == stages[4] {
                            content
                        } else {
                            EmptyView()
                        }
                        
                        
                        
                        
                    }
                        
                    Divider()
                        .frame(width: height == 0 ? 0 : 360)
                    
                    
                    // Dragger
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 360, height: 18)
                            .cornerRadius(10, corners: height == 0 ? .allCorners : [.bottomLeft, .bottomRight])
//                            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                        
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        self.isPressed = true
                                        // Just follow touch within bounds
                                        let newh = height + value.translation.height
                                        if newh > maxHeight {
                                            height = maxHeight
                                        } else if newh < minHeight {
                                            height = minHeight
                                        } else {
                                            height = newh
                                        }
                                    }
                                
                                    .onEnded() { value in
                                        withAnimation(.spring()) {
                                            self.isPressed = false
                                            height = stages.nearest(to: height + value.predictedEndTranslation.height)!.element
                                        }
                                    }
                            )
                        
                        
                        Capsule()
                            .fill(Color(uiColor: isPressed ? .systemGray4 : .systemGray5))
                            .scaleEffect(isPressed ? 1.12 : 1.00)
                            .frame(width: 36, height: 6)
                    }
                }
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 0)
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension Collection {
    subscript (safe index: Index?) -> Element? {
        guard let index = index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}

private extension Array where Element: (Comparable & SignedNumeric) {
    func nearest(to value: Element) -> (offset: Int, element: Element)? {
        self.enumerated().min(by: {
            abs($0.element - value) < abs($1.element - value)
        })
    }
}
