{
  description = "Flutter round 2";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersion = "30.0.3";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          toolsVersion = "26.1.1";
          platformToolsVersion = "33.0.3";
          buildToolsVersions = [ "30.0.3" ];
          includeEmulator = false;
          emulatorVersion = "33.1.6";
          platformVersions = [ "28" "31" "33" ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" "x86_64" ];
          cmakeVersions = [ "3.10.2" ];
          includeNDK = true;
          ndkVersions = [ "22.0.7026061" ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
        };
        androidSdk = androidComposition.androidsdk;

        fhs = pkgs.buildFHSUserEnv {
          name = "android-sdk-env";
          targetPkgs = pkgs: (with pkgs; [
            androidSdk
            glibc
            flutter
            jdk17
          ]);
        };

        emulator = pkgs.androidenv.emulateApp {
          name = "run-emulator";
          platformVersion = "33";
          abiVersion = "x86_64";
          systemImageType = "google_apis_playstore";
        };
      in
      {
        devShell = with pkgs; mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          JAVA_HOME = jdk17;
          buildInputs = [
            fhs
            emulator
          ];
          shellHook = "exec android-sdk-env";
        };
      }
    );
}
