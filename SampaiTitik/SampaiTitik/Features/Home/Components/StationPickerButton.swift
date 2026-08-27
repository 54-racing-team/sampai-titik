//
//  StationPickerButton.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import SwiftUI

struct StationPickerButton: View {
    var iconName: String
    var selection: String
    var action: () -> Void
    
    var body: some View {
        Button{
            action()
        } label: {
            HStack{
                Image(systemName: iconName)
                Text(selection.isEmpty ? "Pilih Stasiun" : selection)
                    .opacity(selection.isEmpty ? 0.5 : 1)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 16)
            .font(.headline)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue.opacity(0.1))
    }
}
