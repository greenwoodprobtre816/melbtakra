import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard
    case learn
    case trainer
    case history
    case settings

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .dashboard: "tab.dashboard"
        case .learn: "tab.learn"
        case .trainer: "tab.trainer"
        case .history: "tab.history"
        case .settings: "tab.settings"
        }
    }

    var iconName: String {
        switch self {
        case .dashboard: "house.fill"
        case .learn: "play.rectangle.on.rectangle.fill"
        case .trainer: "sportscourt.fill"
        case .history: "globe.asia.australia.fill"
        case .settings: "person.crop.circle.fill"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case en
    case es
    case de
    case ar
    case th

    var id: String { rawValue }

    var localeIdentifier: String { rawValue }

    var titleKey: String {
        switch self {
        case .en: "language.english"
        case .es: "language.spanish"
        case .de: "language.german"
        case .ar: "language.arabic"
        case .th: "language.thai"
        }
    }
}

enum TrainerDifficulty: String, CaseIterable, Identifiable {
    case starter
    case challenger
    case elite

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .starter: "difficulty.starter"
        case .challenger: "difficulty.challenger"
        case .elite: "difficulty.elite"
        }
    }

    var points: Int {
        switch self {
        case .starter: 10
        case .challenger: 16
        case .elite: 24
        }
    }
}

enum TakrawRole: String, Identifiable {
    case tekong
    case feeder
    case killer

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .tekong: "learn.role.tekong.title"
        case .feeder: "learn.role.feeder.title"
        case .killer: "learn.role.killer.title"
        }
    }
}

enum CourtZone: String {
    case service
    case leftFront
    case rightFront
    case net
    case center

    var labelKey: String {
        switch self {
        case .service: "court.zone.service"
        case .leftFront: "court.zone.leftFront"
        case .rightFront: "court.zone.rightFront"
        case .net: "court.zone.net"
        case .center: "court.zone.center"
        }
    }
}

struct DashboardHighlight: Identifiable {
    let id: String
    let titleKey: String
    let bodyKey: String
    let symbol: String
}

struct GalleryAsset: Identifiable, Hashable {
    let imageName: String
    let captionKey: String

    var id: String { imageName + captionKey }
}

struct ArticleTimelineEntry: Identifiable, Hashable {
    let id: String
    let labelKey: String
    let titleKey: String
    let bodyKey: String
}

struct LearnTopic: Identifiable {
    let id: String
    let titleKey: String
    let summaryKey: String
    let imageName: String
    let symbol: String
    let readingTimeKey: String
    let paragraphKeys: [String]
    let highlightKeys: [String]
    let gallery: [GalleryAsset]
    let timeline: [ArticleTimelineEntry]
    let relatedIDs: [String]
}

struct HistoryStory: Identifiable {
    let id: String
    let titleKey: String
    let summaryKey: String
    let imageName: String
    let readingTimeKey: String
    let paragraphKeys: [String]
    let highlightKeys: [String]
    let gallery: [GalleryAsset]
    let timeline: [ArticleTimelineEntry]
    let relatedIDs: [String]
    let accentKey: String
}

struct AchievementDefinition: Identifiable {
    let id: String
    let titleKey: String
    let bodyKey: String
    let symbol: String
}

struct OnboardingPage: Identifiable {
    let id: String
    let titleKey: String
    let bodyKey: String
    let symbol: String
}

struct TacticScenario: Identifiable {
    let id: String
    let titleKey: String
    let promptKey: String
    let optionKeys: [String]
    let correctIndex: Int
    let feedbackKey: String
    let difficulty: TrainerDifficulty
    let relatedLessonID: String
    let role: TakrawRole
    let ballZone: CourtZone
    let targetZone: CourtZone
    let replayNoteKeys: [String]
}

enum AppData {
    private static func optionKeys(_ prefix: String) -> [String] {
        (1...3).map { "\(prefix).option.\($0)" }
    }

