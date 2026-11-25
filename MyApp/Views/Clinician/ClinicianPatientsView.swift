import SwiftUI

struct ClinicianPatientsView: View {
    let userViewModel: UserViewModel
    let onHome: () -> Void

    @State private var searchText = ""

    private let blue = Color(red: 0.05, green: 0.43, blue: 1)
    private let ink = Color(red: 0.06, green: 0.11, blue: 0.21)
    private let secondary = Color(red: 0.35, green: 0.41, blue: 0.52)
    private let background = Color(red: 0.97, green: 0.98, blue: 0.99)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    categoryBar
                    HStack {
                        Text("Patients")
                            .font(.title2.bold())
                        Spacer()
                        Button {} label: {
                            Label("Add Patient", systemImage: "plus")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(blue, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(true)
                    }
                    searchField
                    VStack(spacing: 8) {
                        Image(systemName: "person.2")
                            .font(.largeTitle)
                        Text(searchText.isEmpty ? "No patients yet" : "No patients found")
                            .font(.headline)
                        Text(searchText.isEmpty ? "Patients will appear here when they are added." : "Try a different search.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            bottomBar
        }
        .foregroundStyle(ink)
        .background(background.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onHome) {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }
            .accessibilityLabel("Back to home")
            HStack(spacing: 0) {
                Text("Tip").foregroundStyle(ink)
                Text("Aba").foregroundStyle(blue)
            }
            .font(.title3.bold())
            Spacer()
            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(secondary)
                .accessibilityLabel("Notifications")
            Text(userViewModel.nameInitials)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(blue)
                .frame(width: 38, height: 38)
                .background(blue.opacity(0.14), in: Circle())
                .accessibilityLabel("Profile: \(userViewModel.nameInitials)")
        }
        .foregroundStyle(blue)
    }

    private var categoryBar: some View {
        HStack(spacing: 0) {
            Text("Patients")
                .foregroundStyle(blue)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.white, in: Capsule())
                .accessibilityAddTraits(.isSelected)
            Text("Supervisors")
                .frame(maxWidth: .infinity)
            Text("Parents")
                .frame(maxWidth: .infinity)
        }
        .font(.subheadline)
        .foregroundStyle(secondary)
        .padding(2)
        .background(Color(red: 0.92, green: 0.93, blue: 0.95), in: Capsule())
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(secondary)
            TextField("Search patients...", text: $searchText)
                .font(.subheadline)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.92, green: 0.93, blue: 0.95), in: Capsule())
    }

    private var bottomBar: some View {
        HStack {
            Button(action: onHome) {
                tabItem("Home", symbol: "house")
            }
            .buttonStyle(.plain)
            tabItem("Patients", symbol: "person.2.fill", selected: true)
            tabItem("Supervisors", symbol: "person.3")
            tabItem("Parents", symbol: "house")
            tabItem("More", symbol: "ellipsis")
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(background)
        .overlay(alignment: .top) { Divider() }
    }

    private func tabItem(_ title: String, symbol: String, selected: Bool = false) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol).font(.system(size: 19, weight: .semibold))
            Text(title).font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
        }
        .foregroundStyle(selected ? blue : secondary)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

#Preview {
    ClinicianPatientsView(userViewModel: UserViewModel(), onHome: {})
}
