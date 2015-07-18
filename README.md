# chrome-extension-saml-decoder

**This extension is not production-ready. It is experimental only.**

## Development

1) Get the development machine up and running. You have Virtualbox and Vagrant already installed, right?
```
vagrant up
```
2) Start WebStorm and walk through its initial setup steps (you might as well select the Evaulation license, since this is a temporary machine)
```
./WebStorm-141.1550/bin/webstorm.sh
```
3) Open the project at:
```
/vagrant/src
```
4) Open Dart settings. Enter the following:
```
Dart SDK path: /usr/lib/dart
```
```
Dartium path: /home/vagrant/dartium-lucid64-full-stable-1.11.1.0/chrome
```
5) The project should already be loaded. Now open the pubspec.yaml in the editor and hit "Get Dependencies". 
  
