//import SwiftUI
//
//struct Joystick: View {
//    @Binding var direction: CGVector
//
//    @GestureState private var dragOffset: CGSize = .zero
//    let size: CGFloat = 100
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: size, height: size)
//
//            Circle()
//                .fill(Color.gray)
//                .frame(width: size / 2.5, height: size / 2.5)
//                .offset(dragOffset)
//                .gesture(
//                    DragGesture()
//                        .updating($dragOffset) { value, state, _ in
//                            let radius = size / 2
//                            var offset = value.translation
//
//                            // Clamp to radius
//                            let distance = sqrt(offset.width * offset.width + offset.height * offset.height)
//                            if distance > radius {
//                                let scale = radius / distance
//                                offset = CGSize(width: offset.width * scale, height: offset.height * scale)
//                            }
//
//                            state = offset
//                            direction = CGVector(dx: offset.width / radius, dy: -offset.height / radius)
//                        }
//                        .onEnded { _ in
//                            direction = .zero
//                        }
//                )
//        }
//    }
//}