    private static func gallery(_ items: (String, String)...) -> [GalleryAsset] {
        items.map { GalleryAsset(imageName: $0.0, captionKey: $0.1) }
    }

    private static func timeline(prefix: String, count: Int) -> [ArticleTimelineEntry] {
        (1...count).map { index in
            ArticleTimelineEntry(
                id: "\(prefix)\(index)",
                labelKey: "\(prefix).\(index).label",
                titleKey: "\(prefix).\(index).title",
                bodyKey: "\(prefix).\(index).body"
            )
        }
    }

    private static func learnTopic(
        id: String,
        keyPrefix: String,
        imageName: String,
        symbol: String,
        paragraphCount: Int = 4,
        highlightCount: Int = 3,
        gallery: [GalleryAsset],
        timeline: [ArticleTimelineEntry],
        relatedIDs: [String]
    ) -> LearnTopic {
        LearnTopic(
            id: id,
            titleKey: "\(keyPrefix).title",
            summaryKey: "\(keyPrefix).summary",
            imageName: imageName,
            symbol: symbol,
            readingTimeKey: "\(keyPrefix).readingTime",
            paragraphKeys: (1...paragraphCount).map { "\(keyPrefix).p\($0)" },
            highlightKeys: (1...highlightCount).map { "\(keyPrefix).b\($0)" },
            gallery: gallery,
            timeline: timeline,
            relatedIDs: relatedIDs
        )
    }

    private static func historyStory(
        id: String,
        keyPrefix: String,
        imageName: String,
        paragraphCount: Int = 4,
        highlightCount: Int = 3,
        gallery: [GalleryAsset],
        timeline: [ArticleTimelineEntry],
        relatedIDs: [String],
        accentKey: String
    ) -> HistoryStory {
        HistoryStory(
            id: id,
            titleKey: "\(keyPrefix).title",
            summaryKey: "\(keyPrefix).summary",
            imageName: imageName,
            readingTimeKey: "\(keyPrefix).readingTime",
            paragraphKeys: (1...paragraphCount).map { "\(keyPrefix).p\($0)" },
            highlightKeys: (1...highlightCount).map { "\(keyPrefix).b\($0)" },
            gallery: gallery,
            timeline: timeline,
            relatedIDs: relatedIDs,
            accentKey: accentKey
        )
    }

    private static func scenario(
        id: String,
        keyPrefix: String,
        correctIndex: Int,
        feedbackKey: String,
        difficulty: TrainerDifficulty,
        relatedLessonID: String,
        role: TakrawRole,
        ballZone: CourtZone,
        targetZone: CourtZone,
        replayNoteKeys: [String]
    ) -> TacticScenario {
        TacticScenario(
            id: id,
            titleKey: "\(keyPrefix).title",
            promptKey: "\(keyPrefix).prompt",
            optionKeys: optionKeys(keyPrefix),
            correctIndex: correctIndex,
            feedbackKey: feedbackKey,
            difficulty: difficulty,
            relatedLessonID: relatedLessonID,
            role: role,
            ballZone: ballZone,
            targetZone: targetZone,
            replayNoteKeys: replayNoteKeys
        )
    }

    static let dashboardHighlights: [DashboardHighlight] = [
        .init(id: "1", titleKey: "dashboard.highlight.analytics.title", bodyKey: "dashboard.highlight.analytics.body", symbol: "chart.line.uptrend.xyaxis"),
        .init(id: "2", titleKey: "dashboard.highlight.roles.title", bodyKey: "dashboard.highlight.roles.body", symbol: "figure.volleyball"),
        .init(id: "3", titleKey: "dashboard.highlight.culture.title", bodyKey: "dashboard.highlight.culture.body", symbol: "globe.asia.australia")
    ]

