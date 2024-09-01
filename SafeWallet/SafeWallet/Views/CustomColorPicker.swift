//
//  CustomColorPicker.swift
//  SafeWallet
//
//  Created by Gonçalo on 30/08/2024.
//

import Foundation
import SwiftUI

struct CustomColorPicker: View {
    @State var selectedColor: Color = .white
    @State private var hue: Double = 0.0
    let wheelSize: CGFloat = 146
    
    var onCancel: () -> Void
    var onSelect: (Color) -> Void

    var body: some View {
            VStack(spacing: 20) {
                ColorWheel(hue: $hue)
                    .frame(width: wheelSize, height: wheelSize)
                    .cornerRadius(wheelSize / 2)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .shadow(radius: 5)
                    )

                Circle()
                    .fill(Color(hue: hue, saturation: 1.0, brightness: 1.0))
                    .frame(width: 80, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                    )

                HStack {
                    Button(action: {
                        onCancel()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        selectedColor = Color(hue: hue, saturation: 1.0, brightness: 1.0)
                        onSelect(selectedColor)
                    }) {
                        Text("Select")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            .onAppear {
                let components = UIColor(selectedColor).hsbComponents
                hue = components.hue
            }
        }
}

struct ColorWheel: View {
    @Binding var hue: Double

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                ForEach(0..<360) { angle in
                    Rectangle()
                        .fill(Color(hue: Double(angle) / 360, saturation: 1.0, brightness: 1.0))
                        .frame(width: 2, height: size / 2)
                        .offset(x: 0, y: -size / 4)
                        .rotationEffect(Angle(degrees: Double(angle)))
                }
            }
            .frame(width: size, height: size)
            .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let dx = value.location.x - size / 2
                            let dy = value.location.y - size / 2
                            let angle = atan2(dy, dx) + .pi / 2
                            let normalizedAngle = (angle >= 0 ? angle : angle + 2 * .pi) / (2 * .pi)
                            hue = normalizedAngle
                        })
        }
        .aspectRatio(1, contentMode: .fit)
    }
}


struct CustomColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomColorPicker(
            onCancel: {
                print("Cancel button pressed")
            },
            onSelect: { selectedColor in
                print("Selected color: \(selectedColor)")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
