//
//  StationPickerButton.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import SwiftUI

struct StationPickerButton: View {
    var iconName: String
    var selection: StationModelDTO?
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(.mainBlue)
                
                Text(selection?.name ?? "Pilih Stasiun")
                    .fontWeight(.regular)
                    .opacity(selection == nil ? 0.5 : 1)
                Spacer()
                Image(systemName: "chevron.right")
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .font(.headline)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
