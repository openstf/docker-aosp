# docker-aosp

Docker images for Android modules or apps that really need to be built inside the [AOSP](https://source.android.com/) source tree. This allows you to access all private APIs in both Java and C++ land. Doing that is usually a massive pain, and definitely not recommended for any application. Even with these helper images, it's not exactly a walk in the park. Furthermore, by using private APIs you risk your module or app crashing on random devices.

So go away now unless you know what you're doing.

## Features

* Create local AOSP mirrors
* Checkout AOSP branches or tags (from your local mirror or directly)
* Build your own modules inside any checked out AOSP branches
* Supports JDK6 (with openstf/aosp:jdk6) and JDK7 (with openstf/aosp:jdk7)

Available as [openstf/aosp](https://registry.hub.docker.com/u/openstf/aosp/) in the Docker Hub Registry.

## Requirements

* [docker](https://www.docker.com/)
* Vast amounts of disk space. A local mirror currently takes roughly 60GB, and each checked out branch roughly 20-30GB after building your module and its deps.
* Knowledge of AOSP.

## Usage

You might want to checkout the helper script's usage first.

```bash
docker run -ti --rm openstf/aosp:jdk7 /aosp.sh help
```

Please see [here](https://github.com/openstf/minicap/blob/master/jni/minicap-shared/README.md) for a usage example from an actual module.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).

Copyright © CyberAgent, Inc. All Rights Reserved.
