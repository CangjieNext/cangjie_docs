# Cross-Compilation

Developers can cross-compile their Cangjie programs to run on different architecture platforms. Cangjie supports the following cross-compilation scenarios:

|  Compilation  Platform        | Target Platform     | Common Scenarios / Tools              | Corresponding SDK Installation Package                          |
|-------------------------|-----------------------|-------------------------------|-------------------------------------------------|
| Windows (x64)           | Android (aarch64)     | Android physical devices | cangjie-sdk-windows-x64-android.x.y.z.zip (or .exe) |
| Linux (x64)             | Android (aarch64)     | Android physical devices  | cangjie-sdk-linux-x64-android.x.y.z.tar.gz |
| macOS (aarch64/x64)     | Android (aarch64)     | Android physical devices and Android Studio Emulator | cangjie-sdk-mac-aarch64-android.x.y.z.tar.gz |
| macOS (aarch64)     | Android (arm32)       | Android physical devices | cangjie-sdk-mac-aarch64-android-arm32-x.y.z.tar.gz |
| macOS (aarch64)         | iOS (aarch64)         | iOS physical devices | cangjie-sdk-mac-aarch64-ios.x.y.z.tar.gz |
| macOS (aarch64)         | iOS Simulator (aarch64/x86_64)   | Xcode Simulator | cangjie-sdk-mac-aarch64-ios.x.y.z.tar.gz |


The Cangjie programming language now supports cross-compilation to `Android` (`aarch64` defaults to `API 26+`, and `arm32` defaults to `API 23+`) and `iOS`, enabling developers to build applications across different platforms.

## Cross-Compiling Cangjie to Android

### Package Download

Developers can use Cangjie installation packages that support cross-compilation for specific platforms (`android-aarch64`, `android-arm32`). `Android aarch64` and `Android arm32` require different SDK installation packages.

**Cangjie installation packages supporting cross-compilation to Android are listed below (the exact version number depends on the actual release package):**

- Android `aarch64`:
  `cangjie-sdk-linux-x64-android.x.y.z.tar.gz`, `cangjie-sdk-windows-x64-android.x.y.z.zip`, `cangjie-sdk-windows-x64-android.x.y.z.exe`, `cangjie-sdk-mac-aarch64-android.x.y.z.tar.gz`
- Android `arm32`:
  `cangjie-sdk-mac-aarch64-android-arm32.tar.gz`

For example: To cross-compile to `Android aarch64` on a `linux x64` platform, download and install `cangjie-sdk-linux-x64-android.x.y.z.tar.gz`.

In addition to the cross-compilation-supported Cangjie package, you also need `Android NDK` (recommended: `ndk-r27d`).

### Compilation

Cross-compiling Cangjie to `Android` requires the following three dependency directories:

1. `sysroot` directory, provided by `Android NDK`, typically located at `<ndk-path>/toolchains/llvm/prebuilt/<platform>/sysroot`.

2. Directory containing `libclang_rt.builtins-<arch>-android.a` (for example, `libclang_rt.builtins-aarch64-android.a` or `libclang_rt.builtins-arm-android.a`), provided by `Android NDK`, typically located at `<ndk-path>/toolchains/llvm/prebuilt/<platform>/lib/clang/<version>/lib/linux`.

3. Toolchain binary directory, provided by `Android NDK`, typically located at `<ndk-path>/toolchains/llvm/prebuilt/<platform>/bin`.

When using `cjc` for cross-compilation, the following additional options must be specified (replace `< >` parts with actual directories):

- `--target=aarch64-linux-android` defaults to Android API 26 for cross-compilation; append the API level suffix explicitly for a higher version, e.g. `--target=aarch64-linux-android31` for Android API 31.
- `--target=arm-linux-android23` specifies the `arm32` target platform (Android API 23).
- `--sysroot=<sysroot-path>` specifies the toolchain's root directory path `<sysroot-path>`
- `-L<lib-path>` specifies the directory `<lib-path>` containing `libclang_rt.builtins-<arch>-android.a`
- `-B<toolchain-bin-path>` specifies the `Android NDK` toolchain binary directory `<toolchain-bin-path>`

For cross-compiling to `aarch64`, run:

```shell
$ cjc main.cj --target=aarch64-linux-android31 \
  --sysroot /opt/buildtools/android_ndk-r25b/toolchains/llvm/prebuilt/linux-x86_64/sysroot \
  -L /opt/buildtools/android_ndk-r25b/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/14.0.6/lib/linux
```

- `main.cj` is the Cangjie code being cross-compiled, `aarch64-linux-android31` is the target platform
- `/opt/buildtools/android_ndk-r25b/toolchains/llvm/prebuilt/linux-x86_64/sysroot` is the toolchain root directory `<sysroot-path>`
- `/opt/buildtools/android_ndk-r25b/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/14.0.6/lib/linux` is the directory `<lib-path>` containing `libclang_rt.builtins-aarch64-android.a`

For cross-compiling to `arm32`, run:

```shell
$ cjc test.cj --target=arm-linux-android23 \
  --sysroot /home/rus/opt/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/sysroot \
  -L /home/rus/opt/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/18/lib/linux/ \
  -B/home/rus/opt/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/bin
```

