import Foundation
import SwiftUI

enum MatchLabTab: String, CaseIterable, Identifiable {
    case scenarios
    case miniGame

    var id: String { rawValue }
}

enum MiniGameType: String {
    case zoneTap
    case roleRead
    case patternPick

    var titleKey: String {
        switch self {
        case .zoneTap: "trainer.minigame.type.zoneTap"
        case .roleRead: "trainer.minigame.type.roleRead"
        case .patternPick: "trainer.minigame.type.patternPick"
        }
    }

    var subtitleKey: String {
        switch self {
        case .zoneTap: "trainer.minigame.type.zoneTap.subtitle"
        case .roleRead: "trainer.minigame.type.roleRead.subtitle"
        case .patternPick: "trainer.minigame.type.patternPick.subtitle"
        }
    }
}

enum MiniGamePattern: String, CaseIterable, Identifiable {
    case reset
    case build
    case strike

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .reset: "trainer.minigame.pattern.reset"
        case .build: "trainer.minigame.pattern.build"
        case .strike: "trainer.minigame.pattern.strike"
        }
    }
}

struct MiniGameDrill {
    let type: MiniGameType
    let role: TakrawRole
    let ballZone: CourtZone
    let targetZone: CourtZone
    let promptKey: String
    let successFeedbackKey: String
    let failureFeedbackKey: String
    let correctRole: TakrawRole?
    let correctPattern: MiniGamePattern?
}

@MainActor
final class AppSettings: ObservableObject {
    @Published var selectedLanguageCode: String {
        didSet {
            UserDefaults.standard.set(selectedLanguageCode, forKey: Self.languageKey)
        }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Self.onboardingKey)
        }
    }

    @Published var coachHintsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(coachHintsEnabled, forKey: Self.coachHintsKey)
        }
    }

    @Published var autoSaveCorrectLessons: Bool {
        didSet {
            UserDefaults.standard.set(autoSaveCorrectLessons, forKey: Self.autoSaveLessonsKey)
        }
    }

    private static let languageKey = "settings.language"
    private static let onboardingKey = "settings.onboarding"
    private static let coachHintsKey = "settings.coachHints"
    private static let autoSaveLessonsKey = "settings.autoSaveLessons"

    init() {
        let defaults = UserDefaults.standard
        selectedLanguageCode = defaults.string(forKey: Self.languageKey) ?? AppLanguage.en.localeIdentifier
        hasCompletedOnboarding = defaults.bool(forKey: Self.onboardingKey)
        coachHintsEnabled = defaults.object(forKey: Self.coachHintsKey) as? Bool ?? true
        autoSaveCorrectLessons = defaults.object(forKey: Self.autoSaveLessonsKey) as? Bool ?? true
    }

    var currentLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode) ?? .en
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var streakDays: Int
    @Published private(set) var totalCorrectAnswers: Int
    @Published private(set) var savedLessons: Set<String>
    @Published private(set) var unlockedAchievements: Set<String>
    @Published private(set) var highScore: Int
    @Published private(set) var lastActiveDay: String?

    private static let streakKey = "progress.streak"
    private static let correctKey = "progress.correct"
    private static let savedLessonsKey = "progress.savedLessons"
    private static let achievementsKey = "progress.achievements"
    private static let highScoreKey = "progress.highScore"
    private static let lastActiveDayKey = "progress.lastActiveDay"

    init() {
        let defaults = UserDefaults.standard
        streakDays = defaults.integer(forKey: Self.streakKey)
        totalCorrectAnswers = defaults.integer(forKey: Self.correctKey)
        savedLessons = Set(defaults.stringArray(forKey: Self.savedLessonsKey) ?? [])
        unlockedAchievements = Set(defaults.stringArray(forKey: Self.achievementsKey) ?? [])
        highScore = defaults.integer(forKey: Self.highScoreKey)
        lastActiveDay = defaults.string(forKey: Self.lastActiveDayKey)
    }

    var savedLessonsCount: Int { savedLessons.count }
    var achievementsCount: Int { unlockedAchievements.count }

    func toggleSavedLesson(_ id: String) {
        if savedLessons.contains(id) {
            savedLessons.remove(id)
        } else {
            savedLessons.insert(id)
            unlockedAchievements.insert("first_save")
        }
        persist()
    }

    func isLessonSaved(_ id: String) -> Bool {
        savedLessons.contains(id)
    }

    func registerTrainingActivity(correctAnswers: Int, earnedScore: Int, difficulty: TrainerDifficulty, perfectRun: Bool, relatedLessonID: String?, autoSaveLesson: Bool) {
        refreshStreak()
        totalCorrectAnswers += correctAnswers
        highScore = max(highScore, earnedScore)

        if autoSaveLesson, let relatedLessonID {
            savedLessons.insert(relatedLessonID)
        }

        if totalCorrectAnswers >= 10 {
            unlockedAchievements.insert("ten_correct")
        }

        if streakDays >= 3 {
            unlockedAchievements.insert("daily_streak")
        }

        if difficulty == .elite, perfectRun {
            unlockedAchievements.insert("elite_perfect")
        }

        if !savedLessons.isEmpty {
            unlockedAchievements.insert("first_save")
        }

        persist()
    }

    func registerMiniGameActivity(correctAnswer: Bool, currentScore: Int, streak: Int) {
        refreshStreak()
        highScore = max(highScore, currentScore)

        if correctAnswer {
            totalCorrectAnswers += 1
            unlockedAchievements.insert("first_minigame")
        }

        if totalCorrectAnswers >= 10 {
            unlockedAchievements.insert("ten_correct")
        }

        if streak >= 5 {
            unlockedAchievements.insert("mini_streak")
        }

        if streakDays >= 3 {
            unlockedAchievements.insert("daily_streak")
        }

        persist()
    }

    func resetAll() {
        streakDays = 0
        totalCorrectAnswers = 0
        savedLessons = []
        unlockedAchievements = []
        highScore = 0
        lastActiveDay = nil
        persist()
    }

    private func refreshStreak() {
        let today = Self.dayStamp(for: Date())
        if lastActiveDay == today {
            return
        }

        if let lastActiveDay, let lastDate = Self.date(from: lastActiveDay) {
            let delta = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if delta == 1 {
                streakDays += 1
            } else if delta > 1 {
                streakDays = 1
            } else if delta == 0 {
                streakDays = max(streakDays, 1)
            }
        } else {
            streakDays = 1
        }

        lastActiveDay = today
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(streakDays, forKey: Self.streakKey)
        defaults.set(totalCorrectAnswers, forKey: Self.correctKey)
        defaults.set(Array(savedLessons).sorted(), forKey: Self.savedLessonsKey)
        defaults.set(Array(unlockedAchievements).sorted(), forKey: Self.achievementsKey)
        defaults.set(highScore, forKey: Self.highScoreKey)
        defaults.set(lastActiveDay, forKey: Self.lastActiveDayKey)
    }

    private static func dayStamp(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func date(from stamp: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: stamp)
    }
}

