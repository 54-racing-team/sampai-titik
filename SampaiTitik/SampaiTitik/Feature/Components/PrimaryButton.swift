//
//  PrimaryButton.swift
//  SampaiTitik
//
//  Created by Rizki Fitriani on 27/08/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(width: 310)
                .frame(height: 48)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("MainBlue"))
    }
}

struct CardButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(width: 342)
                .frame(height: 52)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("MainBlue"))
    }
}

#Preview {
    PrimaryButton(title: "Mulai Perjalanan") {
        print("Button tapped")
    }
    .padding()
}