- `test.cj` is the Cangjie code being cross-compiled, `arm-linux-android23` is the target platform
- `/home/rus/opt/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/sysroot` is the toolchain root directory `<sysroot-path>`
- `/home/rus/opt/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/18/lib/linux/` is the directory `<lib-path>` containing `libclang_rt.builtins-arm-android.a`
- `/home/rus/opt/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/bin` is the toolchain binary directory `<toolchain-bin-path>`

> **Notes：**
>
> ARM32 does not support reflection-related features, stack expansion, runtime tracing, and other related functionalities.

### Deployment and Execution

After compilation, the following files need to be pushed to the `Android` device:

- The executable and all its dependent dynamic libraries: e.g., `main` and its dependent `.so` files
- Cangjie runtime dependencies: choose the corresponding directory based on the target platform (for example, `aarch64-linux-android31` uses `$CANGJIE_HOME/runtime/lib/linux_android31_aarch64_cjnative/*.so`, while `arm-linux-android23` uses `$CANGJIE_HOME/runtime/lib/linux_android23_arm_cjnative/*.so`; actual directory names depend on the SDK)

Use the `Android` Debug Bridge `adb` tool to push the executable and Cangjie libraries to the device. Example:

`aarch64` target example:

```shell
$ adb push ./main /data/local/tmp/
$ adb push $CANGJIE_HOME/runtime/lib/linux_android31_aarch64_cjnative/* /data/local/tmp/
```

`arm32` target example:

```shell
$ adb push ./main /data/local/tmp/
$ adb push $CANGJIE_HOME/runtime/lib/linux_android23_arm_cjnative/* /data/local/tmp/
```

For detailed usage of the `adb` tool, please refer to the `Android` Debug Bridge (`adb`) documentation on the official `Android` website.

`.so` dynamic library files can be deployed directly to system directories. If deployed in non-standard directories, add the directory to the `LD_LIBRARY_PATH` environment variable before execution.

To run the Cangjie program `main`:

```shell
$ adb shell "chmod +x /data/local/tmp/main"
$ adb shell "LD_LIBRARY_PATH=/data/local/tmp /data/local/tmp/main"
```

## Cross-Compiling Cangjie to iOS

### Package Download

The Cangjie SDK that supports cross-compiling for iOS is provided as `cangjie-sdk-mac-aarch64-ios.x.y.z.tar.gz` .

To cross-compile to `iOS` on a `macOS` platform, download and install the package that matches your host architecture . The Cangjie runtime and standard libraries natively support `iOS 11` and above (for exceptions, refer to the "Cangjie Programming Language Library API" manual).

In addition to the cross-compilation supported Cangjie package, you also need to download `Xcode`. After installation, install the iOS development components in Xcode. Refer to the "Downloading and installing additional Xcode components" section in the Xcode manual for specific steps.

### Compilation

Currently, Cangjie cross-compilation to iOS only supports compiling static libraries. When cross-compiling Cangjie code to `iOS` devices, specify the following additional options:

- `--target=aarch64-apple-ios<version>` specifies the target platform `ios` for cross-compilation
- `--output-type=staticlib` specifies the output file type as a static library

> **Notes：**
>
> The version number specified by \<version> is recommended to align with the SDK version supported by the installed Xcode (e.g., 17.5).

Currently, Cangjie supports cross-compiling to the x86_64 architecture iOS simulator from an aarch64 architecture environment (the compiled product for this architecture requires Rosetta in Xcode to run).For running on iOS simulators, specify:

- `--target=aarch64-apple-ios-simulator` or `--target=x86_64-apple-ios-simulator` specifies the target platform `ios-simulator` for cross-compilation
- `--output-type=staticlib` specifies the output file type as a static library

The compilation output must be added to an `Xcode` project and built through `Xcode` to create an `iOS` application.

Example command to compile `main.cj` into `libmain.a` static library:

```shell
cjc main.cj --output-type=staticlib --target=aarch64-apple-ios17.5 -o libmain.a
```

`main.cj` is the Cangjie code being cross-compiled, `aarch64-apple-ios17.5` is the target platform, and `--output-type=staticlib` specifies the output file type as a static library.

In addition to adding the Cangjie compilation output to the `Xcode` project, the following configurations are required when building with `Xcode`:

1. Select a directory based on the runtime target (device or simulator):

    - For devices: `$CANGJIE_HOME/lib/ios_aarch64_cjnative`

    - For simulators: `$CANGJIE_HOME/lib/ios_simulator_aarch64_cjnative`

    Add all `.a` files from the corresponding directory to the `Xcode` project.

2. Configure the `Build Settings > Other Linker Flags` field in the `Xcode` project with the following values:

    - `$CANGJIE_HOME/lib/ios_aarch64_cjnative/section.o`

    - `$CANGJIE_HOME/lib/ios_aarch64_cjnative/cjstart.o`

    - `-lc++`

    Note: The linking options must be added in the exact order listed above. Replace `$CANGJIE_HOME` with the actual Cangjie installation directory. For simulator targets, replace `ios_aarch64_cjnative` with `ios_simulator_aarch64_cjnative`.

3. Set the `Build Settings > Dead Code Stripping` field in the `Xcode` project to `No`.

After configuration, build the project directly through `Xcode`.

### Deployment and Execution

Build and deploy to real devices or simulators through `Xcode`. Refer to the "Build and running an app" section in the `Xcode` manual for specific steps.
