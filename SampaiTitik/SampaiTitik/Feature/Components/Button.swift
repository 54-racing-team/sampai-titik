//
//  Button.swift
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
                .padding(.vertical, 12)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("MainBlue"))
    }
}

struct DestructiveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(width: 310)
                .padding(.vertical, 12)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.red)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(.white))
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .buttonStyle(.glassProminent)
        .tint(Color("MainBlue"))
    }
}

#Preview {
    CardButton(title: "Mulai Perjalanan") {
        print("Button tapped")
    }
    .padding()
}
