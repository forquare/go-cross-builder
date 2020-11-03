The version represents the Go version + a counter.

So if the Go version is `1.15.3` and this is the first version based on that:

```bash
version=1.15.3 make install
```

# macOS

The macOS part of the build requires the macOS SDK.

To obtain it, register for a developer account, then download Xcode:

https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_8.3.3/Xcode8.3.3.xip

Use this page to find links: https://stackoverflow.com/questions/10335747/how-to-download-xcode-dmg-or-xip-file

Or check out crossbuild: https://github.com/multiarch/crossbuild/blob/master/Dockerfile


Using macOS, you can mount the dmg and create the SDK tarfile with `create_osx_sdk.sh`.


This was taken from here with love: https://github.com/bep/dockerfiles
