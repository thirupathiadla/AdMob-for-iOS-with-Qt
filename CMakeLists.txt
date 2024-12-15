# Minimum CMake Version
cmake_minimum_required(VERSION 3.16)

# Define Project
project(admob VERSION 0.1 LANGUAGES CXX OBJC OBJCXX)

# Enable Automatic Qt Features
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Required Qt Modules
find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Quick)

# Define Executable
qt_add_executable(appadmob
    main.cpp
    AdMobManager.mm
    AdMobManager.h
    adbridge.h
    adbridge.cpp
)

# Correct ObjC++ File Property for .mm file
set_source_files_properties(AdMobManager.mm PROPERTIES LANGUAGE OBJCXX)

# Link FirebaseCore and other necessary libraries
target_link_libraries(appadmob PUBLIC
    Qt6::Core
    Qt6::Widgets
    Qt6::Quick
    FirebaseCore
    "-framework UIKit"
    "-framework Foundation"
    "-framework CoreGraphics"
    "-framework JavaScriptCore"
)

# Link Google Mobile Ads Directory (Ensure you specify the correct path to the .xcframework)
set(GOOGLE_MOBILE_ADS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Pods/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework/GoogleMobileAds.xcframework")

# Embed Frameworks in Xcode
set_target_properties(appadmob PROPERTIES
    XCODE_EMBED_FRAMEWORKS "${GOOGLE_MOBILE_ADS_DIR}"
    XCODE_EMBED_FRAMEWORKS_CODE_SIGN_ON_COPY ON
    XCODE_ATTRIBUTE_SIGNING_ALLOWED TRUE
    XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/Frameworks"
)

# Enable Deployment Target
#set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0")

# Install Targets
include(GNUInstallDirs)
install(TARGETS appadmob
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
