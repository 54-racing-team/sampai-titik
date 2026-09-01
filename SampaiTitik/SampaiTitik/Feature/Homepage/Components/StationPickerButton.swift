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
                .foregroundStyle(.mainBlue)
                Text(selection.isEmpty ? "Pilih Stasiun" : selection)
                .font(.body)
                .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 16)
            .font(.headline)
            .background(Color("BackgroundBlue"))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
