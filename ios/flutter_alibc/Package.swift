// swift-tools-version: 5.9
import PackageDescription

let sdkTargets: [String] = [
    "AlibabaAuthEntrance",
    "AlibabaAuthExt",
    "AlibabaAuthSDK",
    "AlibcLinkPartnerSDK",
    "AlibcTradeBiz",
    "AlibcTradeSDK",
    "MtopSDK",
    "SGIndieKit",
    "SGMain",
    "SGMiddleTier",
    "SGNoCaptcha",
    "SGSecurityBody",
    "SecurityGuardSDK",
    "UTDID",
    "UTMini",
    "WindVane",
    "WindVaneBasic",
    "WindVaneCore",
    "mtopcoreopen",
    "mtopext",
]

let package = Package(
    name: "flutter_alibc",
    platforms: [.iOS("13.0")],
    products: [.library(name: "flutter-alibc", targets: ["flutter_alibc"])],
    dependencies: [.package(name: "FlutterFramework", path: "../FlutterFramework")],
    targets: [
        .target(
            name: "flutter_alibc",
            dependencies: [.product(name: "FlutterFramework", package: "FlutterFramework")]
                + sdkTargets.map { .target(name: $0) },
            resources: [.copy("Resources/AlibabaAuthSDK.bundle"),
                        .copy("Resources/NBResource.bundle"),
                        .copy("Resources/NebulaWK.bundle"),
                        .copy("Resources/SmartLink.bundle"),
                        .copy("Resources/WindVaneBasic.bundle")],
            linkerSettings: [
                .linkedFramework("CoreTelephony"), .linkedFramework("CoreMotion"),
                .linkedFramework("UIKit"), .linkedFramework("Foundation"),
                .linkedLibrary("z"), .linkedLibrary("c++"), .linkedLibrary("sqlite3"),
                .unsafeFlags(["-ObjC"])
            ]
        )
    ] + sdkTargets.map {
        .binaryTarget(name: $0, path: "Frameworks/\($0).xcframework")
    }
)
