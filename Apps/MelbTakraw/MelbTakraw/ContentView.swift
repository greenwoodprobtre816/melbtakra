import SwiftUI

struct RootView: View {
    @State private var selectedSection: AppSection = .dashboard
    @StateObject private var trainerStore = TrainerStore()
    @StateObject private var settings = AppSettings()
    @StateObject private var progressStore = ProgressStore()

    private var contentLayoutDirection: LayoutDirection {
        settings.selectedLanguageCode == AppLanguage.ar.rawValue ? .rightToLeft : .leftToRight
    }

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                appShell
            } else {
                OnboardingView(settings: settings)
            }
        }
        .environment(\.locale, Locale(identifier: settings.selectedLanguageCode))
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private var appShell: some View {
        phoneLayout
    }

    private var phoneLayout: some View {
        TabView(selection: $selectedSection) {
            ForEach(AppSection.allCases) { section in
                NavigationStack {
                    sectionView(for: section)
                }
                .id("phone-nav-\(section.rawValue)-\(settings.selectedLanguageCode)")
                .tabItem {
                    Label {
                        Text(LocalizedStringKey(section.titleKey))
                    } icon: {
                        Image(systemName: section.iconName)
                    }
                }
                .tag(section)
            }
        }
        .environment(\.layoutDirection, contentLayoutDirection)
        .id("phone-shell-\(settings.selectedLanguageCode)")
        .tint(AppTheme.brandYellow)
    }

    @ViewBuilder
    private func sectionView(for section: AppSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView(progressStore: progressStore)
        case .learn:
            LearnView(progressStore: progressStore)
        case .trainer:
            TrainerView(store: trainerStore, settings: settings, progressStore: progressStore)
        case .history:
            HistoryView()
        case .settings:
            SettingsView(settings: settings, progressStore: progressStore)
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var settings: AppSettings
    @State private var pageIndex = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("app.name")
                        .font(.title2.weight(.bold))
                    Spacer()
                    Text("\(pageIndex + 1)/\(AppData.onboardingPages.count)")
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 18) {
                    Image(systemName: AppData.onboardingPages[pageIndex].symbol)
                        .font(.system(size: 42))
                        .foregroundStyle(AppTheme.brandYellow)

                    Text(LocalizedStringKey(AppData.onboardingPages[pageIndex].titleKey))
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text(LocalizedStringKey(AppData.onboardingPages[pageIndex].bodyKey))
                        .foregroundStyle(AppTheme.textSecondary)
                        .font(.body.leading(.loose))
                }
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

                HStack(spacing: 10) {
                    ForEach(0..<AppData.onboardingPages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == pageIndex ? AppTheme.brandYellow : Color.white.opacity(0.16))
                            .frame(width: index == pageIndex ? 34 : 12, height: 10)
                    }
                }

                Spacer()

                HStack {
                    if pageIndex > 0 {
                        Button("onboarding.back") {
                            pageIndex -= 1
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.brandYellow)
                    }

                    Spacer()

                    Button(pageIndex == AppData.onboardingPages.count - 1 ? String(localized: "onboarding.start") : String(localized: "onboarding.next")) {
                        if pageIndex == AppData.onboardingPages.count - 1 {
                            settings.hasCompletedOnboarding = true
                        } else {
                            pageIndex += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.brandYellow)
                    .foregroundStyle(.black)
                }
            }
            .padding(24)
        }
    }
}

