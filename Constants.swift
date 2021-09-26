import Foundation

enum Constants {
    // swiftlint:disable line_length

    static let doseDisclaimer = "Dosage information is gathered from users and resources such as clinical studies. It is not a recommendation and should be verified with other sources for accuracy."
    static let substancesDisclaimerWatch = """
This list is neither a suggestion nor an incitement to the consumption of these substances. Using these substances always involves risks and can never be considered safe. Consult a doctor before making medical decisions.
The warning labels in this list do not entail the risks of the substance individually but only highlight dangerous interactions with other substances you've added or interactions you've enabled.
"""

    static let substancesDisclaimerIOS = substancesDisclaimerWatch + " Tap the link on the left to read the corresponding PsychonautWiki article on the wanted and unwanted effects of an individual substance."
}
