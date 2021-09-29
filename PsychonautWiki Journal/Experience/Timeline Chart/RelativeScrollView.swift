import SwiftUI

struct RelativeScrollView<Content: View>: View {

    @Binding var relativeScrollPosition: Double?
    let childWidth: CGFloat
    let isAnimating = true
    var child: () -> Content

    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                ZStack {
                    HStack {
                        // swiftlint:disable identifier_name
                        ForEach(0..<101) { i in
                            Spacer().id(i)
                        }
                    }
                    .frame(width: childWidth)
                    self.child()
                }
            }
            .onAppear {
                scroll(reader, to: relativeScrollPosition)
            }
            .onChange(of: relativeScrollPosition) { newPos in
                scroll(reader, to: newPos)
            }
        }
    }

    private func scroll(_ reader: ScrollViewProxy, to position: Double?) {
        guard let unwrappedPosition = position else { return }
        assert(unwrappedPosition >= 0 && unwrappedPosition <= 1)
        let elementToScrollTo = Int(unwrappedPosition * 100)
        if isAnimating {
            withAnimation {
                reader.scrollTo(elementToScrollTo, anchor: .center)
            }
        } else {
            reader.scrollTo(elementToScrollTo, anchor: .center)
        }
    }
}
