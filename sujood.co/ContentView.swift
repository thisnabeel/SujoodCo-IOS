//
//  ContentView.swift
//  sujood.co
//
//  Ocean-themed Zikr Helper — anatomy-based gratitude dhikr.
//

import SwiftUI
import Combine

// MARK: - Theme (shared with modals)

private enum SujoodTheme {
    static let oceanTop = Color(red: 0x2a/255, green: 0x3b/255, blue: 0x5f/255)
    static let oceanMid = Color(red: 0x1e/255, green: 0x3a/255, blue: 0x5f/255)
    static let oceanBottom = Color(red: 0x0d/255, green: 0x28/255, blue: 0x47/255)
    static let buttonBlue = Color(red: 0x5b/255, green: 0x9f/255, blue: 0xd8/255) // same as Tap button
    static let listRowBg = Color.white.opacity(0.12)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.75)
}

// MARK: - Model

struct Zikr: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var arabic: String
    var transliteration: String
    var reflection: String

    init(id: UUID = UUID(), arabic: String, transliteration: String, reflection: String) {
        self.id = id
        self.arabic = arabic
        self.transliteration = transliteration
        self.reflection = reflection
    }
}

struct ZikrSet: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var zikrs: [Zikr]

    init(id: UUID = UUID(), title: String, zikrs: [Zikr]) {
        self.id = id
        self.title = title
        self.zikrs = zikrs
    }
}

// Predefined Arabic phrases (one of three must be selected when creating/editing a zikr)
private struct PredefinedArabic {
    let arabic: String
    let transliteration: String
    let label: String

