try (file2 = File("./tempFile.txt", Read)) {
    ...
    // Automatically releases the file after use
}