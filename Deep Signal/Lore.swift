import Foundation

// 16 evocative lore fragments — a loose narrative of a fading alien civilization
// whose final broadcasts your array slowly decodes.
struct LoreFragment: Identifiable {
    let id: Int
    let title: String
    let body: String
}

enum SignalLore {
    static let fragments: [LoreFragment] = [
        LoreFragment(id: 0, title: "First Carrier",
            body: "A tone, impossibly clean, riding beneath the cosmic hiss. It does not pulse like a star or a beacon. It breathes. Something out there is still exhaling into the dark."),
        LoreFragment(id: 1, title: "The Counting",
            body: "Primes, then their gaps, then the silences between the gaps. They taught us their numbers first, as if to say: we know you will not understand the rest, but you will understand this."),
        LoreFragment(id: 2, title: "A Name For Home",
            body: "They called their world Sehl — the syllable repeats across every transmission like a heartbeat. Three suns once warmed it. The decode renders only two as present tense."),
        LoreFragment(id: 3, title: "The Long Day",
            body: "Their year was four of ours. Generations measured seasons the way we measure breaths. Patience, for them, was not a virtue. It was simply the shape of time."),
        LoreFragment(id: 4, title: "Builders of Glass",
            body: "Cities grown, not built — lattices of living silica that sang when the wind moved through them. Every street was an instrument. The whole planet was a chord held for ten thousand years."),
        LoreFragment(id: 5, title: "The Listeners",
            body: "Like us, they built arrays and aimed them outward. For nine centuries they heard nothing. They kept listening anyway. The fragment ends with a phrase we translate as: silence is also an answer."),
        LoreFragment(id: 6, title: "Dimming",
            body: "The eldest sun began to cool. Not violently — gently, the way a lamp lowers when oil runs thin. They had millennia of warning. They spent the first thousand years in denial, and called it hope."),
        LoreFragment(id: 7, title: "The Migration That Wasn't",
            body: "They had no ships fast enough, no world close enough. So they did the only thing left: they decided to be remembered instead of saved. The arrays turned from listening to speaking."),
        LoreFragment(id: 8, title: "Archive of Sehl",
            body: "Every song, every name, every argument settled and unsettled — encoded, compressed, repeated on a loop aimed at the whole sky. A civilization folded into a signal. This is that signal."),
        LoreFragment(id: 9, title: "The Children's Channel",
            body: "One sub-band carries only the voices of the young, laughing at something the translation cannot recover. They chose to send joy, not warning. We are still deciding what that means."),
        LoreFragment(id: 10, title: "Caretakers",
            body: "A guild remained to tend the transmitters as the cold came, generation after generation, each born knowing they would never be heard back. They called the work tending the lamp."),
        LoreFragment(id: 11, title: "The Last Argument",
            body: "Two factions, near the end. One wished to stop broadcasting and simply live the remaining time in peace. The other could not bear to be unwitnessed. The signal continues, so we know which one prevailed."),
        LoreFragment(id: 12, title: "Coordinates",
            body: "Buried in the loop, a map — not to Sehl, but to the others they had heard and never answered. A list of regrets, rendered as right ascension and declination. We have begun to check them."),
        LoreFragment(id: 13, title: "The Final Caretaker",
            body: "One voice, alone, much later than the rest. The array is failing; the syntax is breaking. She is not transmitting the archive anymore. She is just talking. To anyone. To us."),
        LoreFragment(id: 14, title: "Last Transmission",
            body: "The carrier we first detected — the clean impossible tone — was never a beacon. It was the empty channel left running after the last voice stopped. We have been listening to an open door."),
        LoreFragment(id: 15, title: "Resonance",
            body: "Recalibrating the array, you understand the final instruction hidden in the counting from the very first fragment: do not mourn us. Continue the listening. Somewhere the next signal is already on its way."),
    ]

    static var count: Int { fragments.count }
}
