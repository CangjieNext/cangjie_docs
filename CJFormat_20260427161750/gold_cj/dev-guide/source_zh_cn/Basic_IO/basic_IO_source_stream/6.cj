import std.fs.{copy, rename, remove}

main() {
    copy("./tempFile.txt", to: "./tempFile2.txt", overwrite: false)
    rename("./tempFile2.txt", to: "./tempFile3.txt", overwrite: false)
    remove("./tempFile3.txt")
}
