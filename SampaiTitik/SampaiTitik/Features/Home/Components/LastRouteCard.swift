//
//  LastRouteCard.swift
//  SampaiTitik
//
//  Created by Salman on 27/08/26.
//

import SwiftUI

struct LastRouteCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Kemarin · 22.15")
                    .foregroundStyle(.gray)
                    .font(.caption)
                
                HStack {
                    VStack {
                        Image(systemName: "circle")
                            .fontWeight(.bold)
                      
                        DottedLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 2]))
                            .frame(width: 1, height: 20)
                            .foregroundColor(Color.black)
                            
                        
                        Image(systemName: "circle")
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 28) {
                        Text("Pasar Minggu Baru")
                        Text("Metland Telaga Murni")
                    }
                    .font(.subheadline.bold())
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Pakai lagi")
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    struct DottedLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
            return path
        }
    }
}

#Preview {
    LastRouteCard()
}
