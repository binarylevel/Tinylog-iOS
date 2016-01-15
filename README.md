Tinylog-iOS
===

[![Build Status](https://magnum.travis-ci.com/sger/Tinylog-iOS.svg?token=eNtGTmcp6xRPx3pzCGne&branch=master)](https://magnum.travis-ci.com/sger/Tinylog-iOS)

Tinylog is a minimal TODO App for iOS (iPhone/iPad).

[Download on the App Store](https://itunes.apple.com/gr/app/tinylog/id799267191?mt=8)

Setup
-----

```ruby
$ git clone https://github.com/sger/Tinylog-iOS
$ cd Tinylog-iOS
$ pod install
```

Testing
-----

```ruby
$ xctool test -workspace Tinylog.xcworkspace -scheme TinylogTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
```

Requirements
-----

Tinylog requires Swift 2.1 and Xcode 7.2.

## Author

__Spiros Gerokostas__ 

- [![](https://img.shields.io/badge/twitter-sger-brightgreen.svg)](https://twitter.com/sger) 
- :email: spiros.gerokostas@gmail.com

## License

Tinylog is available under the MIT license. See the LICENSE file for more info.