    static let all: [PredefinedArabic] = [
        PredefinedArabic(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", label: "Glory be to Allah"),
        PredefinedArabic(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", label: "All praise is for Allah"),
        PredefinedArabic(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", label: "Allah is the Greatest"),
        PredefinedArabic(arabic: "أستغفر الله", transliteration: "Astaghfirullah", label: "I seek forgiveness from Allah")
    ]
}

private struct ArabicPhrasePicker: View {
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(PredefinedArabic.all.enumerated()), id: \.offset) { index, option in
                let isSelected = index == selectedIndex
                Button {
                    selectedIndex = index
                } label: {
                    VStack(spacing: 4) {
                        Text(option.arabic)
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(option.transliteration)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundStyle(isSelected ? SujoodTheme.textPrimary : SujoodTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.06))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

// MARK: - Store (local persistence)

private let zikrSetsStorageKey = "sujood.zikrSets"

final class ZikrStore: ObservableObject {
    @Published var sets: [ZikrSet]

    init() {
        if let data = UserDefaults.standard.data(forKey: zikrSetsStorageKey),
           let decoded = try? JSONDecoder().decode([ZikrSet].self, from: data),
           !decoded.isEmpty {
            self.sets = decoded
        } else {
            self.sets = ZikrStore.defaultData()
            save()
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(sets) else { return }
        UserDefaults.standard.set(data, forKey: zikrSetsStorageKey)
    }

    func addSet(_ set: ZikrSet) {
        sets.append(set)
        save()
    }

    func updateSet(id: UUID, title: String? = nil, zikrs: [Zikr]? = nil) {
        guard let i = sets.firstIndex(where: { $0.id == id }) else { return }
        if let title { sets[i].title = title }
        if let zikrs { sets[i].zikrs = zikrs }
        save()
    }

    func deleteSet(id: UUID) {
        sets.removeAll { $0.id == id }
        save()
    }

    func addZikr(_ zikr: Zikr, toSet setId: UUID) {
        guard let i = sets.firstIndex(where: { $0.id == setId }) else { return }
        sets[i].zikrs.append(zikr)
        save()
    }

    func updateZikr(setId: UUID, zikrId: UUID, arabic: String? = nil, transliteration: String? = nil, reflection: String? = nil) {
        guard let si = sets.firstIndex(where: { $0.id == setId }),
              let zi = sets[si].zikrs.firstIndex(where: { $0.id == zikrId }) else { return }
        if let arabic { sets[si].zikrs[zi].arabic = arabic }
        if let transliteration { sets[si].zikrs[zi].transliteration = transliteration }
        if let reflection { sets[si].zikrs[zi].reflection = reflection }
        save()
    }

    func deleteZikr(setId: UUID, zikrId: UUID) {
        guard let i = sets.firstIndex(where: { $0.id == setId }) else { return }
        sets[i].zikrs.removeAll { $0.id == zikrId }
        save()
    }

    static func defaultData() -> [ZikrSet] {
        [
            ZikrSet(
                title: "My Body",
                zikrs: [
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Thank you Allah for my beating heart, pumping life through my body every moment."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for my eyes, with millions of photoreceptors capturing the beauty of creation."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than my lungs that exchange oxygen 20,000 times a day without me thinking."),
                    Zikr(arabic: "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ", transliteration: "La ilaha illallah", reflection: "There is no deity but Allah who designed my brain with 86 billion neurons."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "All praise to Allah for my liver, performing over 500 vital functions silently."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for my bones, 206 pieces of living tissue supporting my every move."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than my immune system, fighting billions of threats I never see."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Thank you Allah for my hands, with 27 bones in each, capable of creating and caring."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for my digestive system, extracting nutrients from every meal."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than my kidneys, filtering 200 liters of blood daily."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "All praise to Allah for my skin, the largest organ protecting me from harm."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for my ears, with intricate mechanisms detecting the slightest sound."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than my tongue, with 8,000 taste buds experiencing His blessings."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Thank you Allah for my spine, 33 vertebrae perfectly aligned for strength and flexibility."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for my blood vessels, 60,000 miles of pathways in my body.")
                ]
            ),
            ZikrSet(
                title: "Nature",
                zikrs: [
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Praise Allah for the sky, vast and ever-changing, a ceiling of mercy above us."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for the sun, rising and setting in perfect order every day."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than the mountains, standing firm and ancient."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Thank you Allah for rain, reviving the earth and filling rivers and wells."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for the sea, its depths and creatures we have not yet seen."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than the stars, countless and guiding through the night."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Praise Allah for trees, giving shade, fruit, and breathable air."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for the moon, a gentle light and a sign for times and seasons.")
                ]
            ),
            ZikrSet(
                title: "Daily Blessings",
                zikrs: [
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Thank you Allah for this food, sustaining my body and giving me strength."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for a home, a place of safety and rest."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than any worry; He provides when we cannot see how."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Praise Allah for family and friends, love and companionship."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for another day of life, a chance to do better."),
                    Zikr(arabic: "ٱللَّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", reflection: "Allah is greater than any difficulty; with Him nothing is impossible."),
                    Zikr(arabic: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "Alhamdulillah", reflection: "Thank you Allah for sleep and rest, renewing my body and mind."),
                    Zikr(arabic: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SubhanAllah", reflection: "Glory to Allah for clean water to drink and to purify with.")
                ]
            )
        ]
    }
}

// MARK: - Sets Manager (full-screen modal)

struct ZikrSetsManagerView: View {
    @ObservedObject var store: ZikrStore
    @Binding var currentSetIndex: Int
    @Binding var currentZikrIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showAddSet = false
    @State private var setToEdit: ZikrSet?

    private var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [SujoodTheme.oceanTop, SujoodTheme.oceanMid, SujoodTheme.oceanBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(store.sets.enumerated()), id: \.element.id) { index, set in
                    HStack(spacing: 14) {
                        Button {
                            currentSetIndex = index
                            currentZikrIndex = 0
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(set.zikrs.count)")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(SujoodTheme.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.white.opacity(0.15)))
                                Text(set.title)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(SujoodTheme.textPrimary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Button {
                            setToEdit = set
                        } label: {
                            Image(systemName: "pencil")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SujoodTheme.oceanTop)
                                .frame(width: 44, height: 44)
                                .background(Capsule().fill(Color.white.opacity(0.95)))
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 12))
                    .listRowBackground(SujoodTheme.listRowBg)
                    .listRowSeparatorTint(SujoodTheme.textSecondary.opacity(0.4))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) { store.deleteSet(id: set.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(oceanGradient.ignoresSafeArea())
            .tint(SujoodTheme.textPrimary)
            .navigationTitle("Zikr Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SujoodTheme.oceanTop.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(SujoodTheme.textPrimary)
                    }
                }
            }
            .navigationDestination(item: $setToEdit) { set in
                ZikrListInSetView(store: store, set: set)
            }
            .sheet(isPresented: $showAddSet) {
                AddSetSheet(store: store) { showAddSet = false }
            }
        }
    }
}

struct AddSetSheet: View {
    @ObservedObject var store: ZikrStore
    var onDismiss: () -> Void
    @State private var title = ""

    private var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [SujoodTheme.oceanTop, SujoodTheme.oceanMid, SujoodTheme.oceanBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Set title", text: $title)
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                .listRowBackground(SujoodTheme.listRowBg)
                .listRowSeparatorTint(SujoodTheme.textSecondary.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background(oceanGradient.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("New set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SujoodTheme.oceanTop.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addSet(ZikrSet(title: title.trimmingCharacters(in: .whitespaces), zikrs: []))
                        onDismiss()
                    }
                    .foregroundStyle(SujoodTheme.textPrimary)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct ZikrListInSetView: View {
    @ObservedObject var store: ZikrStore
    let set: ZikrSet
    @State private var editingSet: ZikrSet?
    @State private var editingZikr: Zikr?
    @State private var newZikr: Zikr?

    private var currentSet: ZikrSet? { store.sets.first { $0.id == set.id } }

    private var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [SujoodTheme.oceanTop, SujoodTheme.oceanMid, SujoodTheme.oceanBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        Group {
            if let set = currentSet {
                List {
                    ForEach(set.zikrs) { zikr in
                        Button {
                            editingZikr = zikr
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(zikr.arabic)
                                    .font(.body)
                                    .foregroundStyle(SujoodTheme.textPrimary)
                                Text(zikr.reflection)
                                    .font(.caption)
                                    .foregroundStyle(SujoodTheme.textSecondary)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowBackground(SujoodTheme.listRowBg)
                        .listRowSeparatorTint(SujoodTheme.textSecondary.opacity(0.5))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                store.deleteZikr(setId: set.id, zikrId: zikr.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(oceanGradient.ignoresSafeArea())
            } else {
                ContentUnavailableView("Set not found", systemImage: "folder.badge.questionmark")
                    .background(oceanGradient.ignoresSafeArea())
            }
        }
        .tint(SujoodTheme.textPrimary)
        .navigationTitle(currentSet?.title ?? set.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(SujoodTheme.oceanTop.opacity(0.95), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    newZikr = Zikr(arabic: "", transliteration: "", reflection: "")
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Edit set") {
                    if let s = currentSet { editingSet = s }
                }
                .foregroundStyle(SujoodTheme.textPrimary)
            }
        }
        .sheet(item: $editingSet) { s in
            EditSetSheet(store: store, set: s) { editingSet = nil }
        }
        .sheet(item: $editingZikr) { z in
            if let s = currentSet {
                EditZikrSheet(store: store, setId: s.id, zikr: z) { editingZikr = nil }
            }
        }
        .sheet(item: $newZikr) { z in
            if let s = currentSet {
                AddZikrSheet(store: store, setId: s.id, initial: z) { newZikr = nil }
            }
        }
    }
}

struct EditSetSheet: View {
    @ObservedObject var store: ZikrStore
    let set: ZikrSet
    var onDismiss: () -> Void
    @State private var title: String = ""

    private var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [SujoodTheme.oceanTop, SujoodTheme.oceanMid, SujoodTheme.oceanBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Set title", text: $title)
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                .listRowBackground(SujoodTheme.listRowBg)
                .listRowSeparatorTint(SujoodTheme.textSecondary.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background(oceanGradient.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("Edit set")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { title = set.title }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SujoodTheme.oceanTop.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateSet(id: set.id, title: title)
                        onDismiss()
                    }
                    .foregroundStyle(SujoodTheme.textPrimary)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct EditZikrSheet: View {
    @ObservedObject var store: ZikrStore
    let setId: UUID
    let zikr: Zikr
    var onDismiss: () -> Void
    @State private var selectedArabicIndex: Int = 0
    @State private var reflection: String = ""

    private var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [SujoodTheme.oceanTop, SujoodTheme.oceanMid, SujoodTheme.oceanBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var selectedOption: PredefinedArabic { PredefinedArabic.all[selectedArabicIndex] }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ArabicPhrasePicker(selectedIndex: $selectedArabicIndex)
                    TextField("Reflection", text: $reflection, axis: .vertical)
                        .lineLimit(3...8)
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                .listRowBackground(SujoodTheme.listRowBg)
                .listRowSeparatorTint(SujoodTheme.textSecondary.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background(oceanGradient.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("Edit zikr")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let idx = PredefinedArabic.all.firstIndex(where: { $0.arabic == zikr.arabic }) {
                    selectedArabicIndex = idx
                }
                reflection = zikr.reflection
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SujoodTheme.oceanTop.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let o = selectedOption
                        store.updateZikr(setId: setId, zikrId: zikr.id, arabic: o.arabic, transliteration: o.transliteration, reflection: reflection)
                        onDismiss()
                    }
                    .foregroundStyle(SujoodTheme.textPrimary)
                }
            }
        }
    }
}

struct AddZikrSheet: View {
    @ObservedObject var store: ZikrStore
    let setId: UUID
    let initial: Zikr
    var onDismiss: () -> Void
    @State private var selectedArabicIndex: Int = 0
    @State private var reflection: String = ""

    private var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [SujoodTheme.oceanTop, SujoodTheme.oceanMid, SujoodTheme.oceanBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var selectedOption: PredefinedArabic { PredefinedArabic.all[selectedArabicIndex] }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ArabicPhrasePicker(selectedIndex: $selectedArabicIndex)
                    TextField("Reflection", text: $reflection, axis: .vertical)
                        .lineLimit(3...8)
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                .listRowBackground(SujoodTheme.listRowBg)
                .listRowSeparatorTint(SujoodTheme.textSecondary.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background(oceanGradient.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationTitle("New zikr")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { reflection = initial.reflection }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SujoodTheme.oceanTop.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(SujoodTheme.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let o = selectedOption
                        let z = Zikr(arabic: o.arabic, transliteration: o.transliteration, reflection: reflection)
                        store.addZikr(z, toSet: setId)
                        onDismiss()
                    }
                    .foregroundStyle(SujoodTheme.textPrimary)
                }
            }
        }
    }
}

// MARK: - Arabic azkaar count (per phrase, Arabic numerals)

private func arabicNumeral(_ n: Int) -> String {
    let digits = "٠١٢٣٤٥٦٧٨٩"
    return String(n).map { c in
        guard let i = Int(String(c)) else { return String(c) }
        return String(digits[digits.index(digits.startIndex, offsetBy: i)])
    }.joined()
}

private struct AzkaarCountView: View {
    let countsPerPhrase: [String: Int]
    let lastPulsedPhrase: String?
    let lockedPhrase: String?
    var onLockTap: (String) -> Void

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(PredefinedArabic.all, id: \.transliteration) { option in
                let n = countsPerPhrase[option.transliteration] ?? 0
                let isPulsing = option.transliteration == lastPulsedPhrase
                let isLocked = option.transliteration == lockedPhrase
                HStack(spacing: isLocked ? 14 : 10) {
                    Text(option.arabic)
                        .font(.system(size: isLocked ? 20 : 15, weight: .medium, design: .serif))
                        .foregroundStyle(SujoodTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.45)
                    Text("\(n)")
                        .font(.system(size: isLocked ? 24 : 18, weight: .semibold))
                        .foregroundStyle(SujoodTheme.textPrimary.opacity(0.95))
                        .monospacedDigit()
                    Spacer(minLength: 0)
                    Button {
                        onLockTap(option.transliteration)
                    } label: {
                        Image(systemName: isLocked ? "lock.circle.fill" : "lock.circle")
                            .font(.system(size: isLocked ? 28 : 22))
                            .foregroundStyle(isLocked ? SujoodTheme.buttonBlue : SujoodTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, isLocked ? 18 : 12)
                .padding(.vertical, isLocked ? 12 : 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Capsule().fill(isPulsing ? SujoodTheme.buttonBlue : Color.white.opacity(0.12)))
                .scaleEffect(isPulsing ? 1.05 : (isLocked ? 1.12 : 1.0))
                .animation(.easeOut(duration: 0.1), value: lastPulsedPhrase)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Wave Shape

struct OceanWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h))
        path.addCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.6),
            control1: CGPoint(x: w * 0.08, y: h),
            control2: CGPoint(x: w * 0.2, y: h * 0.3)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.75),
            control1: CGPoint(x: w * 0.35, y: h * 0.4),
            control2: CGPoint(x: w * 0.45, y: h)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.75, y: h * 0.5),
            control1: CGPoint(x: w * 0.6, y: h * 0.6),
            control2: CGPoint(x: w * 0.7, y: h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: w, y: h),
            control1: CGPoint(x: w * 0.88, y: h * 0.7),
            control2: CGPoint(x: w, y: h)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Main View

struct ContentView: View {
    @StateObject private var store = ZikrStore()
    @State private var count = 0
    @State private var countsPerPhrase: [String: Int] = [:] // transliteration -> count (which azkaar you've done more of)
    @State private var currentZikrIndex = 0
    @State private var currentSetIndex = 0
    @State private var displayZikrs: [Zikr] = [] // shuffled order for current set
    @State private var arabicPulseScale: CGFloat = 1.0
    @State private var showSetsManager = false
    @State private var lastPulsedPhrase: String? = nil // transliteration of card that just got +1 (for pulse)
    @State private var selectZikrIdAfterSetChange: UUID? = nil // when set via lock, jump to this zikr after shuffle
    @State private var lockedPhrase: String? = nil // transliteration of phrase that is locked (lock icon filled)

    private var sets: [ZikrSet] { store.sets }
    private var currentSet: ZikrSet? {
        guard currentSetIndex < sets.count else { return nil }
        return sets[currentSetIndex]
    }
    private var current: Zikr? {
        guard currentZikrIndex < displayZikrs.count else { return nil }
        return displayZikrs[currentZikrIndex]
    }

    private func onZikrTap() {
        count += 1
        if let zikr = current {
            countsPerPhrase[zikr.transliteration, default: 0] += 1
            withAnimation(.easeOut(duration: 0.1)) { lastPulsedPhrase = zikr.transliteration }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.2)) { lastPulsedPhrase = nil }
            }
        }
        withAnimation(.easeOut(duration: 0.1)) { arabicPulseScale = 1.05 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) { arabicPulseScale = 1.0 }
        }
        // Cycle: when locked, only cycle through zikrs matching locked phrase across sets; else next in current set
        if let phrase = lockedPhrase {
            cycleToNextMatching(transliteration: phrase)
        } else {
            guard !displayZikrs.isEmpty else { return }
            currentZikrIndex = (currentZikrIndex + 1) % displayZikrs.count
        }
    }

    /// Move to the next zikr that has this transliteration (across all sets). Wraps to first at end.
    private func cycleToNextMatching(transliteration: String) {
        let list = indicesForPhrase(transliteration: transliteration)
        guard !list.isEmpty else { return }
        let currentId = current?.id
        let currentListIndex = list.firstIndex { (si, zi) in
            sets[si].zikrs[zi].id == currentId
        } ?? 0
        let next = (currentListIndex + 1) % list.count
        let (nextSetIndex, nextZikrIndex) = list[next]
        let targetZikr = sets[nextSetIndex].zikrs[nextZikrIndex]
        if nextSetIndex == currentSetIndex {
            if let idx = displayZikrs.firstIndex(where: { $0.id == targetZikr.id }) {
                currentZikrIndex = idx
            }
        } else {
            selectZikrIdAfterSetChange = targetZikr.id
            currentSetIndex = nextSetIndex
        }
    }

    private let oceanTop = SujoodTheme.oceanTop
    private let oceanMid = SujoodTheme.oceanMid
    private let oceanBottom = SujoodTheme.oceanBottom
    private let buttonTop = Color(red: 0x5b/255, green: 0x9f/255, blue: 0xd8/255)
    private let buttonBottom = Color(red: 0x3b/255, green: 0x7f/255, blue: 0xb8/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            // Ocean gradient background
            LinearGradient(
                colors: [oceanTop, oceanMid, oceanBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Wave decoration at bottom
            OceanWaveShape()
                .fill(Color.blue.opacity(0.15))
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)

            if sets.isEmpty {
                emptyState
            } else if let set = currentSet, let zikr = current {
                mainContent(set: set, displayZikrs: displayZikrs, zikr: zikr, countsPerPhrase: countsPerPhrase, lastPulsedPhrase: lastPulsedPhrase, lockedPhrase: lockedPhrase, onLockTap: onLockTap)
            } else {
                emptySetState
            }
        }
        .onAppear {
            shuffleCurrentSetZikrs()
            clampIndices()
        }
        .onChange(of: store.sets.count) { _, _ in clampIndices() }
        .onChange(of: currentSetIndex) { _, _ in
            shuffleCurrentSetZikrs()
            clampIndices()
        }
        .fullScreenCover(isPresented: $showSetsManager) {
            ZikrSetsManagerView(store: store, currentSetIndex: $currentSetIndex, currentZikrIndex: $currentZikrIndex)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("No zikr sets yet")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.9))
            Text("Tap below to create sets and add zikrs.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Manage sets") { showSetsManager = true }
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptySetState: some View {
        VStack(spacing: 20) {
            Text("No zikrs in this set")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.9))
            Text("Open Manage sets to add zikrs to \(currentSet?.title ?? "this set").")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Manage sets") { showSetsManager = true }
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func shuffleCurrentSetZikrs() {
        guard let set = currentSet, !set.zikrs.isEmpty else {
            displayZikrs = []
            selectZikrIdAfterSetChange = nil
            return
        }
        displayZikrs = set.zikrs.shuffled()
        if let targetId = selectZikrIdAfterSetChange,
           let idx = displayZikrs.firstIndex(where: { $0.id == targetId }) {
            currentZikrIndex = idx
            selectZikrIdAfterSetChange = nil
        } else {
            currentZikrIndex = 0
        }
    }

    /// All (setIndex, zikrIndex) where that zikr has the given transliteration, in order across sets.
    private func indicesForPhrase(transliteration: String) -> [(setIndex: Int, zikrIndex: Int)] {
        var result: [(Int, Int)] = []
        for (si, set) in sets.enumerated() {
            for (zi, zikr) in set.zikrs.enumerated() {
                if zikr.transliteration == transliteration {
                    result.append((si, zi))
                }
            }
        }
        return result
    }

    /// Go to the first zikr that has this transliteration (search sets in order until one is found).
    private func goToFirstMatching(transliteration: String) {
        let list = indicesForPhrase(transliteration: transliteration)
        guard let first = list.first else { return }
        let targetZikr = sets[first.setIndex].zikrs[first.zikrIndex]
        if first.setIndex == currentSetIndex {
            if let idx = displayZikrs.firstIndex(where: { $0.id == targetZikr.id }) {
                currentZikrIndex = idx
            }
        } else {
            selectZikrIdAfterSetChange = targetZikr.id
            currentSetIndex = first.setIndex
        }
    }

    private func onLockTap(transliteration: String) {
        if lockedPhrase == transliteration {
            lockedPhrase = nil
            return
        }
        lockedPhrase = transliteration
        goToFirstMatching(transliteration: transliteration)
    }

    private func clampIndices() {
        if currentSetIndex >= sets.count {
            currentSetIndex = max(0, sets.count - 1)
        }
        if currentZikrIndex >= displayZikrs.count {
            currentZikrIndex = max(0, displayZikrs.count - 1)
        }
    }

    private func mainContent(set: ZikrSet, displayZikrs: [Zikr], zikr: Zikr, countsPerPhrase: [String: Int], lastPulsedPhrase: String?, lockedPhrase: String?, onLockTap: @escaping (String) -> Void) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

                // Say / Set title / Arabic / Transliteration (pulses on tap)
                VStack(spacing: 8) {
                    Text(zikr.arabic)
                        .font(.system(size: 36, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .lineSpacing(6)

                    Text(zikr.transliteration)
                        .font(.title3)
                        .italic()
                        .foregroundStyle(.white.opacity(0.7))

                    Text("For:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.85))
                    Button {
                        showSetsManager = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(set.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.subheadline)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.white.opacity(0.15)))
                    }
                    .buttonStyle(.plain)
                }
                .scaleEffect(arabicPulseScale)
                .padding(.horizontal)

                // Think / Reflection — swipe left/right to change zikr
                VStack(alignment: .leading, spacing: 10) {
                    // Text("Think:")
                    //     .font(.title3)
                    //     .fontWeight(.medium)
                    //     .tracking(0.5)
                    //     .foregroundStyle(.white.opacity(0.8))

                    TabView(selection: $currentZikrIndex) {
                        ForEach(Array(displayZikrs.enumerated()), id: \.element.id) { index, z in
                            Text(z.reflection)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                                .lineSpacing(4)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10) // room so scale doesn’t clip edges
                                .scaleEffect(arabicPulseScale)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 60)

                    // Page indicator dots
                    HStack(spacing: 6) {
                        ForEach(0..<displayZikrs.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentZikrIndex ? Color.white : Color.white.opacity(0.35))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 36)
                .padding(.top, 20)

                Spacer(minLength: 24)

                // Large circular button
                ZikrButton(
                    buttonTop: buttonTop,
                    buttonBottom: buttonBottom,
                    action: onZikrTap
                )

                Spacer(minLength: 24)

                // Arabic azkaar count (per phrase, Arabic numerals)
                AzkaarCountView(countsPerPhrase: countsPerPhrase, lastPulsedPhrase: lastPulsedPhrase, lockedPhrase: lockedPhrase, onLockTap: onLockTap)

                Spacer(minLength: 40)
            }
            .zIndex(1)
    }
}

// MARK: - Scale on press button style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Zikr Button (gradient circle + haptic)

struct ZikrButton: View {
    let buttonTop: Color
    let buttonBottom: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [buttonTop, buttonBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                )
                .overlay(
                    Text("Tap")
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(.white.opacity(0.95))
                )
                .shadow(color: Color.blue.opacity(0.5), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
        .frame(width: 280, height: 280)
    }
}

#Preview {
    ContentView()
}
