fun testPatterns() {
    val testCommands = listOf(
        "musique play",
        "musique pause", 
        "ouvrir spotify",
        "ouvrir caméra",
        "aide",
        "volume augmenter"
    )
    
    val patterns = listOf(
        "musique.*play",
        "musique.*pause",
        "ouvrir.*",
        "aide",
        "volume.*augmenter"
    )
    
    testCommands.forEach { command ->
        println("Testing: '$command'")
        patterns.forEach { pattern ->
            val regexPattern = pattern.replace(".*", ".*").replace(" ", ".*")
            val matches = command.matches(Regex(regexPattern))
            if (matches) {
                println("  ✅ MATCH: $pattern")
            }
        }
    }
}
