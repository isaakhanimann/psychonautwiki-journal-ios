import SwiftUI

struct UnknownDoseAlert: View {

    @ObservedObject var viewModel: ChooseDoseView.ViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            title
            textBody
            buttons
                .padding(.top, 10)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .clipped()
        .padding(.horizontal, 20)
    }

    var title: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            Text("Test Your Substance!")
                .font(.title.bold())
        }
    }

    var textBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            // swiftlint:disable line_length
            Text("Taking an unknown dose can lead to overdose. Dose your substance with a milligram scale or volumetrically. Test your substance to make sure that it really is what you believe it is and doesn’t contain any dangerous adulterants. If you live in Austria, Belgium, Canada, France, Italy, Netherlands, Spain or Switzerland there are anonymous and free drug testing services available to you, else you can purchase an inexpensive reagent testing kit.")
        }
    }

    var buttons: some View {
        HStack {
            Button("Cancel") {
                viewModel.isShowingUnknownDoseAlert.toggle()
            }
            Spacer()
            Button("Use Unknown Dose") {
                viewModel.isShowingUnknownDoseAlert.toggle()
                viewModel.selectedPureDose = nil
                viewModel.isShowingNext = true
            }
            .foregroundColor(.red)
        }
    }
}

struct UnknownDoseAlert_Previews: PreviewProvider {
    static var previews: some View {
        UnknownDoseAlert(viewModel: ChooseDoseView.ViewModel())
    }
}