    static let onboardingPages: [OnboardingPage] = [
        .init(id: "o1", titleKey: "onboarding.page1.title", bodyKey: "onboarding.page1.body", symbol: "sportscourt"),
        .init(id: "o2", titleKey: "onboarding.page2.title", bodyKey: "onboarding.page2.body", symbol: "brain.head.profile"),
        .init(id: "o3", titleKey: "onboarding.page3.title", bodyKey: "onboarding.page3.body", symbol: "globe.badge.chevron.backward")
    ]

    static let learnTopics: [LearnTopic] = [
        learnTopic(
            id: "foundations",
            keyPrefix: "learn.topic.foundations",
            imageName: "LearnCourt",
            symbol: "sportscourt.fill",
            paragraphCount: 3,
            gallery: gallery(
                ("LearnCourt", "learn.topic.foundations.gallery.1"),
                ("ServiceMechanics", "learn.topic.foundations.gallery.2"),
                ("RattanCraft", "learn.topic.foundations.gallery.3")
            ),
            timeline: timeline(prefix: "learn.topic.foundations.timeline", count: 3),
            relatedIDs: ["service_design", "defensive_shapes", "match_iq"]
        ),
        learnTopic(
            id: "roles",
            keyPrefix: "learn.topic.roles",
            imageName: "DashboardHero",
            symbol: "person.3.fill",
            paragraphCount: 3,
            gallery: gallery(
                ("DashboardHero", "learn.topic.roles.gallery.1"),
                ("ServiceMechanics", "learn.topic.roles.gallery.2"),
                ("ChampionshipArena", "learn.topic.roles.gallery.3")
            ),
            timeline: timeline(prefix: "learn.topic.roles.timeline", count: 3),
            relatedIDs: ["match_iq", "defensive_shapes", "foundations"]
        ),
        learnTopic(
            id: "match_iq",
            keyPrefix: "learn.topic.matchiq",
            imageName: "ChampionshipArena",
            symbol: "brain.head.profile",
            paragraphCount: 3,
            gallery: gallery(
                ("ChampionshipArena", "learn.topic.matchiq.gallery.1"),
                ("LearnCourt", "learn.topic.matchiq.gallery.2"),
                ("DashboardHero", "learn.topic.matchiq.gallery.3")
            ),
            timeline: timeline(prefix: "learn.topic.matchiq.timeline", count: 3),
            relatedIDs: ["roles", "defensive_shapes", "service_design"]
        ),
        learnTopic(
            id: "service_design",
            keyPrefix: "learn.topic.service_design",
            imageName: "ServiceMechanics",
            symbol: "target",
            gallery: gallery(
                ("ServiceMechanics", "learn.topic.service_design.gallery.1"),
                ("LearnCourt", "learn.topic.service_design.gallery.2"),
                ("ChampionshipArena", "learn.topic.service_design.gallery.3")
            ),
            timeline: timeline(prefix: "learn.topic.service_design.timeline", count: 3),
            relatedIDs: ["foundations", "roles", "match_iq"]
        ),
        learnTopic(
            id: "defensive_shapes",
            keyPrefix: "learn.topic.defensive_shapes",
            imageName: "ChampionshipArena",
            symbol: "shield.lefthalf.filled",
            gallery: gallery(
                ("ChampionshipArena", "learn.topic.defensive_shapes.gallery.1"),
                ("DashboardHero", "learn.topic.defensive_shapes.gallery.2"),
                ("HistoryOrigins", "learn.topic.defensive_shapes.gallery.3")
            ),
            timeline: timeline(prefix: "learn.topic.defensive_shapes.timeline", count: 3),
            relatedIDs: ["match_iq", "roles", "foundations"]
        )
    ]

