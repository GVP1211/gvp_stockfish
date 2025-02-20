#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint stockfish.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'gvp_stockfish'
  s.version          = '1.0.0'
  s.summary          = 'Stockfish plugin for Flutter'
  s.description      = <<-DESC
Stockfish plugin for Flutter
                       DESC
  s.homepage         = 'https://gvp1211.github.io/gvp_stockfish'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Virunpat Puengrostham' => 'gem.virunpat@gmail.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'Stockfish/src/**/*'
  s.exclude_files = 'Stockfish/src/incbin/UNLICENCE', 'Stockfish/src/Makefile'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'stockfish_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  s.library = 'c++'
  s.script_phase = {
    :execution_position => :before_compile,
    :name => 'Download nnue',
    :script => 'for f in nn-1c0000000000.nnue nn-37f18f62d772.nnue ; do [ -e $f ] || curl https://data.stockfishchess.org/nn/$f -o $f ; done'
  }

  base_cplusplusflags = '-fno-exceptions -std=c++17 -pedantic -Wextra -Wshadow -Wmissing-declarations -m64 -mmacosx-version-min=10.15  -DUSE_PTHREADS -funroll-loops -DIS_64BIT'
  base_ldflags = '-m64 -mmacosx-version-min=10.15 -lpthread'

  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',

    'OTHER_CPLUSPLUSFLAGS[arch=arm64][config=Debug]' => "$(inherited) #{base_cplusplusflags} -arch arm64 -g -Og -DUSE_POPCNT -DUSE_NEON=8 -march=armv8.2-a+dotprod -DUSE_NEON_DOTPROD",
    'OTHER_CPLUSPLUSFLAGS[arch=arm64][config=Release]' => "$(inherited) #{base_cplusplusflags} -arch arm64 -DNDEBUG -O3 -DUSE_POPCNT -DUSE_NEON=8 -march=armv8.2-a+dotprod -DUSE_NEON_DOTPROD -flto=full",
    'OTHER_LDFLAGS[arch=arm64]' => "#{base_ldflags} -arch arm64",

    'OTHER_CPLUSPLUSFLAGS[arch=x86_64][config=Debug]' => "$(inherited) #{base_cplusplusflags} -DUSE_SSE2 -DDEBUG -g -Og -msse -msse2",
    'OTHER_CPLUSPLUSFLAGS[arch=x86_64][config=Release]' => "$(inherited) #{base_cplusplusflags} -DUSE_SSE2 -DNDEBUG -O3 -msse -msse2 -flto=full",
    'OTHER_LDFLAGS[arch=x86_64]' => "#{base_ldflags} -arch x86_64",

    'HEADER_SEARCH_PATHS' => [
        '"${PODS_TARGET_SRCROOT}/Stockfish/src/"'
    ],
  }
end
