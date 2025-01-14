import SwiftUI
import CoreData
import Combine

// MARK: - MAIN SESSION VIEW
struct SessionsView: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @State var showNewSessionPopUp = false
    
    @FetchRequest(
        entity: Sessions.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Sessions.pinned, ascending: false),
            NSSortDescriptor(keyPath: \Sessions.name, ascending: true)
        ]
    ) var sessions: FetchedResults<Sessions>
    
    var body: some View {
        let _ = NSLog("\(sessions.map({$0.scramble_type}))")
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 10) {
                        ForEach(sessions) { item in
                            SessionCard(item: item, allSessions: sessions)
                        }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.clear).frame(height: 50).padding(.top, 64).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
                
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            showNewSessionPopUp = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2.weight(.semibold))
                                .padding(.leading, -5)
                            Text("New Session")
                                .font(.headline.weight(.medium))
                                .padding(.leading, -2)
                        }
                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
                        .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 0.5))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .background(.ultraThinMaterial, in: Capsule())
                        .sheet(isPresented: $showNewSessionPopUp) {
                            NewSessionModalView(showNewSessionPopUp: $showNewSessionPopUp)
                                .environment(\.managedObjectContext, managedObjectContext)
                        }
                        .padding(.leading)
                        .padding(.bottom, 8)
                        
                        Spacer()
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.clear).frame(height: 50).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
            }
            .navigationTitle("Your Sessions")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


// MARK: - CUSTOMISE SESSIONS
struct CustomiseSessionView: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    let sessionItem: Sessions
    
    @State private var name: String
    @State private var targetStr: String
    @State private var phaseCount: Int
    
    @State var pinnedSession: Bool
    
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @ScaledMetric(relativeTo: .title2) var bigFrameHeight: CGFloat = 220
    
    
    @State private var sessionEventType: Int32
    
    
    init(sessionItem: Sessions) {
        self.sessionItem = sessionItem
        
        self._name = State(initialValue: sessionItem.name ?? "")
        self._pinnedSession = State(initialValue: sessionItem.pinned)
        self._targetStr = State(initialValue: filteredStrFromTime((sessionItem as? CompSimSession)?.target))
        self._phaseCount = State(initialValue: Int((sessionItem as? MultiphaseSession)?.phase_count ?? 0))
        
        self._sessionEventType = State(initialValue: sessionItem.scramble_type)
    }
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .center, spacing: 0) {
                            PuzzleHeaderImage(imageName: puzzle_types[Int(sessionEventType)].name)
                            
                            SessionNameField(name: $name)
                        }
                        .frame(height: bigFrameHeight)
                        .modifier(NewStandardSessionViewBlocks())
                        
                        if sessionItem.session_type == SessionTypes.compsim.rawValue {
                            CompSimTargetEntry(targetStr: $targetStr)
                        }
                        
                        if sessionItem.session_type == SessionTypes.playground.rawValue {
                            EventPicker(sessionEventType: $sessionEventType)
                        }
                        
                        
                        PinSessionToggle(pinnedSession: $pinnedSession)
                    }
                }
                .navigationBarTitle("Customise Session", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            sessionItem.name = name
                            sessionItem.pinned = pinnedSession
                            
                            if sessionItem.session_type == SessionTypes.compsim.rawValue {
                                (sessionItem as! CompSimSession).target = timeFromStr(targetStr)!
                            }
                            
                            if sessionItem.session_type == SessionTypes.multiphase.rawValue {
                                (sessionItem as! MultiphaseSession).phase_count = Int16(phaseCount)
                            }
                            
                            if sessionItem.session_type == SessionTypes.playground.rawValue {
                                if sessionItem == stopWatchManager.currentSession {
                                    stopWatchManager.playgroundScrambleType = sessionEventType
                                } else {
                                    sessionItem.scramble_type = sessionEventType
                                }
                            }
                            
                            try! managedObjectContext.save()
                            
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                        .disabled(self.name.isEmpty || (sessionItem.session_type == SessionTypes.compsim.rawValue && targetStr.isEmpty))
                    }
                }
            }
        }
        .accentColor(accentColour)
        .ignoresSafeArea(.keyboard)
    }
}


