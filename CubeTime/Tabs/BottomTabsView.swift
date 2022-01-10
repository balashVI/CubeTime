import SwiftUI

struct BottomTabsView: View {
    @Binding var hide: Bool
    @Binding var currentTab: Tab
    
    var namespace: Namespace.ID
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if !hide {
                GeometryReader { geometry in
                    ZStack {
                        HStack {
                            
                            
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(uiColor: .systemGray5))
                            
                                .frame(
                                    width: geometry.size.width - CGFloat(SetValues.marginLeftRight * 2),
                                    height: CGFloat(SetValues.tabBarHeight),
                                    alignment: .center
                                )
                                .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 3)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        .zIndex(0)
                        
                                            
                        HStack {
                            
                            VStack {
                                VStack {
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .timer,
                                        systemIconName: "stopwatch",
                                        systemIconNameSelected: "stopwatch.fill",
                                        namespace: namespace
                                    )
                                    
    //                                Spacer()
                                    
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .solves,
                                        systemIconName: "hourglass.bottomhalf.filled",
                                        systemIconNameSelected: "hourglass.tophalf.filled",
                                        namespace: namespace
                                    )
                                    
    //                                Spacer()
                                    
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .stats,
                                        systemIconName: "chart.pie",
                                        systemIconNameSelected: "chart.pie.fill",
                                        namespace: namespace
                                    )
                                    
                                    
    //                                Spacer()
                                    
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .sessions,
                                        systemIconName: "line.3.horizontal.circle",
                                        systemIconNameSelected: "line.3.horizontal.circle.fill",
                                        namespace: namespace
                                    )
    //                                    .padding(.trailing, 14)
                                }
                                .frame(
                                    width: CGFloat(SetValues.tabBarHeight),
                                    height: nil,
                                    alignment: .leading
                                )
                                .background(Color(uiColor: .systemGray4).clipShape(RoundedRectangle(cornerRadius:12)))
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3.5)
    //                            .padding(.leading, CGFloat(SetValues.marginLeftRight))
                                .animation(.spring(), value: self.currentTab)
                                
                                Spacer()
                                
                                
                                
                                TabIcon(
                                    currentTab: $currentTab,
                                    assignedTab: .settings,
                                    systemIconName: "gearshape",
                                    systemIconNameSelected: "gearshape.fill"
                                )
    //                                .padding(.trailing, CGFloat(SetValues.marginLeftRight + 12))
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            
                        }
                        .zIndex(1)
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .padding(.bottom, SetValues.hasBottomBar ? CGFloat(0) : nil)
                //.transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
                .transition(.move(edge: .bottom).animation(.easeIn(duration: 6)))
    //            .transition(AnyTransition.scale.animation(.easeIn(duration: 1)))
                //
                
            }
        } else {
            if !hide {
                GeometryReader { geometry in
                    ZStack {
                        VStack {
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(uiColor: .systemGray5))
                            
                                .frame(
                                    width: geometry.size.width - CGFloat(SetValues.marginLeftRight * 2),
                                    height: CGFloat(SetValues.tabBarHeight),
                                    alignment: .center
                                )
                                .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 3)
                                .padding(.horizontal)
                        }
                        .zIndex(0)
                        
                                            
                        VStack {
                            Spacer()
                            
                            HStack {
                                HStack {
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .timer,
                                        systemIconName: "stopwatch",
                                        systemIconNameSelected: "stopwatch.fill",
                                        namespace: namespace
                                    )
                                    
    //                                Spacer()
                                    
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .solves,
                                        systemIconName: "hourglass.bottomhalf.filled",
                                        systemIconNameSelected: "hourglass.tophalf.filled",
                                        namespace: namespace
                                    )
                                    
    //                                Spacer()
                                    
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .stats,
                                        systemIconName: "chart.pie",
                                        systemIconNameSelected: "chart.pie.fill",
                                        namespace: namespace
                                    )
                                    
                                    
    //                                Spacer()
                                    
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .sessions,
                                        systemIconName: "line.3.horizontal.circle",
                                        systemIconNameSelected: "line.3.horizontal.circle.fill",
                                        namespace: namespace
                                    )
    //                                    .padding(.trailing, 14)
                                }
                                .frame(
                                    width: nil,
                                    height: CGFloat(SetValues.tabBarHeight),
                                    alignment: .leading
                                )
                                .background(Color(uiColor: .systemGray4).clipShape(RoundedRectangle(cornerRadius:12)))
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3.5)
    //                            .padding(.leading, CGFloat(SetValues.marginLeftRight))
                                .animation(.spring(), value: self.currentTab)
                                
                                Spacer()
                                
                                
                                
                                TabIcon(
                                    currentTab: $currentTab,
                                    assignedTab: .settings,
                                    systemIconName: "gearshape",
                                    systemIconNameSelected: "gearshape.fill"
                                )
    //                                .padding(.trailing, CGFloat(SetValues.marginLeftRight + 12))
                            }
                            .padding(.horizontal)
                            
                            
                        }
                        .zIndex(1)
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .padding(.bottom, SetValues.hasBottomBar ? CGFloat(0) : nil)
                //.transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
                .transition(.move(edge: .bottom).animation(.easeIn(duration: 6)))
    //            .transition(AnyTransition.scale.animation(.easeIn(duration: 1)))
                //
                
            }
        }
    }
}
