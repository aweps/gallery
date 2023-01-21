# gallery

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



### Run commands:-

1. To build local container:

docker build -t hello-world .

2. To run local container:

docker run --rm -it -p 8083:8080 hello-world

3. Browse at http://<MACHINE_IP>:8083

4. If using CI (drone/circleci/github), run container from shared registry & then browse:

docker pull registry.hub.docker.com/harmeetg/gallery:<ci_used>
docker run --rm -it -p 8083:8080 registry.hub.docker.com/harmeetg/gallery:<ci_used>






### Flutter
## To build
bash _ops/build.sh

# For IOS
export DART_DEFINES=
export APPLE_ID=
flutter run