@MainActor
final class TrainerStore: ObservableObject {
    @Published var selectedTab: MatchLabTab = .scenarios
    @Published var difficulty: TrainerDifficulty = .starter {
        didSet {
            restartForDifficulty()
        }
    }
    @Published var scenarioIndex = 0
    @Published var selectedIndex: Int?
    @Published var sessionScore = 0
    @Published var combo = 0
    @Published var correctAnswers = 0
    @Published var sessionBest = 0
    @Published var replayStep = 0
    @Published var isReplayPlaying = false
    @Published var miniGameIndex = 0
    @Published var miniGameScore = 0
    @Published var miniGameStreak = 0
    @Published var miniGameBestStreak = 0
    @Published var miniGameFeedbackKey = "trainer.minigame.instruction.zoneTap"
    @Published var miniGameLastZoneChoice: CourtZone?
    @Published var miniGameLastRoleChoice: TakrawRole?
    @Published var miniGameLastPatternChoice: MiniGamePattern?
    @Published var miniGameRoundResolved = false
    @Published var miniGameFlightToken = 0
    @Published var miniGameCorrectAnswers = 0
    @Published var miniGameRoundsPlayed = 0
    @Published var isShowingMiniGameResults = false

    private var replayTask: Task<Void, Never>?
    private let miniGameDrills: [MiniGameDrill] = [
        MiniGameDrill(
            type: .zoneTap,
            role: .feeder,
            ballZone: .leftFront,
            targetZone: .net,
            promptKey: "trainer.minigame.drill.1.prompt",
            successFeedbackKey: "trainer.minigame.drill.1.success",
            failureFeedbackKey: "trainer.minigame.drill.1.failure",
            correctRole: nil,
            correctPattern: nil
        ),
        MiniGameDrill(
            type: .roleRead,
            role: .tekong,
            ballZone: .service,
            targetZone: .rightFront,
            promptKey: "trainer.minigame.drill.2.prompt",
            successFeedbackKey: "trainer.minigame.drill.2.success",
            failureFeedbackKey: "trainer.minigame.drill.2.failure",
            correctRole: .tekong,
            correctPattern: nil
        ),
        MiniGameDrill(
            type: .patternPick,
            role: .killer,
            ballZone: .net,
            targetZone: .center,
            promptKey: "trainer.minigame.drill.3.prompt",
            successFeedbackKey: "trainer.minigame.drill.3.success",
            failureFeedbackKey: "trainer.minigame.drill.3.failure",
            correctRole: nil,
            correctPattern: .reset
        ),
        MiniGameDrill(
            type: .zoneTap,
            role: .feeder,
            ballZone: .net,
            targetZone: .rightFront,
            promptKey: "trainer.minigame.drill.4.prompt",
            successFeedbackKey: "trainer.minigame.drill.4.success",
            failureFeedbackKey: "trainer.minigame.drill.4.failure",
            correctRole: nil,
            correctPattern: nil
        ),
        MiniGameDrill(
            type: .roleRead,
            role: .killer,
            ballZone: .rightFront,
            targetZone: .leftFront,
            promptKey: "trainer.minigame.drill.5.prompt",
            successFeedbackKey: "trainer.minigame.drill.5.success",
            failureFeedbackKey: "trainer.minigame.drill.5.failure",
            correctRole: .killer,
            correctPattern: nil
        ),
        MiniGameDrill(
            type: .patternPick,
            role: .feeder,
            ballZone: .service,
            targetZone: .rightFront,
            promptKey: "trainer.minigame.drill.6.prompt",
            successFeedbackKey: "trainer.minigame.drill.6.success",
            failureFeedbackKey: "trainer.minigame.drill.6.failure",
            correctRole: nil,
            correctPattern: .build
        )
    ]