    static let historyStories: [HistoryStory] = [
        historyStory(
            id: "origins",
            keyPrefix: "history.story.origins",
            imageName: "HistoryOrigins",
            paragraphCount: 3,
            gallery: gallery(
                ("HistoryOrigins", "history.story.origins.gallery.1"),
                ("VillagePlay", "history.story.origins.gallery.2"),
                ("RattanCraft", "history.story.origins.gallery.3")
            ),
            timeline: timeline(prefix: "history.story.origins.timeline", count: 3),
            relatedIDs: ["equipment_craft", "regional_power", "sea_games"],
            accentKey: "history.story.origins.accent"
        ),
        historyStory(
            id: "regional_power",
            keyPrefix: "history.story.regional",
            imageName: "ChampionshipArena",
            paragraphCount: 3,
            gallery: gallery(
                ("ChampionshipArena", "history.story.regional.gallery.1"),
                ("DashboardHero", "history.story.regional.gallery.2"),
                ("VillagePlay", "history.story.regional.gallery.3")
            ),
            timeline: timeline(prefix: "history.story.regional.timeline", count: 3),
            relatedIDs: ["sea_games", "modern_game", "origins"],
            accentKey: "history.story.regional.accent"
        ),
        historyStory(
            id: "sea_games",
            keyPrefix: "history.story.sea_games",
            imageName: "ChampionshipArena",
            gallery: gallery(
                ("ChampionshipArena", "history.story.sea_games.gallery.1"),
                ("HistoryOrigins", "history.story.sea_games.gallery.2"),
                ("DashboardHero", "history.story.sea_games.gallery.3")
            ),
            timeline: timeline(prefix: "history.story.sea_games.timeline", count: 3),
            relatedIDs: ["regional_power", "modern_game", "equipment_craft"],
            accentKey: "history.story.sea_games.accent"
        ),
        historyStory(
            id: "equipment_craft",
            keyPrefix: "history.story.equipment_craft",
            imageName: "RattanCraft",
            gallery: gallery(
                ("RattanCraft", "history.story.equipment_craft.gallery.1"),
                ("HistoryOrigins", "history.story.equipment_craft.gallery.2"),
                ("LearnCourt", "history.story.equipment_craft.gallery.3")
            ),
            timeline: timeline(prefix: "history.story.equipment_craft.timeline", count: 3),
            relatedIDs: ["origins", "modern_game", "sea_games"],
            accentKey: "history.story.equipment_craft.accent"
        ),
        historyStory(
            id: "modern_game",
            keyPrefix: "history.story.modern_game",
            imageName: "DashboardHero",
            paragraphCount: 4,
            gallery: gallery(
                ("DashboardHero", "history.story.modern_game.gallery.1"),
                ("ChampionshipArena", "history.story.modern_game.gallery.2"),
                ("ServiceMechanics", "history.story.modern_game.gallery.3")
            ),
            timeline: timeline(prefix: "history.story.modern_game.timeline", count: 3),
            relatedIDs: ["sea_games", "regional_power", "equipment_craft"],
            accentKey: "history.story.modern_game.accent"
        )
    ]

    static let achievements: [AchievementDefinition] = [
        .init(id: "first_save", titleKey: "achievement.firstSave.title", bodyKey: "achievement.firstSave.body", symbol: "bookmark.fill"),
        .init(id: "daily_streak", titleKey: "achievement.dailyStreak.title", bodyKey: "achievement.dailyStreak.body", symbol: "flame.fill"),
        .init(id: "ten_correct", titleKey: "achievement.tenCorrect.title", bodyKey: "achievement.tenCorrect.body", symbol: "target"),
        .init(id: "elite_perfect", titleKey: "achievement.elitePerfect.title", bodyKey: "achievement.elitePerfect.body", symbol: "crown.fill"),
        .init(id: "first_minigame", titleKey: "achievement.firstMiniGame.title", bodyKey: "achievement.firstMiniGame.body", symbol: "figure.run.circle"),
        .init(id: "mini_streak", titleKey: "achievement.miniStreak.title", bodyKey: "achievement.miniStreak.body", symbol: "bolt.circle.fill")
    ]