struct DashboardView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var progressStore: ProgressStore

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 280 : 220), spacing: 16)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard

                HStack(spacing: 12) {
                    progressPill(titleKey: "progress.streak", value: "\(progressStore.streakDays)")
                    progressPill(titleKey: "progress.saved", value: "\(progressStore.savedLessonsCount)")
                    progressPill(titleKey: "progress.highScore", value: "\(progressStore.highScore)")
                }

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppData.dashboardHighlights) { highlight in
                        VStack(alignment: .leading, spacing: 14) {
                            Image(systemName: highlight.symbol)
                                .font(.title2)
                                .foregroundStyle(AppTheme.brandYellow)

                            Text(LocalizedStringKey(highlight.titleKey))
                                .font(.title3.weight(.semibold))

                            Text(LocalizedStringKey(highlight.bodyKey))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCard()
                    }
                }

                todayFocusCard
                achievementsCard
            }
            .padding(20)
        }
        .navigationTitle(Text("dashboard.nav"))
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image("DashboardHero")
                .resizable()
                .scaledToFill()
                .frame(height: 360)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.04),
                            Color.black.opacity(0.18),
                            Color.black.opacity(0.90)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 14) {
                    Text("dashboard.hero.eyebrow")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .foregroundStyle(AppTheme.brandYellow)

                Text("dashboard.hero.title")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.heroText)
                    .lineLimit(3)
                    .minimumScaleFactor(0.92)
                    .lineSpacing(2)
                    .shadow(color: Color.black.opacity(0.45), radius: 10, x: 0, y: 3)

                Text("dashboard.hero.subtitle")
                    .foregroundStyle(AppTheme.heroTextSecondary)
                    .font(.subheadline.leading(.loose))
                    .lineLimit(4)
                    .minimumScaleFactor(0.92)
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 2)

                    HStack(spacing: 12) {
                        statPill(titleKey: "dashboard.stat.players", value: "3")
                        statPill(titleKey: "dashboard.stat.touchLimit", value: "3")
                        statPill(titleKey: "dashboard.stat.focus", value: "360°")
                    }
                }
                .frame(maxWidth: 320, alignment: .leading)
                .padding(24)
            }
            .frame(height: 360)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var todayFocusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("dashboard.focus.title")
                .font(.title3.weight(.semibold))
            Text("dashboard.focus.body")
                .foregroundStyle(AppTheme.textSecondary)
            Divider().overlay(Color.white.opacity(0.08))
            Label("dashboard.focus.drill", systemImage: "figure.mind.and.body")
                .font(.body.weight(.medium))
            Text("dashboard.focus.drill.body")
                .foregroundStyle(AppTheme.textSecondary)
        }
        .appCard()
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("dashboard.achievements.title")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("\(progressStore.achievementsCount)/\(AppData.achievements.count)")
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(AppData.achievements) { achievement in
                HStack(spacing: 14) {
                    Image(systemName: achievement.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(progressStore.unlockedAchievements.contains(achievement.id) ? AppTheme.brandYellow : Color.black.opacity(0.48))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(progressStore.unlockedAchievements.contains(achievement.id) ? AppTheme.brandYellow.opacity(0.18) : Color.black.opacity(0.06))
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey(achievement.titleKey))
                            .font(.headline)
                        Text(LocalizedStringKey(achievement.bodyKey))
                            .foregroundStyle(AppTheme.textSecondary)
                            .font(.subheadline)
                    }
                    Spacer()
                }
            }
        }
        .appCard()
    }

    private func statPill(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.black)
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(.black.opacity(0.75))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.brandYellow, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func progressPill(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.title3.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

struct LearnView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var progressStore: ProgressStore

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 320 : 260), spacing: 16)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "learn.eyebrow",
                    titleKey: "learn.title",
                    bodyKey: "learn.subtitle"
                )

                Image("LearnCourt")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                bookmarkedSummary
                contentRibbon

                Text("learn.featured.header")
                    .font(.title2.weight(.bold))

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppData.learnTopics) { topic in
                        NavigationLink {
                            LearnTopicDetailView(topic: topic, progressStore: progressStore)
                        } label: {
                            topicCard(topic)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(Text("learn.nav"))
    }

    private var bookmarkedSummary: some View {
        HStack {
            Label("learn.saved.header", systemImage: "bookmark.fill")
                .font(.headline)
            Spacer()
            Text("\(progressStore.savedLessonsCount)")
                .foregroundStyle(AppTheme.brandYellow)
                .font(.headline)
        }
        .appCard()
    }

    private var contentRibbon: some View {
        HStack(spacing: 12) {
            editorialPill(value: "\(AppData.learnTopics.count)", labelKey: "learn.ribbon.guides")
            editorialPill(value: "3", labelKey: "learn.ribbon.roles")
            editorialPill(value: "10+", labelKey: "learn.ribbon.cues")
        }
    }

    private func topicCard(_ topic: LearnTopic) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(topic.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack(alignment: .top) {
                Label(LocalizedStringKey(topic.titleKey), systemImage: topic.symbol)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text(LocalizedStringKey(topic.readingTimeKey))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.brandYellow)
                    Image(systemName: progressStore.isLessonSaved(topic.id) ? "bookmark.fill" : "chevron.right.circle.fill")
                        .foregroundStyle(progressStore.isLessonSaved(topic.id) ? AppTheme.brandYellow : AppTheme.textSecondary)
                }
            }

            Text(LocalizedStringKey(topic.summaryKey))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func editorialPill(value: String, labelKey: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(LocalizedStringKey(labelKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

struct LearnTopicDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let topic: LearnTopic
    @ObservedObject var progressStore: ProgressStore

    private var relatedTopics: [LearnTopic] {
        topic.relatedIDs.compactMap(AppData.learnTopic(withID:))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DetailHeroImage(
                        name: topic.imageName,
                        title: String(localized: String.LocalizationValue(topic.titleKey)),
                        summary: String(localized: String.LocalizationValue(topic.summaryKey))
                    )

                    HStack {
                        Label("learn.detail.article", systemImage: topic.symbol)
                            .font(.headline)
                        Spacer()
                        Text(LocalizedStringKey(topic.readingTimeKey))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.brandYellow)
                        Button {
                            progressStore.toggleSavedLesson(topic.id)
                        } label: {
                            Label(progressStore.isLessonSaved(topic.id) ? "learn.detail.saved" : "learn.detail.save", systemImage: progressStore.isLessonSaved(topic.id) ? "bookmark.fill" : "bookmark")
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.brandYellow)
                    }
                    .appCard()

                    if horizontalSizeClass == .regular {
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                InlineGallerySection(titleKey: "article.gallery.title", assets: topic.gallery)
                                ArticleParagraphSection(paragraphKeys: topic.paragraphKeys)
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                            VStack(alignment: .leading, spacing: 18) {
                                ArticleHighlightSection(titleKey: "learn.detail.keypoints", itemKeys: topic.highlightKeys, systemImage: "checkmark.seal.fill")
                                TimelineSection(titleKey: "learn.detail.timeline", entries: topic.timeline)
                                RelatedLearnSection(topics: relatedTopics, progressStore: progressStore)
                            }
                            .frame(width: min(max(proxy.size.width * 0.32, 320), 380), alignment: .topLeading)
                        }
                    } else {
                        ArticleHighlightSection(titleKey: "learn.detail.keypoints", itemKeys: topic.highlightKeys, systemImage: "checkmark.seal.fill")
                        InlineGallerySection(titleKey: "article.gallery.title", assets: topic.gallery)
                        TimelineSection(titleKey: "learn.detail.timeline", entries: topic.timeline)
                        ArticleParagraphSection(paragraphKeys: topic.paragraphKeys)
                        RelatedLearnSection(topics: relatedTopics, progressStore: progressStore)
                    }
                }
                .frame(width: min(max(proxy.size.width - 32, 0), horizontalSizeClass == .regular ? 1120 : max(proxy.size.width - 32, 0)), alignment: .topLeading)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(Text(LocalizedStringKey(topic.titleKey)))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TrainerView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var store: TrainerStore
    @ObservedObject var settings: AppSettings
    @ObservedObject var progressStore: ProgressStore

    private var currentReplayNote: String {
        String(
            localized: String.LocalizationValue(
                store.currentScenario.replayNoteKeys[min(store.replayStep, store.currentScenario.replayNoteKeys.count - 1)]
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "trainer.eyebrow",
                    titleKey: "trainer.title",
                    bodyKey: "trainer.subtitle"
                )

                Picker("trainer.mode", selection: $store.selectedTab) {
                    Text("trainer.tab.scenarios")
                        .tag(MatchLabTab.scenarios)
                    Text("trainer.tab.minigame")
                        .tag(MatchLabTab.miniGame)
                }
                .pickerStyle(.segmented)

                if store.selectedTab == .scenarios {
                    scenariosView
                } else {
                    miniGameView
                }
            }
            .padding(20)
        }
        .navigationTitle(Text("trainer.nav"))
        .sheet(isPresented: $store.isShowingMiniGameResults) {
            MiniGameResultsView(
                score: store.miniGameScore,
                correctAnswers: store.miniGameCorrectAnswers,
                roundsPlayed: store.miniGameRoundsPlayed,
                bestStreak: store.miniGameBestStreak,
                globalHighScore: progressStore.highScore,
                achievementsCount: progressStore.achievementsCount,
                onReplay: {
                    store.resetMiniGame()
                },
                onClose: {
                    store.closeMiniGameResults()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var scenariosView: some View {
        Group {
            Picker("trainer.difficulty", selection: $store.difficulty) {
                ForEach(TrainerDifficulty.allCases) { difficulty in
                    Text(LocalizedStringKey(difficulty.titleKey))
                        .tag(difficulty)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                scoreCard(titleKey: "trainer.score", value: "\(store.sessionScore)")
                scoreCard(titleKey: "trainer.combo", value: "\(store.combo)")
                scoreCard(titleKey: "trainer.progress", value: store.progressText)
            }

            if horizontalSizeClass == .regular {
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 20) {
                        situationSummaryCard
                        courtCard
                        replayPanel
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    scenarioCard
                        .frame(width: 380, alignment: .topLeading)
                }
            } else {
                situationSummaryCard
                courtCard
                replayPanel
                scenarioCard
            }
        }
    }

    private var miniGameView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                miniGameMetric(titleKey: "trainer.minigame.metric.score", value: "\(store.miniGameScore)")
                miniGameMetric(titleKey: "trainer.minigame.metric.streak", value: "\(store.miniGameStreak)")
                miniGameMetric(titleKey: "trainer.minigame.metric.best", value: "\(store.miniGameBestStreak)")
                miniGameMetric(titleKey: "trainer.minigame.metric.round", value: store.miniGameRoundText)
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey(store.currentMiniGameType.titleKey))
                            .font(.title3.weight(.semibold))
                        Text(LocalizedStringKey(store.currentMiniGameType.subtitleKey))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    Text(LocalizedStringKey(store.currentMiniGameDrill.role.titleKey))
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.brandMint.opacity(0.18), in: Capsule())
                        .foregroundStyle(AppTheme.brandMint)
                }

                HStack(spacing: 12) {
                    zoneTag(titleKey: "trainer.tag.liveBall", value: String(localized: String.LocalizationValue(store.currentMiniGameDrill.ballZone.labelKey)))
                    zoneTag(titleKey: "trainer.tag.mode", value: String(localized: String.LocalizationValue(store.currentMiniGameType.titleKey)))
                    zoneTag(titleKey: "trainer.tag.bestStreak", value: "\(store.miniGameBestStreak)")
                }

                Text(LocalizedStringKey(store.currentMiniGameDrill.promptKey))
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.body.leading(.loose))
            }
            .appCard()

            MiniGameCourtView(
                drill: store.currentMiniGameDrill,
                selectedZone: store.miniGameLastZoneChoice,
                animationToken: store.miniGameFlightToken,
                isInteractive: store.currentMiniGameType == .zoneTap && !store.miniGameRoundResolved,
                onSelect: { zone in
                    store.playMiniGame(on: zone, progressStore: progressStore)
                }
            )
            .frame(height: horizontalSizeClass == .regular ? 380 : 320)
            .appCard()

            if store.currentMiniGameType == .roleRead {
                HStack(spacing: 12) {
                    roleChoiceButton(.tekong)
                    roleChoiceButton(.feeder)
                    roleChoiceButton(.killer)
                }
            }

            if store.currentMiniGameType == .patternPick {
                HStack(spacing: 12) {
                    patternChoiceButton(.reset)
                    patternChoiceButton(.build)
                    patternChoiceButton(.strike)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("trainer.feedback")
                    .font(.headline)
                Text(LocalizedStringKey(store.miniGameFeedbackKey))
                    .foregroundStyle(AppTheme.textSecondary)

                HStack {
                    Button("trainer.minigame.resetDrill") {
                        store.resetMiniGame()
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.brandYellow)

                    Spacer()

                    Button(store.isLastMiniGameRound ? String(localized: "trainer.finish") : String(localized: "trainer.minigame.nextRound")) {
                        store.nextMiniGameRound()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.brandYellow)
                    .foregroundStyle(.black)
                    .disabled(!store.miniGameRoundResolved)
                }
            }
            .appCard()
        }
    }

    private var situationSummaryCard: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                Text(LocalizedStringKey(store.currentScenario.role.titleKey))
            }
            Spacer()
            zoneTag(titleKey: "trainer.tag.liveBall", value: String(localized: String.LocalizationValue(store.currentScenario.ballZone.labelKey)))
            zoneTag(titleKey: "trainer.tag.bestLane", value: String(localized: String.LocalizationValue(store.currentScenario.targetZone.labelKey)))
        }
        .font(.subheadline)
        .appCard()
    }

    private var courtCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("trainer.motionboard", systemImage: "sportscourt.fill")
                    .font(.headline)
                Spacer()
                Text(LocalizedStringKey(stepTitleKey(for: store.replayStep)))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandYellow.opacity(0.16), in: Capsule())
                    .foregroundStyle(AppTheme.brandYellow)
            }

            CourtSituationView(
                role: store.currentScenario.role,
                ballZone: store.currentScenario.ballZone,
                targetZone: store.currentScenario.targetZone,
                replayStep: store.replayStep
            )
            .frame(height: 320)

            Text(currentReplayNote)
                .foregroundStyle(AppTheme.textSecondary)
                .font(.body.leading(.loose))
        }
        .appCard()
    }

    private var replayPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            if horizontalSizeClass == .regular {
                HStack {
                    Text(LocalizedStringKey("trainer.rallystudio"))
                        .font(.headline)
                    Spacer()
                    replayPlayButton
                }
            } else {
                VStack(spacing: 12) {
                    HStack(alignment: .center) {
                        Text(LocalizedStringKey("trainer.rallystudio"))
                            .font(.headline)
                        Spacer(minLength: 12)
                        replayPlayButton
                    }

                    VStack(spacing: 10) {
                        replayNavButton(titleKey: "trainer.prev", systemImage: "chevron.left") {
                            store.previousReplayStep()
                        }

                        replayNavButton(titleKey: "trainer.next", systemImage: "chevron.right") {
                            store.nextReplayStep()
                        }
                    }
                }
            }

            if horizontalSizeClass != .regular {
                VStack(spacing: 12) {
                    ReplayStepCard(index: 0, titleKey: "trainer.step.read", detailKey: store.currentScenario.replayNoteKeys[0], isActive: store.replayStep == 0)
                    ReplayStepCard(index: 1, titleKey: "trainer.step.build", detailKey: store.currentScenario.replayNoteKeys[1], isActive: store.replayStep == 1)
                    ReplayStepCard(index: 2, titleKey: "trainer.step.strike", detailKey: store.currentScenario.replayNoteKeys[2], isActive: store.replayStep == 2)
                }
            } else {
                HStack(spacing: 12) {
                    replayNavButton(titleKey: "trainer.prev", systemImage: "chevron.left") {
                        store.previousReplayStep()
                    }
                    .frame(maxWidth: 170, alignment: .leading)

                    replayNavButton(titleKey: "trainer.next", systemImage: "chevron.right") {
                        store.nextReplayStep()
                    }
                    .frame(maxWidth: 170, alignment: .leading)
                }

                HStack(alignment: .top, spacing: 12) {

                    ReplayStepCard(index: 0, titleKey: "trainer.step.read", detailKey: store.currentScenario.replayNoteKeys[0], isActive: store.replayStep == 0)
                    ReplayStepCard(index: 1, titleKey: "trainer.step.build", detailKey: store.currentScenario.replayNoteKeys[1], isActive: store.replayStep == 1)
                    ReplayStepCard(index: 2, titleKey: "trainer.step.strike", detailKey: store.currentScenario.replayNoteKeys[2], isActive: store.replayStep == 2)
                }
            }
        }
        .appCard()
    }

    private var replayPlayButton: some View {
        Button(store.isReplayPlaying ? String(localized: "trainer.pause") : String(localized: "trainer.playRally")) {
            store.toggleReplay()
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.brandYellow)
        .foregroundStyle(.black)
        .lineLimit(1)
        .minimumScaleFactor(0.82)
    }

    private func replayNavButton(titleKey: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label {
                Text(LocalizedStringKey(titleKey))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            } icon: {
                Image(systemName: systemImage)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .tint(AppTheme.brandYellow)
    }

    private var scenarioCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(LocalizedStringKey(store.currentScenario.titleKey))
                    .font(.title3.weight(.semibold))
                Spacer()
                Text(LocalizedStringKey(store.difficulty.titleKey))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandYellow.opacity(0.16), in: Capsule())
                    .foregroundStyle(AppTheme.brandYellow)
            }

            Text(LocalizedStringKey(store.currentScenario.promptKey))
                .foregroundStyle(AppTheme.textSecondary)

            VStack(spacing: 12) {
                ForEach(Array(store.currentScenario.optionKeys.enumerated()), id: \.offset) { index, optionKey in
                    Button {
                        store.choose(index)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(buttonBackground(for: index))
                                    .frame(width: 34, height: 34)
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(iconColor(for: index))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(LocalizedStringKey(optionKey))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(AppTheme.textPrimary)
                                if store.selectedIndex == index {
                                    Text(LocalizedStringKey(store.selectedIndex == store.currentScenario.correctIndex ? "trainer.option.correct" : "trainer.option.incorrect"))
                                        .font(.caption)
                                        .foregroundStyle(iconColor(for: index))
                                }
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(buttonBorder(for: index), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if settings.coachHintsEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("trainer.feedback")
                        .font(.headline)
                    Text(feedbackText)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surfaceStrong, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            HStack {
                Button("trainer.reset") {
                    store.resetSession()
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.brandYellow)

                Spacer()

                Button(store.scenarioIndex == store.scenariosForDifficulty.count - 1 ? String(localized: "trainer.finish") : String(localized: "trainer.next")) {
                    store.advance(settings: settings, progressStore: progressStore)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.brandYellow)
                .foregroundStyle(.black)
                .disabled(!store.isAnswered)
            }
        }
        .appCard()
    }

    private var feedbackText: LocalizedStringKey {
        if let selectedIndex = store.selectedIndex {
            return selectedIndex == store.currentScenario.correctIndex
                ? LocalizedStringKey(store.currentScenario.feedbackKey)
                : "trainer.tryAgainHint"
        }
        return "trainer.feedback.placeholder"
    }

    private func scoreCard(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(titleKey))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func iconColor(for index: Int) -> Color {
        guard let selectedIndex = store.selectedIndex else { return AppTheme.textPrimary }
        if index == store.currentScenario.correctIndex { return AppTheme.brandYellow }
        if selectedIndex == index { return Color.red.opacity(0.82) }
        return AppTheme.textSecondary
    }

    private func buttonBackground(for index: Int) -> Color {
        guard let selectedIndex = store.selectedIndex else { return Color.black.opacity(0.05) }
        if index == store.currentScenario.correctIndex { return AppTheme.brandYellow.opacity(0.18) }
        if selectedIndex == index { return Color.red.opacity(0.14) }
        return Color.black.opacity(0.04)
    }

    private func buttonBorder(for index: Int) -> Color {
        guard let selectedIndex = store.selectedIndex else { return Color.black.opacity(0.09) }
        if index == store.currentScenario.correctIndex { return AppTheme.brandYellow.opacity(0.9) }
        if selectedIndex == index { return Color.red.opacity(0.58) }
        return Color.black.opacity(0.08)
    }

    private func stepTitleKey(for step: Int) -> String {
        switch step {
        case 0: "trainer.step.read"
        case 1: "trainer.step.build"
        default: "trainer.step.strike"
        }
    }

    private func zoneTag(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func miniGameMetric(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.title3.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func roleChoiceButton(_ role: TakrawRole) -> some View {
        Button {
            store.playMiniGame(with: role, progressStore: progressStore)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey(role.titleKey))
                    .font(.headline)
                Text(rolePrompt(for: role))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(roleButtonFill(for: role), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(roleButtonBorder(for: role), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(store.miniGameRoundResolved)
    }

    private func patternChoiceButton(_ pattern: MiniGamePattern) -> some View {
        Button {
            store.playMiniGame(with: pattern, progressStore: progressStore)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey(pattern.titleKey))
                    .font(.headline)
                Text(patternPrompt(for: pattern))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(patternButtonFill(for: pattern), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(patternButtonBorder(for: pattern), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(store.miniGameRoundResolved)
    }

    private func rolePrompt(for role: TakrawRole) -> String {
        switch role {
        case .tekong: String(localized: "trainer.minigame.roleprompt.tekong")
        case .feeder: String(localized: "trainer.minigame.roleprompt.feeder")
        case .killer: String(localized: "trainer.minigame.roleprompt.killer")
        }
    }

    private func patternPrompt(for pattern: MiniGamePattern) -> String {
        switch pattern {
        case .reset: String(localized: "trainer.minigame.patternprompt.reset")
        case .build: String(localized: "trainer.minigame.patternprompt.build")
        case .strike: String(localized: "trainer.minigame.patternprompt.strike")
        }
    }

    private func roleButtonFill(for role: TakrawRole) -> Color {
        if let selected = store.miniGameLastRoleChoice {
            if role == store.currentMiniGameDrill.correctRole {
                return AppTheme.brandMint.opacity(0.18)
            }
            if selected == role {
                return AppTheme.brandCoral.opacity(0.16)
            }
        }
        return Color.white.opacity(0.04)
    }

    private func roleButtonBorder(for role: TakrawRole) -> Color {
        if let selected = store.miniGameLastRoleChoice {
            if role == store.currentMiniGameDrill.correctRole {
                return AppTheme.brandMint
            }
            if selected == role {
                return AppTheme.brandCoral
            }
        }
        return Color.white.opacity(0.08)
    }

    private func patternButtonFill(for pattern: MiniGamePattern) -> Color {
        if let selected = store.miniGameLastPatternChoice {
            if pattern == store.currentMiniGameDrill.correctPattern {
                return AppTheme.brandMint.opacity(0.18)
            }
            if selected == pattern {
                return AppTheme.brandCoral.opacity(0.16)
            }
        }
        return Color.white.opacity(0.04)
    }

    private func patternButtonBorder(for pattern: MiniGamePattern) -> Color {
        if let selected = store.miniGameLastPatternChoice {
            if pattern == store.currentMiniGameDrill.correctPattern {
                return AppTheme.brandMint
            }
            if selected == pattern {
                return AppTheme.brandCoral
            }
        }
        return Color.white.opacity(0.08)
    }
}

struct MiniGameCourtView: View {
    let drill: MiniGameDrill
    let selectedZone: CourtZone?
    let animationToken: Int
    let isInteractive: Bool
    let onSelect: (CourtZone) -> Void
    @State private var flightProgress: CGFloat = 0
    @State private var showFlightBall = false

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let leftFront = CGPoint(x: width * 0.25, y: height * 0.75)
            let rightFront = CGPoint(x: width * 0.75, y: height * 0.75)
            let service = CGPoint(x: width * 0.5, y: height * 0.22)
            let center = CGPoint(x: width * 0.5, y: height * 0.68)
            let net = CGPoint(x: width * 0.5, y: height * 0.45)
            let startPoint = point(for: drill.ballZone, service: service, leftFront: leftFront, rightFront: rightFront, center: center, net: net)
            let endPoint = point(for: drill.targetZone, service: service, leftFront: leftFront, rightFront: rightFront, center: center, net: net)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.courtSurfaceTop, AppTheme.courtSurfaceBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppTheme.courtBoundary, lineWidth: 1)

                Path { path in
                    path.addRoundedRect(
                        in: CGRect(x: width * 0.08, y: height * 0.08, width: width * 0.84, height: height * 0.82),
                        cornerSize: CGSize(width: 24, height: 24)
                    )
                }
                .stroke(AppTheme.courtBoundary, lineWidth: 2)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.08, y: net.y))
                    path.addLine(to: CGPoint(x: width * 0.92, y: net.y))
                }
                .stroke(AppTheme.courtLine, style: StrokeStyle(lineWidth: 3, dash: [8, 8]))

                tappableZone(titleKey: "court.zone.short.service", zone: .service, point: service, highlight: drill.ballZone == .service)
                tappableZone(titleKey: "court.zone.short.leftFront", zone: .leftFront, point: leftFront, highlight: drill.ballZone == .leftFront)
                tappableZone(titleKey: "court.zone.short.rightFront", zone: .rightFront, point: rightFront, highlight: drill.ballZone == .rightFront)
                tappableZone(titleKey: "court.zone.short.net", zone: .net, point: net, highlight: drill.ballZone == .net)
                tappableZone(titleKey: "court.zone.short.center", zone: .center, point: center, highlight: drill.ballZone == .center)

                playerMarker(titleKey: drill.role.titleKey, point: point(for: drill.role, service: service, leftFront: leftFront, rightFront: rightFront))

                if showFlightBall {
                    Circle()
                        .fill(AppTheme.brandSand)
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 2))
                        .shadow(color: AppTheme.brandSand.opacity(0.55), radius: 16)
                        .position(ballPosition(from: startPoint, to: endPoint, progress: flightProgress))
                }
            }
            .onChange(of: animationToken) { newValue in
                guard drill.type == .zoneTap, newValue > 0 else { return }
                showFlightBall = true
                flightProgress = 0
                withAnimation(.easeInOut(duration: 0.8)) {
                    flightProgress = 1
                }
                Task {
                    try? await Task.sleep(nanoseconds: 900_000_000)
                    showFlightBall = false
                }
            }
        }
    }

    private func tappableZone(titleKey: String, zone: CourtZone, point: CGPoint, highlight: Bool) -> some View {
        Button {
            if isInteractive {
                onSelect(zone)
            }
        } label: {
            VStack(spacing: 8) {
                Circle()
                    .fill(fillColor(for: zone, highlight: highlight))
                    .frame(width: zone == .net ? 56 : 72, height: zone == .net ? 56 : 72)
                    .overlay(
                        Circle()
                            .stroke(borderColor(for: zone), lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: iconName(for: zone))
                            .foregroundStyle(AppTheme.courtText)
                    )

                Text(LocalizedStringKey(titleKey))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.heroText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.courtBadgeBackground, in: Capsule())
            }
        }
        .buttonStyle(.plain)
        .disabled(!isInteractive)
        .position(point)
    }

    private func playerMarker(titleKey: String, point: CGPoint) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(AppTheme.brandSand)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
            Text(LocalizedStringKey(titleKey))
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.heroText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.courtBadgeBackground, in: Capsule())
        }
        .position(x: point.x, y: point.y - 58)
    }

    private func point(for role: TakrawRole, service: CGPoint, leftFront: CGPoint, rightFront: CGPoint) -> CGPoint {
        switch role {
        case .tekong: service
        case .feeder: leftFront
        case .killer: rightFront
        }
    }

    private func point(for zone: CourtZone, service: CGPoint, leftFront: CGPoint, rightFront: CGPoint, center: CGPoint, net: CGPoint) -> CGPoint {
        switch zone {
        case .service: service
        case .leftFront: leftFront
        case .rightFront: rightFront
        case .net: net
        case .center: center
        }
    }

    private func fillColor(for zone: CourtZone, highlight: Bool) -> Color {
        if let selectedZone {
            if zone == drill.targetZone {
                return AppTheme.brandMint.opacity(0.9)
            }
            if selectedZone == zone {
                return AppTheme.brandCoral.opacity(0.82)
            }
        }
        if highlight {
            return AppTheme.brandSand.opacity(0.72)
        }
        return Color.white.opacity(0.12)
    }

    private func borderColor(for zone: CourtZone) -> Color {
        if let selectedZone {
            if zone == drill.targetZone {
                return AppTheme.brandMint
            }
            if selectedZone == zone {
                return AppTheme.brandCoral
            }
        }
        return Color.white.opacity(0.18)
    }

    private func iconName(for zone: CourtZone) -> String {
        switch zone {
        case .service: "arrow.up.circle.fill"
        case .leftFront: "arrow.up.left.circle.fill"
        case .rightFront: "arrow.up.right.circle.fill"
        case .net: "line.3.crossed.swirl.circle.fill"
        case .center: "circle.grid.2x2.fill"
        }
    }

    private func ballPosition(from start: CGPoint, to end: CGPoint, progress: CGFloat) -> CGPoint {
        let x = start.x + (end.x - start.x) * progress
        let baseY = start.y + (end.y - start.y) * progress
        let arcLift = sin(progress * .pi) * 42
        return CGPoint(x: x, y: baseY - arcLift)
    }
}

