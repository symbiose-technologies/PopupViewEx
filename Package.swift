// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "PopupViewEx",
	platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
    	.library(
    		name: "PopupViewEx",
    		targets: ["PopupViewEx"]
    	)
    ],
    targets: [
    	.target(
    		name: "PopupViewEx",
            path: "Source"
        )
    ]
)
