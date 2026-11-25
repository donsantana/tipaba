import SwiftUI

struct ClinicianDashboard: View {
    let userViewModel: UserViewModel
    @State private var searchText = ""
    private enum Destination {
        case patients, supervisors, parents
    }

    @State private var destination: Destination?

    private let blue = Color(red: 0.05, green: 0.43, blue: 1)
    private let ink = Color(red: 0.06, green: 0.11, blue: 0.21)
    private let secondary = Color(red: 0.35, green: 0.41, blue: 0.52)
    private let background = Color(red: 0.97, green: 0.98, blue: 0.99)

    private var displayName: String {
        guard let user = userViewModel.currentUser else { return "Clinician" }
        let name = "\(user.firstname) \(user.lastname)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Clinician" : name
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return "Good morning," }
        if hour < 17 { return "Good afternoon," }
        return "Good evening,"
    }

    var body: some View {
        switch destination {
        case .patients:
            ClinicianPatientsView(userViewModel: userViewModel) {
                destination = nil
            }
        case .supervisors:
            destinationView { SupervisorDashoard() }
        case .parents:
            destinationView { ParentDashboard(userViewModel: userViewModel) }
        case nil:
            dashboardContent
        }
    }

    private func destinationView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    destination = nil
                } label: {
                    Label("Clinician Dashboard", systemImage: "chevron.left")
                }
                Spacer()
            }
            .padding()
            content()
        }
    }

    private var dashboardContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    introduction
                    Text("Manage your clinic, users, and ABA resources in one place.")
                        .font(.subheadline)
                        .foregroundStyle(secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    searchField
                    statistics
                    quickLinks
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
        .background(background.ignoresSafeArea())
        .foregroundStyle(ink)
    }

    private var header: some View {
        HStack {
            HStack(spacing: 0) {
                Text("Tip").foregroundStyle(ink)
                Text("Aba").foregroundStyle(blue)
            }
            .font(.system(size: 27, weight: .bold))
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
                .accessibilityLabel("Profile: \(displayName)")
                .padding(.leading, 12)
        }
    }

    private var introduction: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(secondary)
                Text(displayName)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .lineLimit(2)
                Label("Clinician", systemImage: "stethoscope")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(blue.opacity(0.12), in: Capsule())
            }
            Spacer(minLength: 0)
            Image(systemName: "stethoscope")
                .font(.system(size: 50))
                .foregroundStyle(blue.opacity(0.8))
                .frame(width: 115, height: 100)
                .background(blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 40))
                .accessibilityHidden(true)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(secondary)
            TextField("Search users, patients, or resources...", text: $searchText)
                .font(.subheadline)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.92, green: 0.93, blue: 0.95), in: Capsule())
    }

    private var statistics: some View {
        HStack(spacing: 8) {
            Button { destination = .patients } label: {
                statistic("Patients", symbol: "person.2.fill", color: blue)
            }
            Button { destination = .supervisors } label: {
                statistic("Supervisors", symbol: "person.3.fill", color: .orange)
            }
            Button { destination = .parents } label: {
                statistic("Parents", symbol: "house", color: .purple)
            }
        }
        .buttonStyle(.plain)
    }

    private func statistic(_ title: String, symbol: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text("—")
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private var quickLinks: some View {
        VStack(spacing: 8) {
            if matches("Add User", "Create patients, supervisors, or parents") {
                quickLink("Add User", subtitle: "Create patients, supervisors, or parents", symbol: "person.badge.plus", color: blue)
            }
            if matches("ABA Resources", "Strategies, behaviors, and practical tips") {
                quickLink("ABA Resources", subtitle: "Strategies, behaviors, and practical tips", symbol: "book", color: blue)
            }
            if matches("Clinic Activity", "Usage and engagement overview") {
                quickLink("Clinic Activity", subtitle: "Usage and engagement overview", symbol: "chart.bar.fill", color: .green)
            }
        }
    }

    private func matches(_ title: String, _ subtitle: String) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty || title.localizedCaseInsensitiveContains(query) || subtitle.localizedCaseInsensitiveContains(query)
    }

    private func quickLink(_ title: String, subtitle: String, symbol: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.bold))
                Text(subtitle).font(.caption).foregroundStyle(secondary)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }

    private var bottomBar: some View {
        HStack {
            tabItem("Home", symbol: "house.fill", selected: true)
            Button {
                destination = .patients
            } label: {
                tabItem("Patients", symbol: "person.2")
            }
            .buttonStyle(.plain)
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
    ClinicianDashboard(userViewModel: UserViewModel())
}