struct MiniGameResultsView: View {
    let score: Int
    let correctAnswers: Int
    let roundsPlayed: Int
    let bestStreak: Int
    let globalHighScore: Int
    let achievementsCount: Int
    let onReplay: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("trainer.minigame.results.title")
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                Text("trainer.minigame.results.subtitle")
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 12) {
                    resultCard(titleKey: "trainer.minigame.results.sessionScore", value: "\(score)")
                    resultCard(titleKey: "trainer.minigame.results.correct", value: "\(correctAnswers)/\(max(roundsPlayed, 1))")
                }

                HStack(spacing: 12) {
                    resultCard(titleKey: "trainer.minigame.results.bestStreak", value: "\(bestStreak)")
                    resultCard(titleKey: "trainer.minigame.results.globalHigh", value: "\(globalHighScore)")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("trainer.minigame.results.progressImpact")
                        .font(.headline)
                    Text(String(localized: "trainer.minigame.results.progressBody") + " \(achievementsCount).")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .appCard()

                HStack {
                    Button("common.close") {
                        onClose()
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.brandYellow)

                    Spacer()

                    Button("trainer.minigame.results.playAgain") {
                        onReplay()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.brandYellow)
                    .foregroundStyle(.black)
                }
            }
            .padding(24)
        }
    }

    private func resultCard(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.title.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

struct CourtSituationView: View {
    let role: TakrawRole
    let ballZone: CourtZone
    let targetZone: CourtZone
    let replayStep: Int

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let leftFront = CGPoint(x: width * 0.26, y: height * 0.74)
            let rightFront = CGPoint(x: width * 0.74, y: height * 0.74)
            let service = CGPoint(x: width * 0.5, y: height * 0.22)
            let netY = height * 0.48
            let start = point(for: ballZone, service: service, leftFront: leftFront, rightFront: rightFront, width: width, netY: netY)
            let rolePoint = point(for: role, service: service, leftFront: leftFront, rightFront: rightFront)
            let end = point(for: targetZone, service: service, leftFront: leftFront, rightFront: rightFront, width: width, netY: netY)
            let activeBallPoint = replayPoint(step: replayStep, start: start, rolePoint: rolePoint, end: end)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.courtSurfaceTop, AppTheme.courtSurfaceBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppTheme.courtBoundary, lineWidth: 1)

                Path { path in
                    path.addRoundedRect(in: CGRect(x: width * 0.08, y: height * 0.1, width: width * 0.84, height: height * 0.8), cornerSize: CGSize(width: 22, height: 22))
                }
                .stroke(AppTheme.courtBoundary, lineWidth: 2)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.08, y: netY))
                    path.addLine(to: CGPoint(x: width * 0.92, y: netY))
                }
                .stroke(AppTheme.courtLine, style: StrokeStyle(lineWidth: 3, dash: [6, 6]))

                courtCircle(center: service)
                courtCircle(center: leftFront)
                courtCircle(center: rightFront)

                playerNode(titleKey: "learn.role.tekong.title", role: .tekong, point: service)
                playerNode(titleKey: "learn.role.feeder.title", role: .feeder, point: leftFront)
                playerNode(titleKey: "learn.role.killer.title", role: .killer, point: rightFront)

                stepPath(from: start, to: rolePoint, isActive: replayStep >= 1)
                stepPath(from: rolePoint, to: end, isActive: replayStep >= 2)

                marker(titleKey: "trainer.tag.liveBall", point: start, tint: .white.opacity(0.75))
                marker(titleKey: "trainer.tag.bestLane", point: end, tint: AppTheme.brandCoral.opacity(0.8))

                Circle()
                    .fill(AppTheme.brandYellow)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 2))
                    .shadow(color: AppTheme.brandYellow.opacity(0.55), radius: 18)
                    .position(activeBallPoint)
                    .animation(.easeInOut(duration: 0.5), value: replayStep)
            }
        }
    }

    private func courtCircle(center: CGPoint) -> some View {
        Circle()
            .stroke(AppTheme.courtLine, lineWidth: 2)
            .frame(width: 74, height: 74)
            .position(center)
    }

    private func playerNode(titleKey: String, role: TakrawRole, point: CGPoint) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(self.role == role ? AppTheme.brandYellow : Color.white.opacity(0.15))
                .frame(width: 26, height: 26)
                .overlay(Circle().stroke(Color.white.opacity(0.24), lineWidth: 1))
            Text(LocalizedStringKey(titleKey))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.courtText)
        }
        .position(point)
    }

    private func marker(titleKey: String, point: CGPoint, tint: Color) -> some View {
        Text(LocalizedStringKey(titleKey))
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(AppTheme.courtBadgeBackground, in: Capsule())
            .foregroundStyle(tint)
            .position(x: point.x, y: point.y - 34)
    }

    private func stepPath(from start: CGPoint, to end: CGPoint, isActive: Bool) -> some View {
        Path { path in
            path.move(to: start)
            path.addQuadCurve(to: end, control: CGPoint(x: (start.x + end.x) * 0.5, y: min(start.y, end.y) - 44))
        }
        .stroke(
            isActive ? AppTheme.brandYellow : Color.white.opacity(0.15),
            style: StrokeStyle(lineWidth: isActive ? 4 : 2, lineCap: .round, dash: [10, 8])
        )
    }

    private func replayPoint(step: Int, start: CGPoint, rolePoint: CGPoint, end: CGPoint) -> CGPoint {
        switch step {
        case 0: start
        case 1: rolePoint
        default: end
        }
    }

    private func point(for role: TakrawRole, service: CGPoint, leftFront: CGPoint, rightFront: CGPoint) -> CGPoint {
        switch role {
        case .tekong: service
        case .feeder: leftFront
        case .killer: rightFront
        }
    }

    private func point(for zone: CourtZone, service: CGPoint, leftFront: CGPoint, rightFront: CGPoint, width: CGFloat, netY: CGFloat) -> CGPoint {
        switch zone {
        case .service: service
        case .leftFront: leftFront
        case .rightFront: rightFront
        case .net: CGPoint(x: width * 0.5, y: netY - 10)
        case .center: CGPoint(x: width * 0.5, y: netY + 72)
        }
    }
}

