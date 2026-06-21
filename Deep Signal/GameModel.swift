import Foundation
import SwiftUI

// MARK: - Static definitions

struct DishKind: Identifiable {
    let id: Int
    let name: String
    let blurb: String
    let baseCost: Double
    let baseRate: Double   // signal/sec per unit at multiplier 1.0
}

struct UpgradeKind: Identifiable {
    let id: Int
    let name: String
    let blurb: String
    let cost: Double
    let bonus: Double      // additive to global multiplier (e.g. 0.25 = +25%)
}

enum SignalDefs {
    // Tiers escalate ~4x in rate and ~12x in base cost — geometric, but the 1.15 per-owned
    // cost growth keeps total production a smooth bounded curve (no tier-surge snowball).
    static let dishes: [DishKind] = [
        DishKind(id: 0, name: "Parabolic Dish",  blurb: "A lone bowl turned to the dark.",            baseCost: 15,       baseRate: 0.2),
        DishKind(id: 1, name: "Phased Array",     blurb: "Many small antennae, steered as one.",       baseCost: 180,      baseRate: 1.0),
        DishKind(id: 2, name: "Interferometer",   blurb: "Linked dishes resolving faint detail.",      baseCost: 2_400,    baseRate: 5.0),
        DishKind(id: 3, name: "Deep Array",       blurb: "A continent of receivers, always awake.",    baseCost: 32_000,   baseRate: 26.0),
        DishKind(id: 4, name: "Orbital Net",      blurb: "A web of listeners beyond the atmosphere.",  baseCost: 420_000,  baseRate: 140.0),
        DishKind(id: 5, name: "Void Lattice",     blurb: "Receivers strung across empty space.",       baseCost: 5_600_000, baseRate: 760.0),
    ]

    // One-time multiplier upgrades. Bonuses are ADDITIVE to the global multiplier so they
    // can never compound into runaway growth.
    static let upgrades: [UpgradeKind] = [
        UpgradeKind(id: 0, name: "Cryo Receivers",   blurb: "Colder amplifiers, cleaner gain. +25% signal.",  cost: 1_000,        bonus: 0.25),
        UpgradeKind(id: 1, name: "Phase Locking",    blurb: "Tighter timing across the array. +35% signal.",  cost: 18_000,       bonus: 0.35),
        UpgradeKind(id: 2, name: "Adaptive Optics",  blurb: "Live distortion correction. +50% signal.",       cost: 240_000,      bonus: 0.50),
        UpgradeKind(id: 3, name: "Quantum Mixers",   blurb: "Noise pushed below the floor. +75% signal.",     cost: 3_200_000,    bonus: 0.75),
        UpgradeKind(id: 4, name: "Neutrino Backbone",blurb: "Faster-than-light correlation. +100% signal.",   cost: 48_000_000,   bonus: 1.0),
    ]

    static let tapBaseBurst: Double = 1.0          // base signal per tap (plus a slice of rate)
    static let insightPerDecode: Double = 0.08     // +8% per decode (additive, linear)
    static let prestigeUnlockLore: Int = 6         // need 6 decoded fragments to recalibrate
    static let resonancePerLore: Double = 0.05     // +5% permanent per decoded fragment, additive
    static let offlineCapSeconds: Double = 8 * 3600
}

// MARK: - Persisted save

struct SignalSave: Codable {
    var signal: Double = 0
    var totalSignalEarned: Double = 0
    var dishCounts: [Int] = [0, 0, 0, 0, 0, 0]
    var purchasedUpgrades: [Int] = []
    var decodeCount: Int = 0
    var unlockedLore: [Int] = []
    var recalibrations: Int = 0
    var lastActive: TimeInterval = 0
    var tapCount: Int = 0
}

// MARK: - Game model

final class SignalGame: ObservableObject {
    @Published var signal: Double = 0
    @Published var totalSignalEarned: Double = 0
    @Published var dishCounts: [Int] = [0, 0, 0, 0, 0, 0]
    @Published var purchasedUpgrades: Set<Int> = []
    @Published var decodeCount: Int = 0
    @Published var unlockedLore: Set<Int> = []
    @Published var recalibrations: Int = 0
    @Published var tapCount: Int = 0

