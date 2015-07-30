library magnussuther.chrome_extension_saml_decoder.background;

import 'dart:html';
import 'dart:convert';
import 'dart:js';
import '../main.dart';

void main() {
  // Reset the current state of the localStorage each time the extension starts.
  window.localStorage["messages"] = JSON.encode([]);

  // Start listening for SAML messages.
  // We do this in JS, since the 'chrome' pub package has bugs and is not compatible with the actual
  // Chrome WebRequest API at the moment.https://github.com/dart-gde/chrome.dart/issues/213
  // Make sure to attach the event listener before the listener actually starts.
  context["navigationListenerCallback"] = (data) => onBeforeRequestHandler(data);
  JsFunction f = context["startListener"];
  f.apply(null);
}

onBeforeRequestHandler(JsObject data) {
  if (data["method"] == "GET") {
    processSamlRedirectBindingMessage(data);
  }
  else if (data["method"] == "POST") {
    processSamlPostBindingMessage(data);
  }
  else {
    // Ignore (not supported or not our business)
  }
}

storeInLocalStorage(String decoded, String parameter, String binding) {
  List<Map> storedMessages = JSON.decode(window.localStorage["messages"]);

  Map newMessage = new SamlMessage(new DateTime.now().toUtc().toString(), parameter, '''$decoded''', binding).toJson();

  storedMessages.add(newMessage);

  window.localStorage["messages"] = JSON.encode(storedMessages);
}

void processSamlPostBindingMessage(JsObject data) {
  var body = data["requestBody"];
  if (body != null) {
    var formData = body["formData"];

    if (formData != null) {

      var parameter = null;
      if (postParameterExists(formData, "SAMLRequest")) {
        parameter = "SAMLRequest";
      } else if (postParameterExists(formData, "SAMLResponse")) {
        parameter = "SAMLResponse";
      } else {
        return; // Nothing for us to see here
      }

      var messages = formData[parameter];

      String message = messages[0];
      var decoded = window.atob(message);
      storeInLocalStorage(decoded, parameter, "post");
    }
  }
}

postParameterExists(formData, parameter) {
  var messageList = formData[parameter];
  return messageList != null && messageList.length > 0;
}

void processSamlRedirectBindingMessage(JsObject data) {
  var url = data["url"];
  Uri uri = Uri.parse(url);

  if (uri.hasQuery) {

    var queryKey = null;
    if (uri.queryParameters.containsKey("SAMLRequest")) {
      queryKey = "SAMLRequest";
    } else if (uri.queryParameters.containsKey("SAMLResponse")) {
      queryKey = "SAMLResponse";
    } else {
      return; // Nothing for us to see here
    }

    var message = uri.queryParameters[queryKey];
    // The request is URL decoded already

    var base64Decoded = window.atob(message);

    // TODO: We should find us a pub package instead of calling JS.
    JsObject pakoInflate = context["pako"];
    var inflatedBytes = pakoInflate.callMethod("inflateRaw", [base64Decoded]);
    var inflated = UTF8.decode(inflatedBytes);

    storeInLocalStorage(inflated, queryKey, "redirect");
  }
}