struct ReplayStepCard: View {
    let index: Int
    let titleKey: String
    let detailKey: String
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(index + 1)")
                    .font(.caption.weight(.bold))
                    .padding(8)
                    .background((isActive ? AppTheme.brandYellow : Color.white.opacity(0.08)), in: Circle())
                    .foregroundStyle(isActive ? .black : .white)
                Text(LocalizedStringKey(titleKey))
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(LocalizedStringKey(detailKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isActive ? AppTheme.brandYellow.opacity(0.12) : Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isActive ? AppTheme.brandYellow.opacity(0.8) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct HistoryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 320 : 260), spacing: 16)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "history.eyebrow",
                    titleKey: "history.title",
                    bodyKey: "history.subtitle"
                )

                Image("HistoryOrigins")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                HStack(spacing: 12) {
                    historyPill(value: "\(AppData.historyStories.count)", labelKey: "history.pill.storyArcs")
                    historyPill(value: "5", labelKey: "history.pill.eras")
                    historyPill(value: "3", labelKey: "history.pill.visualNotes")
                }

                Text("history.explore.header")
                    .font(.title2.weight(.bold))

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppData.historyStories) { story in
                        NavigationLink {
                            HistoryStoryDetailView(story: story)
                        } label: {
                            historyCard(story)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(Text("history.nav"))
    }

    private func historyCard(_ story: HistoryStory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(story.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack {
                Text(LocalizedStringKey(story.accentKey))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandYellow.opacity(0.16), in: Capsule())
                    .foregroundStyle(AppTheme.brandYellow)
                Spacer()
                Text(LocalizedStringKey(story.readingTimeKey))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Text(LocalizedStringKey(story.titleKey))
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(LocalizedStringKey(story.summaryKey))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func historyPill(value: String, labelKey: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(LocalizedStringKey(labelKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

struct HistoryStoryDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let story: HistoryStory

    private var relatedStories: [HistoryStory] {
        story.relatedIDs.compactMap(AppData.historyStory(withID:))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DetailHeroImage(
                        name: story.imageName,
                        title: String(localized: String.LocalizationValue(story.titleKey)),
                        summary: String(localized: String.LocalizationValue(story.summaryKey))
                    )

                    HStack {
                        Label("history.detail.feature", systemImage: "globe.asia.australia.fill")
                            .font(.headline)
                        Spacer()
                        Text(LocalizedStringKey(story.readingTimeKey))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.brandYellow)
                    }
                    .appCard()

                    if horizontalSizeClass == .regular {
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                InlineGallerySection(titleKey: "article.gallery.title", assets: story.gallery)
                                ArticleParagraphSection(paragraphKeys: story.paragraphKeys)
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                            VStack(alignment: .leading, spacing: 18) {
                                ArticleHighlightSection(titleKey: "history.detail.keypoints", itemKeys: story.highlightKeys, systemImage: "circle.grid.cross.fill")
                                TimelineSection(titleKey: "history.timeline.header", entries: story.timeline)
                                RelatedHistorySection(stories: relatedStories)
                            }
                            .frame(width: min(max(proxy.size.width * 0.32, 320), 380), alignment: .topLeading)
                        }
                    } else {
                        ArticleHighlightSection(titleKey: "history.detail.keypoints", itemKeys: story.highlightKeys, systemImage: "circle.grid.cross.fill")
                        InlineGallerySection(titleKey: "article.gallery.title", assets: story.gallery)
                        TimelineSection(titleKey: "history.timeline.header", entries: story.timeline)
                        ArticleParagraphSection(paragraphKeys: story.paragraphKeys)
                        RelatedHistorySection(stories: relatedStories)
                    }
                }
                .frame(width: min(max(proxy.size.width - 32, 0), horizontalSizeClass == .regular ? 1120 : max(proxy.size.width - 32, 0)), alignment: .topLeading)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(Text(LocalizedStringKey(story.titleKey)))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "settings.eyebrow",
                    titleKey: "settings.title",
                    bodyKey: "settings.subtitle"
                )

                VStack(alignment: .leading, spacing: 16) {
                    Text("settings.language.header")
                        .font(.headline)

                    Picker("settings.language.label", selection: $settings.selectedLanguageCode) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(LocalizedStringKey(language.titleKey))
                                .tag(language.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 14) {
                    Toggle("settings.coachHints", isOn: $settings.coachHintsEnabled)
                    Toggle("settings.autoSave", isOn: $settings.autoSaveCorrectLessons)
                }
                .toggleStyle(.switch)
                .appCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("settings.progress.header")
                        .font(.headline)
                    HStack {
                        Label("\(progressStore.streakDays)", systemImage: "flame.fill")
                        Spacer()
                        Label("\(progressStore.savedLessonsCount)", systemImage: "bookmark.fill")
                        Spacer()
                        Label("\(progressStore.achievementsCount)", systemImage: "crown.fill")
                    }
                    .foregroundStyle(AppTheme.brandYellow)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("settings.actions.header")
                        .font(.headline)

                    Button("settings.resetOnboarding") {
                        settings.resetOnboarding()
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.brandYellow)

                    Button("settings.resetProgress") {
                        progressStore.resetAll()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("settings.appInfo.header")
                        .font(.headline)
                    Text(appInfoLine)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("settings.appInfo.body")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .appCard()
            }
            .padding(20)
        }
        .navigationTitle(Text("settings.nav"))
    }

    private var appInfoLine: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return String(localized: "settings.versionPrefix") + " \(version)"
    }
}