// MARK: - NEW SESSION
struct NewSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    let sessionType: SessionTypes
    let typeName: String
    @Binding var showNewSessionPopUp: Bool
    
    // All sessions
    @State private var name: String = ""
    @State var pinnedSession: Bool = false
    
    // Non-Playground
    @State private var sessionEventType: Int32 = 0
    
    // Multiphase
    @State private var phaseCount: Int = 2
    
    // Comp sim
    @State private var targetStr: String = ""
    
    
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @ScaledMetric(relativeTo: .title2) var bigFrameHeight: CGFloat = 220
    @ScaledMetric(relativeTo: .title2) var otherBigFrameHeight: CGFloat = 80

    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    VStack (alignment: .center, spacing: 0) {
                        if sessionType != SessionTypes.playground {
                            PuzzleHeaderImage(imageName: puzzle_types[Int(sessionEventType)].name)
                        }
                        
                        SessionNameField(name: $name)
                            .if(sessionType == SessionTypes.playground) { view in
                                view.padding(.top)
                            }
                        
                        if let session_desc = sessionDescriptions[sessionType] {
                            Text(session_desc)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color(uiColor: .systemGray))
                                .padding([.horizontal, .bottom])
                        }
                    }
                    .modifier(NewStandardSessionViewBlocks())
                    .frame(minHeight: otherBigFrameHeight)
                    
                    if sessionType == .multiphase {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("Phases: ")
                                    .font(.body.weight(.medium))
                                Text("\(phaseCount)")
                                
                                Spacer()
                                
                                Stepper("", value: $phaseCount, in: 2...8)
                                
                            }
                            .padding()
                        }
                        .frame(height: frameHeight)
                        .modifier(NewStandardSessionViewBlocks())
                    } else if sessionType == .compsim {
                        CompSimTargetEntry(targetStr: $targetStr)
                    }
                    
                    
                    
                    if sessionType != .playground {
                        EventPicker(sessionEventType: $sessionEventType)
                    }
                    
                    PinSessionToggle(pinnedSession: $pinnedSession)
                    
                    Spacer()
                }
            }
//            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New \(typeName) Session", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = sessionTypeForID[sessionType, default: Sessions.self].init(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        sessionItem.session_type = sessionType.rawValue
                        
                        if let sessionItem = sessionItem as? MultiphaseSession {
                            sessionItem.phase_count = Int16(phaseCount)
                        } else if let sessionItem = sessionItem as? CompSimSession {
                            sessionItem.target = timeFromStr(targetStr)!
                        }
                        
                        if sessionType != .playground {
                            sessionItem.scramble_type = sessionEventType
                        }
                        
                        try! managedObjectContext.save()
                        stopWatchManager.currentSession = sessionItem
                        showNewSessionPopUp = false
                    } label: {
                        Text("Create")
                    }
                    .disabled(name.isEmpty || (sessionType == .compsim && targetStr.isEmpty))
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct NewSessionModalView: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colourScheme
    
    @State private var showNewStandardSessionView = false
    @State private var showNewAlgTrainerView = false
    @State private var showNewMultiphaseView = false
    @State private var showNewPlaygroundView = false
    @State private var showNewCompsimView = false

    @Binding var showNewSessionPopUp: Bool
    
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    VStack(alignment: .center) {
                        Text("Add New Session")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding(.bottom, 8)
                            .padding(.top, UIScreen.screenHeight/12)
                    }
                    
                    
                    
                    VStack(alignment: .leading, spacing: 48) {
                        NewSessionTypeCardGroup(title: "Normal Sessions") {
                            
                            NewSessionTypeCard(name: "Standard Session", icon: "timer.square", iconProps: SessionTypeIconProps(), show: $showNewStandardSessionView)
                        
                            Divider()
                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Multiphase", icon: "square.stack", iconProps: SessionTypeIconProps(size: 24, leaPadding: 10, traPadding: 6), show: $showNewMultiphaseView)
                            
                            Divider()
                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Playground", icon: "square.on.square", iconProps: SessionTypeIconProps(size: 24), show: $showNewPlaygroundView)
                        }
                        
                        
                        NewSessionTypeCardGroup(title: "Other Sessions") {
//                            NewSessionTypeCard(name: "Algorithm Trainer", icon: "command.square", iconProps: SessionTypeIconProps(), show: $showNewAlgTrainerView)
//
//                            Divider()
//                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Comp Sim", icon: "globe.asia.australia", iconProps: SessionTypeIconProps(weight: .medium), show: $showNewCompsimView)
                        }
                        
                        
                        
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.standard, typeName: "Standard", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewStandardSessionView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.multiphase, typeName: "Multiphase", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewMultiphaseView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.playground, typeName: "Playground", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewPlaygroundView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.compsim, typeName: "Comp Sim", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewCompsimView)
                        
                        Spacer()
                        
                    }
                    
                    
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button {
                                dismiss()
                            } label: {
                                CloseButton()
                                    .padding([.trailing, .top])
                            }
                        }
                        Spacer()
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .accentColor(accentColour)
        }
    }
}