    // Transient UI state
    @Published var offlineSummary: OfflineSummary? = nil

    private var lastActive: TimeInterval = Date().timeIntervalSince1970
    private var lastTick: TimeInterval = Date().timeIntervalSince1970
    private var lastSave: TimeInterval = 0
    private var timer: Timer?

    private let saveURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("deepsignal_save.json")
    }()

    struct OfflineSummary: Identifiable {
        let id = UUID()
        let earned: Double
        let seconds: Double
        let capped: Bool
    }

    init() {
        load()
        lastTick = Date().timeIntervalSince1970
    }

    // MARK: Derived values

    // Insight: additive, linear in decode count. Capped soft growth.
    var insightMultiplier: Double {
        return 1.0 + Double(decodeCount) * SignalDefs.insightPerDecode
    }

    // Resonance is a permanent prestige bonus, earned ONLY by recalibrating, scaled by how
    // much lore has been decoded. Additive so it can never compound into runaway growth.
    var resonanceFromRecalibrations: Double {
        return Double(recalibrations) * (Double(unlockedLore.count) * SignalDefs.resonancePerLore)
    }

    var upgradeBonus: Double {
        var b = 0.0
        for u in SignalDefs.upgrades where purchasedUpgrades.contains(u.id) {
            b += u.bonus
        }
        return b
    }

    // Global multiplier: all terms ADDITIVE → bounded, smooth.
    var globalMultiplier: Double {
        return (1.0 + upgradeBonus) * insightMultiplier * (1.0 + resonanceFromRecalibrations)
    }

    var baseSignalPerSecond: Double {
        var rate = 0.0
        for d in SignalDefs.dishes {
            rate += Double(dishCounts[d.id]) * d.baseRate
        }
        return rate
    }

    var signalPerSecond: Double {
        return baseSignalPerSecond * globalMultiplier
    }

    var tapReward: Double {
        // Small burst: base + 1s worth a fraction of production, so tapping stays minor.
        return (SignalDefs.tapBaseBurst + signalPerSecond * 0.05) * max(1.0, insightMultiplier)
    }

    func dishCost(_ kind: DishKind) -> Double {
        let owned = dishCounts[kind.id]
        return (kind.baseCost * pow(1.15, Double(owned))).rounded()
    }

    func canBuyDish(_ kind: DishKind) -> Bool { signal >= dishCost(kind) }

    func canBuyUpgrade(_ kind: UpgradeKind) -> Bool {
        return !purchasedUpgrades.contains(kind.id) && signal >= kind.cost
    }

    var prestigeUnlocked: Bool { unlockedLore.count >= SignalDefs.prestigeUnlockLore }

    // Resonance gained if recalibrating right now.
    var pendingResonanceGain: Double { Double(unlockedLore.count) * SignalDefs.resonancePerLore }

    var highestUnlockedLoreIndex: Int { unlockedLore.max() ?? -1 }

    // MARK: Actions

    func buyDish(_ kind: DishKind) {
        let cost = dishCost(kind)
        guard signal >= cost else { return }
        signal -= cost
        dishCounts[kind.id] += 1
        throttledSave()
    }

    func buyUpgrade(_ kind: UpgradeKind) {
        guard canBuyUpgrade(kind) else { return }
        signal -= kind.cost
        purchasedUpgrades.insert(kind.id)
        throttledSave()
    }

    func tapBoost() {
        let r = tapReward
        signal += r
        totalSignalEarned += r
        tapCount += 1
    }

    // Cost of a decode attempt scales with progress so it stays a meaningful spend.
    var decodeCost: Double {
        let base = 250.0
        return (base * pow(2.4, Double(decodeCount))).rounded()
    }

    func canAffordDecode() -> Bool { signal >= decodeCost && unlockedLore.count < SignalLore.count }

    var allLoreDecoded: Bool { unlockedLore.count >= SignalLore.count }

    // Spend signal to begin a decode. Returns true if charged.
    func payForDecode() -> Bool {
        guard canAffordDecode() else { return false }
        signal -= decodeCost
        return true
    }

    // Called on a successful mini-game decode.
    @discardableResult
    func completeDecode() -> Int? {
        decodeCount += 1
        // Unlock next lore fragment in order.
        let next = unlockedLore.count
        var unlocked: Int? = nil
        if next < SignalLore.count {
            unlockedLore.insert(next)
            unlocked = next
        }
        throttledSave()
        return unlocked
    }

    func recalibrate() {
        guard prestigeUnlocked else { return }
        recalibrations += 1
        signal = 0
        totalSignalEarned = 0
        dishCounts = [0, 0, 0, 0, 0, 0]
        purchasedUpgrades = []
        // Keep: decodeCount, unlockedLore, recalibrations.
        save()
    }

    func resetAll() {
        signal = 0
        totalSignalEarned = 0
        dishCounts = [0, 0, 0, 0, 0, 0]
        purchasedUpgrades = []
        decodeCount = 0
        unlockedLore = []
        recalibrations = 0
        tapCount = 0
        offlineSummary = nil
        save()
    }

    // MARK: Tick

    func startTicking() {
        timer?.invalidate()
        let t = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stopTicking() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let now = Date().timeIntervalSince1970
        let dt = max(0, now - lastTick)
        lastTick = now
        guard dt > 0 else { return }
        let gain = signalPerSecond * dt
        if gain > 0 {
            signal += gain
            totalSignalEarned += gain
        }
        // Periodic autosave every ~15s while foregrounded.
        if now - lastSave > 15 {
            save()
        }
    }

    // MARK: Scene phase

    // CRITICAL (pitfall): stamp lastActive ONLY on .background. .inactive fires both ways
    // and would zero the offline credit.
    func handleBackground() {
        lastActive = Date().timeIntervalSince1970
        save()
    }

    func handleForeground() {
        creditOfflineEarnings()
        lastTick = Date().timeIntervalSince1970
        save()
    }

    private func creditOfflineEarnings() {
        let now = Date().timeIntervalSince1970
        guard lastActive > 0 else { lastActive = now; return }
        let elapsed = now - lastActive
        guard elapsed > 5 else { return } // ignore brief switches
        let capped = elapsed > SignalDefs.offlineCapSeconds
        let used = min(elapsed, SignalDefs.offlineCapSeconds)
        let earned = signalPerSecond * used
        if earned > 0 {
            signal += earned
            totalSignalEarned += earned
            offlineSummary = OfflineSummary(earned: earned, seconds: used, capped: capped)
        }
        lastActive = now
    }

    // MARK: Persistence

    private func throttledSave() {
        let now = Date().timeIntervalSince1970
        if now - lastSave > 2 { save() }
    }

    func save() {
        lastSave = Date().timeIntervalSince1970
        var s = SignalSave()
        s.signal = signal
        s.totalSignalEarned = totalSignalEarned
        s.dishCounts = dishCounts
        s.purchasedUpgrades = Array(purchasedUpgrades)
        s.decodeCount = decodeCount
        s.unlockedLore = Array(unlockedLore)
        s.recalibrations = recalibrations
        s.lastActive = lastActive
        s.tapCount = tapCount
        if let data = try? JSONEncoder().encode(s) {
            try? data.write(to: saveURL, options: .atomic)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let s = try? JSONDecoder().decode(SignalSave.self, from: data) else {
            lastActive = Date().timeIntervalSince1970
            return
        }
        signal = s.signal
        totalSignalEarned = s.totalSignalEarned
        // Guard against array-size drift if dish roster changes.
        var counts = s.dishCounts
        while counts.count < SignalDefs.dishes.count { counts.append(0) }
        if counts.count > SignalDefs.dishes.count { counts = Array(counts.prefix(SignalDefs.dishes.count)) }
        dishCounts = counts
        purchasedUpgrades = Set(s.purchasedUpgrades)
        decodeCount = s.decodeCount
        unlockedLore = Set(s.unlockedLore.filter { $0 >= 0 && $0 < SignalLore.count })
        recalibrations = s.recalibrations
        tapCount = s.tapCount
        lastActive = s.lastActive > 0 ? s.lastActive : Date().timeIntervalSince1970
    }
}