struct ArticleHighlightSection: View {
    let titleKey: String
    let itemKeys: [String]
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(titleKey))
                .font(.headline)

            ForEach(itemKeys, id: \.self) { itemKey in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: systemImage)
                        .foregroundStyle(AppTheme.brandYellow)
                        .padding(.top, 2)
                    Text(LocalizedStringKey(itemKey))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard()
            }
        }
    }
}

struct InlineGallerySection: View {
    let titleKey: String
    let assets: [GalleryAsset]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(titleKey))
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(assets) { asset in
                        VStack(alignment: .leading, spacing: 10) {
                            Image(asset.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 280, height: 180)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                            Text(LocalizedStringKey(asset.captionKey))
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .frame(width: 280, alignment: .leading)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .appCard()
    }
}

struct TimelineSection: View {
    let titleKey: String
    let entries: [ArticleTimelineEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(LocalizedStringKey(titleKey))
                .font(.headline)

            ForEach(entries) { entry in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey(entry.labelKey))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(AppTheme.brandYellow, in: Capsule())
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 2, height: 52)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey(entry.titleKey))
                            .font(.headline)
                        Text(LocalizedStringKey(entry.bodyKey))
                            .foregroundStyle(AppTheme.textSecondary)
                            .font(.subheadline.leading(.loose))
                    }

                    Spacer()
                }
                .appCard()
            }
        }
    }
}