    static let scenarios: [TacticScenario] = [
        scenario(id: "s1", keyPrefix: "trainer.scenario.1", correctIndex: 0, feedbackKey: "trainer.scenario.1.feedback", difficulty: .starter, relatedLessonID: "roles", role: .feeder, ballZone: .leftFront, targetZone: .net, replayNoteKeys: ["trainer.scenario.1.replay.1", "trainer.scenario.1.replay.2", "trainer.scenario.1.replay.3"]),
        scenario(id: "s2", keyPrefix: "trainer.scenario.2", correctIndex: 1, feedbackKey: "trainer.scenario.2.feedback", difficulty: .starter, relatedLessonID: "match_iq", role: .killer, ballZone: .rightFront, targetZone: .rightFront, replayNoteKeys: ["trainer.scenario.2.replay.1", "trainer.scenario.2.replay.2", "trainer.scenario.2.replay.3"]),
        scenario(id: "s3", keyPrefix: "trainer.scenario.3", correctIndex: 1, feedbackKey: "trainer.scenario.3.feedback", difficulty: .starter, relatedLessonID: "foundations", role: .tekong, ballZone: .service, targetZone: .service, replayNoteKeys: ["trainer.scenario.3.replay.1", "trainer.scenario.3.replay.2", "trainer.scenario.3.replay.3"]),
        scenario(id: "s4", keyPrefix: "trainer.scenario.4", correctIndex: 2, feedbackKey: "trainer.scenario.4.feedback", difficulty: .challenger, relatedLessonID: "roles", role: .killer, ballZone: .net, targetZone: .center, replayNoteKeys: ["trainer.scenario.4.replay.1", "trainer.scenario.4.replay.2", "trainer.scenario.4.replay.3"]),
        scenario(id: "s5", keyPrefix: "trainer.scenario.5", correctIndex: 0, feedbackKey: "trainer.scenario.5.feedback", difficulty: .challenger, relatedLessonID: "foundations", role: .feeder, ballZone: .leftFront, targetZone: .center, replayNoteKeys: ["trainer.scenario.5.replay.1", "trainer.scenario.5.replay.2", "trainer.scenario.5.replay.3"]),
        scenario(id: "s6", keyPrefix: "trainer.scenario.6", correctIndex: 2, feedbackKey: "trainer.scenario.6.feedback", difficulty: .challenger, relatedLessonID: "match_iq", role: .feeder, ballZone: .net, targetZone: .rightFront, replayNoteKeys: ["trainer.scenario.6.replay.1", "trainer.scenario.6.replay.2", "trainer.scenario.6.replay.3"]),
        scenario(id: "s7", keyPrefix: "trainer.scenario.7", correctIndex: 1, feedbackKey: "trainer.scenario.7.feedback", difficulty: .elite, relatedLessonID: "match_iq", role: .tekong, ballZone: .service, targetZone: .rightFront, replayNoteKeys: ["trainer.scenario.7.replay.1", "trainer.scenario.7.replay.2", "trainer.scenario.7.replay.3"]),
        scenario(id: "s8", keyPrefix: "trainer.scenario.8", correctIndex: 2, feedbackKey: "trainer.scenario.8.feedback", difficulty: .elite, relatedLessonID: "foundations", role: .feeder, ballZone: .net, targetZone: .center, replayNoteKeys: ["trainer.scenario.8.replay.1", "trainer.scenario.8.replay.2", "trainer.scenario.8.replay.3"]),
        scenario(id: "s9", keyPrefix: "trainer.scenario.9", correctIndex: 0, feedbackKey: "trainer.scenario.9.feedback", difficulty: .elite, relatedLessonID: "roles", role: .killer, ballZone: .rightFront, targetZone: .leftFront, replayNoteKeys: ["trainer.scenario.9.replay.1", "trainer.scenario.9.replay.2", "trainer.scenario.9.replay.3"])
    ]

    static func learnTopic(withID id: String) -> LearnTopic? {
        learnTopics.first { $0.id == id }
    }

    static func historyStory(withID id: String) -> HistoryStory? {
        historyStories.first { $0.id == id }
    }
}
