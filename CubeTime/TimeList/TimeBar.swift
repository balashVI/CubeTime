//
//  TimeBar.swift
//  CubeTime
//
//  Created by Tim Xie on 27/12/21.
//

import SwiftUI

struct TimeBar: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    let solvegroup: CompSimSolveGroup
    
    @State var calculatedAverage: CalculatedAverage?
    
    @Binding var currentCalculatedAverage: CalculatedAverage?
    @Binding var isSelectMode: Bool
    
//    @Binding var selectedSolvegroups: [CompSimSolveGroup]
    
    @State var isSelected = false
    
    let current: Bool
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    init(solvegroup: CompSimSolveGroup, currentCalculatedAverage: Binding<CalculatedAverage?>, isSelectMode: Binding<Bool>, current: Bool) {
        self.solvegroup = solvegroup
        self._currentCalculatedAverage = currentCalculatedAverage
        self._isSelectMode = isSelectMode
        self.current = current
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color(uiColor: .systemGray4) : colourScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .systemBackground))
                
                .onTapGesture {
                    if isSelectMode {
                        
                    } else if solvegroup.solves!.count < 5 {
                        // Current average
                        currentCalculatedAverage = CalculatedAverage(name: "Current Average", average: nil, accountedSolves: (solvegroup.solves!.array as! [Solves]), totalPen: .none, trimmedSolves: [])
                    } else {
                        currentCalculatedAverage = calculatedAverage
                    }
                }
                .onLongPressGesture {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                
                
            HStack {
                VStack(spacing: 0) {
                    if let calculatedAverage = calculatedAverage {
                        HStack {
                            Text(formatSolveTime(secs: calculatedAverage.average!, penType: calculatedAverage.totalPen))
                                .font(.title2.weight(.bold))

                            Spacer()
                        }
                        
                        let displayText: NSMutableAttributedString = {
                            let finalStr = NSMutableAttributedString(string: "")
                            
                            let grey: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGray, .font: UIFont.systemFont(ofSize: 17, weight: .medium)]
                            let normal: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
                          
                            
                            for (index, solve) in Array((solvegroup.solves!.array as! [Solves]).enumerated()) {
                                if calculatedAverage.trimmedSolves!.contains(solve) {
                                    finalStr.append(NSMutableAttributedString(string: "(" + formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)) + ")", attributes: grey))
                                } else {
                                    finalStr.append(NSMutableAttributedString(string: formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)), attributes: normal))
                                }
                                if index < solvegroup.solves!.count-1 {
                                    finalStr.append(NSMutableAttributedString(string: ", "))
                                }
                            }
                            
                            return finalStr
                        }()
                                           
                        
                        HStack(spacing: 0) {
                            Text(AttributedString(displayText))
                            
                            Spacer()
                        }
                    } else {
                        if solvegroup.solves!.count < 5 {
                            HStack {
                                Text("Current Average")
                                    .font(.title2.weight(.bold))

                                Spacer()
                            }
                            
                            let displayText: NSMutableAttributedString = {
                                let finalStr = NSMutableAttributedString(string: "")
                                
//                                let normal: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
                                
//                                let normal: [NSAttributedString.Key: Any] = [.font: UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body))]
                                
                                let normal: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.preferredFont(forTextStyle: .body),
                                ]
                                
                                
                                for (index, solve) in Array((solvegroup.solves!.array as! [Solves]).enumerated()) {
                                    finalStr.append(NSMutableAttributedString(string: formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)), attributes: normal))
                                    
                                    if index < solvegroup.solves!.count - 1 {
                                        finalStr.append(NSMutableAttributedString(string: ", "))
                                    }
                                }
                                
                                return finalStr
                            }()

                            
                            
                            
                            
                            
                            HStack(spacing: 0) {
                                Text(AttributedString(displayText))
                                
                                Spacer()
                            }
                        } else {
                            HStack {
                                Text("Loading...")
                                    .font(.title2.weight(.bold))

                                Spacer()
                            }
                        }
                    }
                }
                .padding(.leading, 12)
                .task {
                    await MainActor.run {
                        self.calculatedAverage = getAvgOfSolveGroup(solvegroup)
                    }
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("AccentColor"))
                        .padding(.trailing, 12)
                }
            }
            .padding(.vertical, 6)
        }
        .onChange(of: isSelectMode) {newValue in
            if !newValue && isSelected {
                withAnimation {
                    isSelected = false
                }
            }
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contextMenu {
            Button (role: .destructive) {
                managedObjectContext.delete(solvegroup)
                try! managedObjectContext.save()
                
                
                // timeListManager.refilter() /// and delete this im using this temporarily to update
                
                /* enable when sort works
                withAnimation {
                    timeListManager.resort()
                }
                 */
            } label: {
                Label {
                    Text("Delete Solve Group")
                } icon: {
                    Image(systemName: "trash")
                }
            }
            .disabled(current)
        }
    }
}