// MARK: - HELPER FUNCTIONS
struct EventPicker: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    
    @Binding var sessionEventType: Int32
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        HStack {
            Text("Session Event")
                .font(.body.weight(.medium))
            
            
            Spacer()
            
            Menu {
                Picker("", selection: $sessionEventType) {
                    ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                        Text(element.name).tag(Int32(index))
                            .font(.body)
                    }
                }
            } label: {
                Text(puzzle_types[Int(sessionEventType)].name)
                    .font(.body)
            }
            .accentColor(accentColour)
            
        }
        .padding()
        .frame(height: frameHeight)
        .modifier(NewStandardSessionViewBlocks())
        
        
        LazyVGrid(columns: sessionEventTypeColumns, spacing: 0) {
            ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                Button {
                    sessionEventType = Int32(index)
                } label: {
                    ZStack {
                        Image("circular-" + element.name)
                        
                        Circle()
                            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: (index == sessionEventType) ? 3 : 0)
                            .frame(width: 54, height: 54)
                            .offset(x: -0.2)
                    }
                }
            }
        }
        .padding()
        .frame(height: 180)
        .modifier(NewStandardSessionViewBlocks())
    }
}

struct SessionNameField: View {
    @Binding var name: String
    
    var body: some View {
        TextField("Session Name", text: $name)
            .padding(12)
            .font(.title2.weight(.semibold))
            .multilineTextAlignment(TextAlignment.center)
            .background(Color(uiColor: .systemGray5))
            .cornerRadius(10)
            .padding([.horizontal, .bottom])
    }
}

struct PuzzleHeaderImage: View {
    let imageName: String
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .padding(.vertical)
            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
    }
}

struct PinSessionToggle: View {
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @Binding var pinnedSession: Bool
    var body: some View {
        Toggle(isOn: $pinnedSession) {
            Text("Pin Session?")
                .font(.body.weight(.medium))
        }
        .tint(.yellow)
        .padding()
        .frame(height: frameHeight)
        .modifier(NewStandardSessionViewBlocks())
    }
}

struct CompSimTargetEntry: View {
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @Binding var targetStr: String
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text("Target")
                    .font(.body.weight(.medium))
                
                Spacer()
                
                TextField("0.00", text: $targetStr)
                    .multilineTextAlignment(.trailing)
                    .modifier(TimeMaskTextField(text: $targetStr))
            }
            .padding()
        }
        .frame(height: frameHeight)
        .modifier(NewStandardSessionViewBlocks())
    }
}

/// **Customise Sessions **


struct NewSessionTypeCard: View {
    @Environment(\.colorScheme) var colourScheme
    let name: String
    let icon: String
    let iconProps: SessionTypeIconProps
    @Binding var show: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: iconProps.size, weight: iconProps.weight))
                .foregroundColor(colourScheme == .light ? .black : .white)
                .padding(.leading, iconProps.leaPadding)
                .padding(.trailing, iconProps.traPadding)
                .padding(.vertical, 8)
            
            Text(name)
                .font(.body)
                .foregroundColor(colourScheme == .light ? .black : .white)
            
            Spacer()
        }
        .background(Color(uiColor: colourScheme == .dark ? .black : .systemGray6))
        .onTapGesture {
            show = true
        }
    }
}

struct NewSessionTypeCardGroup<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    let title: String
    let content: () -> Content
    
    
    @inlinable init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .default))
                .padding(.bottom, 8)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color(uiColor: colourScheme == .dark ? .black : .systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