    deinit {
        replayTask?.cancel()
    }

    var currentScenario: TacticScenario {
        scenariosForDifficulty[scenarioIndex]
    }

    var scenariosForDifficulty: [TacticScenario] {
        AppData.scenarios.filter { $0.difficulty == difficulty }
    }

    var isAnswered: Bool {
        selectedIndex != nil
    }

    var progressText: String {
        "\(scenarioIndex + 1)/\(scenariosForDifficulty.count)"
    }

    var currentMiniGameDrill: MiniGameDrill {
        miniGameDrills[miniGameIndex]
    }

    var miniGameRoundText: String {
        "\(miniGameIndex + 1)/\(miniGameDrills.count)"
    }

    var currentMiniGameType: MiniGameType {
        currentMiniGameDrill.type
    }

    var isLastMiniGameRound: Bool {
        miniGameIndex == miniGameDrills.count - 1
    }

    func choose(_ index: Int) {
        guard selectedIndex == nil else { return }
        selectedIndex = index

        if index == currentScenario.correctIndex {
            combo += 1
            correctAnswers += 1
            sessionScore += difficulty.points + combo * 2
            sessionBest = max(sessionBest, sessionScore)
        } else {
            combo = 0
            sessionScore = max(0, sessionScore - 4)
        }

        withAnimation(.easeInOut(duration: 0.45)) {
            replayStep = 2
        }
    }

    func advance(settings: AppSettings, progressStore: ProgressStore) {
        guard selectedIndex != nil else { return }

        let finishedDifficulty = difficulty
        let wasPerfectRun = correctAnswers == scenariosForDifficulty.count
        let relatedLessonID = currentScenario.relatedLessonID
        let earnedScore = sessionScore
        let earnedCorrect = correctAnswers

        stopReplay()

        if scenarioIndex == scenariosForDifficulty.count - 1 {
            progressStore.registerTrainingActivity(
                correctAnswers: earnedCorrect,
                earnedScore: earnedScore,
                difficulty: finishedDifficulty,
                perfectRun: wasPerfectRun,
                relatedLessonID: relatedLessonID,
                autoSaveLesson: settings.autoSaveCorrectLessons
            )
            resetSession(keepDifficulty: true)
            return
        }

        scenarioIndex += 1
        selectedIndex = nil
        replayStep = 0
    }

    func resetSession(keepDifficulty: Bool = true) {
        stopReplay()

        if !keepDifficulty {
            difficulty = .starter
        }
        scenarioIndex = 0
        selectedIndex = nil
        sessionScore = 0
        combo = 0
        correctAnswers = 0
        replayStep = 0
    }

