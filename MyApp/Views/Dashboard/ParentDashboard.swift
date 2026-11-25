//
//  ParentDashboard.swift
//  Tipaba
//

import SwiftUI

struct ParentDashboard: View {
    let userViewModel: UserViewModel
    @State private var searchText = ""

    private let blue = Color(red: 0.18, green: 0.47, blue: 1)
    private let ink = Color(red: 0.09, green: 0.13, blue: 0.20)
    private let secondary = Color(red: 0.47, green: 0.53, blue: 0.63)
    private let background = Color(red: 0.97, green: 0.98, blue: 0.99)

    private let behaviors: [Behavior] = [
        Behavior(title: "Loud vocalizations", subtitle: "Strategies for responding", symbol: "headphones", color: .green),
        Behavior(title: "Repetitive movements", subtitle: "Understand and respond", symbol: "arrow.triangle.2.circlepath", color: .blue),
        Behavior(title: "Leaving an area", subtitle: "Safety and prevention tips", symbol: "door.left.hand.open", color: .orange),
        Behavior(title: "Refusing a task", subtitle: "Encouragement and support", symbol: "hand.raised.fill", color: .red),
        Behavior(title: "Difficulty with transitions", subtitle: "Make changes easier", symbol: "figure.2.and.child.holdinghands", color: .purple)
    ]

    private var filteredBehaviors: [Behavior] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return behaviors
        }
        return behaviors.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    introduction
                        .padding(.top, 24)
                    searchField
                        .padding(.top, 18)

                    sectionHeading(GlobalStrings.commonBehaviorsTitle)
                        .padding(.top, 22)

                    if filteredBehaviors.isEmpty {
                        Text(GlobalStrings.noBehaviorsText)
                            .font(.subheadline)
                            .foregroundStyle(secondary)
                            .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(filteredBehaviors) { behavior in
                                behaviorRow(behavior)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
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
            Text(userViewModel.nameInitials)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(blue)
                .frame(width: 38, height: 38)
                .background(blue.opacity(0.17), in: Circle())
                .accessibilityLabel("Profile: \(userViewModel.nameInitials)")
        }
    }

    private var introduction: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Good afternoon,")
                    .font(.subheadline)
                    .foregroundStyle(secondary)
                Text("How can we help\ntoday?")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                Text("Find practical ABA strategies for everyday situations.")
                    .font(.caption)
                    .foregroundStyle(secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(secondary)
            TextField("Search a behavior...", text: $searchText)
                .font(.subheadline)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(red: 0.92, green: 0.93, blue: 0.95), in: Capsule())
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }

    private func behaviorRow(_ behavior: Behavior) -> some View {
        HStack(spacing: 14) {
            Image(systemName: behavior.symbol)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(behavior.color)
                .frame(width: 46, height: 46)
                .background(behavior.color.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(behavior.title)
                    .font(.subheadline.weight(.semibold))
                Text(behavior.subtitle)
                    .font(.caption)
                    .foregroundStyle(secondary)
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
            tabItem("Saved", symbol: "bookmark", selected: false)
            tabItem("Profile", symbol: "person", selected: false)
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(background)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private func tabItem(_ title: String, symbol: String, selected: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .semibold))
            Text(title)
                .font(.caption2)
        }
        .foregroundStyle(selected ? blue : secondary)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct Behavior: Identifiable {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color

    var id: String { title }
}

#Preview {
    ParentDashboard(userViewModel: UserViewModel())
}
