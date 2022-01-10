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
    let timeListManager: TimeListManager
    
    @State var calculatedAverage: CalculatedAverage?
    
    @Binding var currentCalculatedAverage: CalculatedAverage?
    @Binding var isSelectMode: Bool
    
//    @Binding var selectedSolvegroups: [CompSimSolveGroup]
    
    @State var isSelected = false
    
    
    init(solvegroup: CompSimSolveGroup, timeListManager: TimeListManager, currentCalculatedAverage: Binding<CalculatedAverage?>, isSelectMode: Binding<Bool>/*, selectedSolves: Binding<[Solves]>*/) {
        self.solvegroup = solvegroup
        self.timeListManager = timeListManager
        self._currentCalculatedAverage = currentCalculatedAverage
        self._isSelectMode = isSelectMode
//        self._selectedSolvegroups = selectedSolves
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color(uiColor: .systemGray4) : colourScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .systemBackground))
                .frame(minHeight: 70, maxHeight: 70) /// todo check operforamcne of the on tap/long hold gestures on the zstack vs the rounded rectange
                
                .onTapGesture {
//                    if isSelectMode {
//                        withAnimation {
//                            if isSelected {
//                                isSelected = false
//                                if let index = selectedSolves.firstIndex(of: solve) {
//                                    selectedSolves.remove(at: index)
//                                }
//                            } else {
//                                isSelected = true
//                                selectedSolves.append(solve)
//                            }
//                        }
//                    } else {
//                        currentSolve = solve
//                    }
                    if isSelectMode {
                        
                    } else if solvegroup.solves!.count < 5 {
                        // Current average
                        currentCalculatedAverage = CalculatedAverage(id: "Current average", average: nil, accountedSolves: (solvegroup.solves!.array as! [Solves]), totalPen: .none, trimmedSolves: [])
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
                                .font(.system(size: 26, weight: .bold, design: .default))

                            Spacer()
                        }
                        
                        HStack(spacing: 0) {
                            ForEach(Array((solvegroup.solves!.array as! [Solves]).enumerated()), id: \.offset) { index, solve in
                                if calculatedAverage.trimmedSolves!.contains(solve) {
                                    Text("(" + formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)) + ")")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                } else {
                                    Text(formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)))
                                        .font(.system(size: 17, weight: .medium))
                                }
                                if index < solvegroup.solves!.count-1 {
                                    Text(", ")
                                }
                            }
                            
                            Spacer()
                        }
                    } else {
                        if solvegroup.solves!.count < 5 {
                            HStack {
                                Text("Current average")
                                    .font(.system(size: 26, weight: .bold, design: .default))

                                Spacer()
                            }
                            
                            HStack(spacing: 0) {
                                ForEach(Array((solvegroup.solves!.array as! [Solves]).enumerated()), id: \.offset) { index, solve in
                                    Text(formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)))
                                        .font(.system(size: 17, weight: .medium))
                                    
                                    if index < solvegroup.solves!.count-1 {
                                        Text(", ")
                                    }
                                }
                                
                                Spacer()
                            }
                        } else {
                            HStack {
                                Text("Loading...")
                                    .font(.system(size: 26, weight: .bold, design: .default))

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
        }
        .onChange(of: isSelectMode) {newValue in
            if !newValue && isSelected {
                withAnimation {
                    isSelected = false
                }
            }
        }
        .contextMenu {
            Button (role: .destructive) {
                managedObjectContext.delete(solvegroup)
                try! managedObjectContext.save()
                
                timeListManager.refilter() /// and delete this im using this temporarily to update
                
                /* enable when sort works
                withAnimation {
                    timeListManager.resort()
                }
                 */
            } label: {
                Label {
                    Text("Delete Solve Group")
                        .foregroundColor(Color.red)
                } icon: {
                    Image(systemName: "trash")
                        .foregroundColor(Color.green) /// FIX: colours not working
                }
            }
        }
    }
}
