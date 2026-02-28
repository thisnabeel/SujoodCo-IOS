//
//  ContentView.swift
//  sujood.co
//
//  Ocean-themed Zikr Helper — anatomy-based gratitude dhikr.
//

import SwiftUI

// MARK: - Model

struct Zikr: Identifiable {
    let id = UUID()
    let arabic: String
    let transliteration: String
    let reflection: String
}

struct ZikrSet: Identifiable {
    let id = UUID()
    let title: String
    let zikrs: [Zikr]

    static let all: [ZikrSet] = [
        ZikrSet(
            title: "My Body",
            zikrs: [
                Zikr(
                    arabic: "ٱلْحَمْدُ لِلَّٰهِ",
                    transliteration: "Alhamdulillah",
                    reflection: "Thank you Allah for my beating heart, pumping life through my body every moment."
                ),
                Zikr(
                    arabic: "سُبْحَانَ ٱللَّٰهِ",
                    transliteration: "SubhanAllah",
                    reflection: "Glory to Allah for my eyes, with millions of photoreceptors capturing the beauty of creation."
                ),
                Zikr(
                    arabic: "ٱللَّٰهُ أَكْبَرُ",
                    transliteration: "Allahu Akbar",
                    reflection: "Allah is greater than my lungs that exchange oxygen 20,000 times a day without me thinking."
                ),
                Zikr(
                    arabic: "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
                    transliteration: "La ilaha illallah",
                    reflection: "There is no deity but Allah who designed my brain with 86 billion neurons."
                ),
                Zikr(
                    arabic: "ٱلْحَمْدُ لِلَّٰهِ",
                    transliteration: "Alhamdulillah",
                    reflection: "All praise to Allah for my liver, performing over 500 vital functions silently."
                ),
                Zikr(
                    arabic: "سُبْحَانَ ٱللَّٰهِ",
                    transliteration: "SubhanAllah",
                    reflection: "Glory to Allah for my bones, 206 pieces of living tissue supporting my every move."
                ),
                Zikr(
                    arabic: "ٱللَّٰهُ أَكْبَرُ",
                    transliteration: "Allahu Akbar",
                    reflection: "Allah is greater than my immune system, fighting billions of threats I never see."
                ),
                Zikr(
                    arabic: "ٱلْحَمْدُ لِلَّٰهِ",
                    transliteration: "Alhamdulillah",
                    reflection: "Thank you Allah for my hands, with 27 bones in each, capable of creating and caring."
                ),
                Zikr(
                    arabic: "سُبْحَانَ ٱللَّٰهِ",
                    transliteration: "SubhanAllah",
                    reflection: "Glory to Allah for my digestive system, extracting nutrients from every meal."
                ),
                Zikr(
                    arabic: "ٱللَّٰهُ أَكْبَرُ",
                    transliteration: "Allahu Akbar",
                    reflection: "Allah is greater than my kidneys, filtering 200 liters of blood daily."
                ),
                Zikr(
                    arabic: "ٱلْحَمْدُ لِلَّٰهِ",
                    transliteration: "Alhamdulillah",
                    reflection: "All praise to Allah for my skin, the largest organ protecting me from harm."
                ),
                Zikr(
                    arabic: "سُبْحَانَ ٱللَّٰهِ",
                    transliteration: "SubhanAllah",
                    reflection: "Glory to Allah for my ears, with intricate mechanisms detecting the slightest sound."
                ),
                Zikr(
                    arabic: "ٱللَّٰهُ أَكْبَرُ",
                    transliteration: "Allahu Akbar",
                    reflection: "Allah is greater than my tongue, with 8,000 taste buds experiencing His blessings."
                ),
                Zikr(
                    arabic: "ٱلْحَمْدُ لِلَّٰهِ",
                    transliteration: "Alhamdulillah",
                    reflection: "Thank you Allah for my spine, 33 vertebrae perfectly aligned for strength and flexibility."
                ),
                Zikr(
                    arabic: "سُبْحَانَ ٱللَّٰهِ",
                    transliteration: "SubhanAllah",
                    reflection: "Glory to Allah for my blood vessels, 60,000 miles of pathways in my body."
                )
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
    @State private var count = 0
    @State private var currentZikrIndex = 0
    @State private var currentSetIndex = 0
    @State private var arabicPulseScale: CGFloat = 1.0

    private var currentSet: ZikrSet { ZikrSet.all[currentSetIndex] }
    private var current: Zikr { currentSet.zikrs[currentZikrIndex] }

    private func onZikrTap() {
        count += 1
        withAnimation(.easeOut(duration: 0.1)) { arabicPulseScale = 1.05 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) { arabicPulseScale = 1.0 }
        }
    }

    private let oceanTop = Color(red: 0x2a/255, green: 0x3b/255, blue: 0x5f/255)
    private let oceanMid = Color(red: 0x1e/255, green: 0x3a/255, blue: 0x5f/255)
    private let oceanBottom = Color(red: 0x0d/255, green: 0x28/255, blue: 0x47/255)
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

            VStack(spacing: 0) {
                Spacer(minLength: 80)

                // Say / Set title / Arabic / Transliteration (pulses on tap)
                VStack(spacing: 8) {
                    

                    // Text("Say:")
                    //     .font(.title2)
                    //     .fontWeight(.medium)
                    //     .tracking(1)
                    //     .foregroundStyle(.white.opacity(0.8))

                    Text(current.arabic)
                        .font(.system(size: 36, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .lineSpacing(6)

                    Text(current.transliteration)
                        .font(.title3)
                        .italic()
                        .foregroundStyle(.white.opacity(0.7))

                    Text("For:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.85))
                    Menu {
                        ForEach(Array(ZikrSet.all.enumerated()), id: \.offset) { index, set in
                            Button(set.title) {
                                currentSetIndex = index
                                currentZikrIndex = 0
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(currentSet.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.subheadline)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.white.opacity(0.15)))
                    }
                }
                .scaleEffect(arabicPulseScale)
                .padding(.horizontal)

                // Think / Reflection — swipe left/right to change zikr
                VStack(alignment: .leading, spacing: 6) {
                    // Text("Think:")
                    //     .font(.title3)
                    //     .fontWeight(.medium)
                    //     .tracking(0.5)
                    //     .foregroundStyle(.white.opacity(0.8))

                    TabView(selection: $currentZikrIndex) {
                        ForEach(Array(currentSet.zikrs.enumerated()), id: \.offset) { index, zikr in
                            Text(zikr.reflection)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                                .lineSpacing(4)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10) // room so scale doesn’t clip edges
                                .scaleEffect(arabicPulseScale)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 80)
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

                // Counter
                Text("Count: \(count)")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)

                Spacer(minLength: 32)
            }
            .zIndex(1)
        }
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
