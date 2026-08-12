// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_alibc_kit",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "flutter-alibc", targets: ["flutter_alibc"]),
    ],
    dependencies: [],
    targets: [
        // MARK: - Plugin Target
        .target(
            name: "flutter_alibc",
            dependencies: [
                // AliAuthSDK
                "AlibabaAuthEntrance",
                "AlibabaAuthExt",
                "AlibabaAuthSDK",
                // AlibcTradeSDK
                "AlibcTradeBiz",
                "AlibcTradeSDK",
                // AlibcLinkPartnerSDK
                "AlibcLinkPartnerSDK",
                // WindVane
                "WindVane",
                "WindVaneBasic",
                "WindVaneCore",
                // mtopSDK
                "MtopSDK",
                "mtopcoreopen",
                "mtopext",
                // securityGuard
                "SGIndieKit",
                "SGMain",
                "SGMiddleTier",
                "SGNoCaptcha",
                "SGSecurityBody",
                "SecurityGuardSDK",
                // UTDID & UTMini
                "UTDID",
                "UTMini",
            ],
            path: ".",
            exclude: [
                // Exclude binary frameworks (declared as binaryTarget below)
                "Source/framework",
                // Exclude non-source files
                "Package.swift",
                "Assets",
            ],
            publicHeadersPath: "Classes",
            cSettings: [
                .headerSearchPath("Classes"),
                .headerSearchPath("Classes/FlutterAlibcConstKey"),
                .headerSearchPath("Classes/Handle"),
                .headerSearchPath("Classes/Tools"),
                .headerSearchPath("Classes/WKWebView"),
            ],
            linkerSettings: [
                .linkedFramework("CoreTelephony"),
                .linkedFramework("CoreMotion"),
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
                .linkedLibrary("sqlite3"),
            ],
            resources: [
                .copy("Source/bundle/AlibabaAuthSDK.bundle"),
                .copy("Source/bundle/NBResource.bundle"),
                .copy("Source/bundle/NebulaWK.bundle"),
                .copy("Source/bundle/SmartLink.bundle"),
                .copy("Source/bundle/WindVaneBasic.bundle"),
            ]
        ),

        // MARK: - Binary Framework Targets

        // AliAuthSDK
        .binaryTarget(
            name: "AlibabaAuthEntrance",
            path: "Source/framework/AliAuthSDK/AlibabaAuthEntrance.framework"
        ),
        .binaryTarget(
            name: "AlibabaAuthExt",
            path: "Source/framework/AliAuthSDK/AlibabaAuthExt.framework"
        ),
        .binaryTarget(
            name: "AlibabaAuthSDK",
            path: "Source/framework/AliAuthSDK/AlibabaAuthSDK.framework"
        ),

        // AlibcTradeSDK
        .binaryTarget(
            name: "AlibcTradeBiz",
            path: "Source/framework/AlibcTradeSDK/AlibcTradeBiz.framework"
        ),
        .binaryTarget(
            name: "AlibcTradeSDK",
            path: "Source/framework/AlibcTradeSDK/AlibcTradeSDK.framework"
        ),

        // AlibcLinkPartnerSDK
        .binaryTarget(
            name: "AlibcLinkPartnerSDK",
            path: "Source/framework/AlibcLinkPartnerSDK.framework"
        ),

        // WindVane
        .binaryTarget(
            name: "WindVane",
            path: "Source/framework/WindVane/WindVane.framework"
        ),
        .binaryTarget(
            name: "WindVaneBasic",
            path: "Source/framework/WindVane/WindVaneBasic.framework"
        ),
        .binaryTarget(
            name: "WindVaneCore",
            path: "Source/framework/WindVane/WindVaneCore.framework"
        ),

        // mtopSDK
        .binaryTarget(
            name: "MtopSDK",
            path: "Source/framework/mtopSDK/MtopSDK.framework"
        ),
        .binaryTarget(
            name: "mtopcoreopen",
            path: "Source/framework/mtopSDK/mtopcoreopen.framework"
        ),
        .binaryTarget(
            name: "mtopext",
            path: "Source/framework/mtopSDK/mtopext.framework"
        ),

        // securityGuard
        .binaryTarget(
            name: "SGIndieKit",
            path: "Source/framework/securityGuard/SGIndieKit.framework"
        ),
        .binaryTarget(
            name: "SGMain",
            path: "Source/framework/securityGuard/SGMain.framework"
        ),
        .binaryTarget(
            name: "SGMiddleTier",
            path: "Source/framework/securityGuard/SGMiddleTier.framework"
        ),
        .binaryTarget(
            name: "SGNoCaptcha",
            path: "Source/framework/securityGuard/SGNoCaptcha.framework"
        ),
        .binaryTarget(
            name: "SGSecurityBody",
            path: "Source/framework/securityGuard/SGSecurityBody.framework"
        ),
        .binaryTarget(
            name: "SecurityGuardSDK",
            path: "Source/framework/securityGuard/SecurityGuardSDK.framework"
        ),

        // UTDID & UTMini
        .binaryTarget(
            name: "UTDID",
            path: "Source/framework/UTDID.framework"
        ),
        .binaryTarget(
            name: "UTMini",
            path: "Source/framework/UTMini.framework"
        ),
    ]
)