    func previousReplayStep() {
        stopReplay()
        guard replayStep > 0 else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            replayStep -= 1
        }
    }

    func nextReplayStep() {
        stopReplay()
        guard replayStep < 2 else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            replayStep += 1
        }
    }

    func toggleReplay() {
        isReplayPlaying ? stopReplay() : playReplay()
    }

    func playMiniGame(on zone: CourtZone, progressStore: ProgressStore) {
        guard currentMiniGameType == .zoneTap, !miniGameRoundResolved else { return }
        miniGameLastZoneChoice = zone
        miniGameRoundResolved = true

        let isCorrect = zone == currentMiniGameDrill.targetZone
        if isCorrect {
            miniGameFlightToken += 1
        }
        completeMiniGameAttempt(
            isCorrect: isCorrect,
            successFeedbackKey: currentMiniGameDrill.successFeedbackKey,
            failureFeedbackKey: currentMiniGameDrill.failureFeedbackKey,
            progressStore: progressStore
        )
    }

    func playMiniGame(with role: TakrawRole, progressStore: ProgressStore) {
        guard currentMiniGameType == .roleRead, !miniGameRoundResolved else { return }
        miniGameLastRoleChoice = role
        miniGameRoundResolved = true

        completeMiniGameAttempt(
            isCorrect: role == currentMiniGameDrill.correctRole,
            successFeedbackKey: currentMiniGameDrill.successFeedbackKey,
            failureFeedbackKey: currentMiniGameDrill.failureFeedbackKey,
            progressStore: progressStore
        )
    }

    func playMiniGame(with pattern: MiniGamePattern, progressStore: ProgressStore) {
        guard currentMiniGameType == .patternPick, !miniGameRoundResolved else { return }
        miniGameLastPatternChoice = pattern
        miniGameRoundResolved = true

        completeMiniGameAttempt(
            isCorrect: pattern == currentMiniGameDrill.correctPattern,
            successFeedbackKey: currentMiniGameDrill.successFeedbackKey,
            failureFeedbackKey: currentMiniGameDrill.failureFeedbackKey,
            progressStore: progressStore
        )
    }

    func nextMiniGameRound() {
        guard miniGameRoundResolved else { return }

        if miniGameIndex == miniGameDrills.count - 1 {
            isShowingMiniGameResults = true
            return
        }
        miniGameIndex += 1
        miniGameLastZoneChoice = nil
        miniGameLastRoleChoice = nil
        miniGameLastPatternChoice = nil
        miniGameRoundResolved = false
        miniGameFeedbackKey = instructionKey(for: currentMiniGameType)
    }

    func resetMiniGame() {
        miniGameIndex = 0
        miniGameScore = 0
        miniGameStreak = 0
        miniGameBestStreak = 0
        miniGameLastZoneChoice = nil
        miniGameLastRoleChoice = nil
        miniGameLastPatternChoice = nil
        miniGameRoundResolved = false
        miniGameFlightToken = 0
        miniGameCorrectAnswers = 0
        miniGameRoundsPlayed = 0
        isShowingMiniGameResults = false
        miniGameFeedbackKey = instructionKey(for: currentMiniGameType)
    }

    func closeMiniGameResults() {
        isShowingMiniGameResults = false
    }

    private func completeMiniGameAttempt(isCorrect: Bool, successFeedbackKey: String, failureFeedbackKey: String, progressStore: ProgressStore) {
        miniGameRoundsPlayed += 1
        if isCorrect {
            miniGameStreak += 1
            miniGameBestStreak = max(miniGameBestStreak, miniGameStreak)
            miniGameScore += 12 + miniGameStreak * 2
            miniGameCorrectAnswers += 1
            miniGameFeedbackKey = successFeedbackKey
        } else {
            miniGameStreak = 0
            miniGameScore = max(0, miniGameScore - 4)
            miniGameFeedbackKey = failureFeedbackKey
        }

        progressStore.registerMiniGameActivity(
            correctAnswer: isCorrect,
            currentScore: miniGameScore,
            streak: miniGameBestStreak
        )
    }

    private func instructionKey(for type: MiniGameType) -> String {
        switch type {
        case .zoneTap:
            "trainer.minigame.instruction.zoneTap"
        case .roleRead:
            "trainer.minigame.instruction.roleRead"
        case .patternPick:
            "trainer.minigame.instruction.patternPick"
        }
    }

    private func playReplay() {
        stopReplay()
        replayStep = 0
        isReplayPlaying = true

        replayTask = Task { [weak self] in
            guard let self else { return }

            for step in 0...2 {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.55)) {
                        self.replayStep = step
                    }
                }
                try? await Task.sleep(nanoseconds: 850_000_000)
            }

            await MainActor.run {
                self.isReplayPlaying = false
                self.replayTask = nil
            }
        }
    }

    private func stopReplay() {
        replayTask?.cancel()
        replayTask = nil
        isReplayPlaying = false
    }

    private func restartForDifficulty() {
        stopReplay()
        scenarioIndex = 0
        selectedIndex = nil
        sessionScore = 0
        combo = 0
        correctAnswers = 0
        replayStep = 0
    }
}