struct ArticleParagraphSection: View {
    let paragraphKeys: [String]

    var body: some View {
        ForEach(paragraphKeys, id: \.self) { paragraphKey in
            Text(LocalizedStringKey(paragraphKey))
                .foregroundStyle(AppTheme.textSecondary)
                .font(.body.leading(.loose))
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard()
        }
    }
}

struct RelatedLearnSection: View {
    let topics: [LearnTopic]
    @ObservedObject var progressStore: ProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("learn.related.header")
                .font(.headline)

            ForEach(topics) { topic in
                NavigationLink {
                    LearnTopicDetailView(topic: topic, progressStore: progressStore)
                } label: {
                    HStack(spacing: 14) {
                        Image(topic.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 72)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(LocalizedStringKey(topic.titleKey))
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(LocalizedStringKey(topic.summaryKey))
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Image(systemName: progressStore.isLessonSaved(topic.id) ? "bookmark.fill" : "chevron.right")
                            .foregroundStyle(progressStore.isLessonSaved(topic.id) ? AppTheme.brandYellow : AppTheme.textSecondary)
                    }
                    .appCard()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RelatedHistorySection: View {
    let stories: [HistoryStory]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("history.related.header")
                .font(.headline)

            ForEach(stories) { story in
                NavigationLink {
                    HistoryStoryDetailView(story: story)
                } label: {
                    HStack(spacing: 14) {
                        Image(story.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 72)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(LocalizedStringKey(story.titleKey))
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(LocalizedStringKey(story.summaryKey))
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .appCard()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DetailHeroImage: View {
    let name: String
    let title: String
    let summary: String

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: 280, alignment: .center)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.84)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.84)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 3)
                    Text(summary)
                        .font(.subheadline.leading(.loose))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .lineLimit(3)
                        .minimumScaleFactor(0.88)
                        .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 2)
                }
                .frame(maxWidth: min(proxy.size.width * 0.76, 520), alignment: .leading)
                .padding(24)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipped()
    }
}

struct SectionIntroView: View {
    let eyebrowKey: String
    let titleKey: String
    let bodyKey: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey(eyebrowKey))
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.brandYellow)

            Text(LocalizedStringKey(titleKey))
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text(LocalizedStringKey(bodyKey))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}
