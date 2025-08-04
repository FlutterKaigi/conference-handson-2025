.PHONY: setup

setup:
	fvm flutter config --enable-ios
	fvm flutter config --enable-android
	fvm flutter config --enable-web
	fvm flutter config --no-enable-windows-desktop
	fvm flutter config --no-enable-linux-desktop
	fvm flutter config --no-enable-macos-desktop
	$(MAKE) tools-install
#	$(MAKE) generate

tools-install:
    fvm: flutter pub global activate build_runner

generate:
	fvm flutter pub get
	fvm flutter pub run build_runner build -d

#watch:
#	fvm dart run build_runner watch -d

cache-clean:
	fvm flutter pub cache clean

get:
	fvm flutter pub get

clean:
	fvm flutter clean

run:
	fvm use
	fvm flutter run

unit-test:
	fvm flutter test test/

build-bundle:
	fvm use
	fvm flutter build appbundle --release

#build-ios:
#	fvm use
#	fvm flutter build ios --release
