# SAML Message Decoder (Chrome extension)

![Screenshot](https://raw.githubusercontent.com/magnussuther/chrome-extension-saml-decoder/master/src/screenshot-1.png)

This tool helps you debug your SAML based SSO/SLO implementations, by running in the background, collecting SAML messages as they are sent and received by the browser. When something didn't work as expected, just pop up the extension to view the latest SAML messages in cleartext (easily readable XML). This allows you see what happened, and to get an idea of how to solve those weird authorization issues.


## Installation

**Recommended**: <a href="https://chrome.google.com/webstore/detail/saml-message-decoder/mpabchoaimgbdbbjjieoaeiibojelbhm">From the Chrome Web Store</a>

Manually: Download one of the releases and unpack to some directory. Open up **chrome://extensions/** in a tab in Chrome, check the "Developer mode" checkbox and hit "Load unpacked extension". Select the directory containing the manifest.json file.

## Development

1) Get the development machine up and running. You have Virtualbox and Vagrant already installed, right?
```
vagrant up
```
Wait until the GDM login screen appears.

2) Login to the machine. Application menu items are installed for launching WebStorm (preconfigured and ready) and Dartium. 

3) In WebStorm, open up the pubspec.yaml and hit the 'Get Dependencies' text link at the top.

