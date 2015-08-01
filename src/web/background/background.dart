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

storeInLocalStorage(SamlMessage message) {
  List<Map> storedMessages = JSON.decode(window.localStorage["messages"]);
  storedMessages.add(message.toJson());
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

      var message = formData[parameter][0];
      var decoded = window.atob(message);

      var samlMessage = new SamlMessage()
        ..time = new DateTime.now().toUtc().toString()
        ..parameter = parameter
        ..binding = "post"
        ..content = decoded;

      if (postParameterExists(formData, "RelayState")) {
        var relayState = formData["RelayState"][0];
        samlMessage.relayState = relayState;
      }

      storeInLocalStorage(samlMessage);
    }
  }
}

postParameterExists(formData, parameter) {
  var values = formData[parameter];
  return values != null && values.length > 0;
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

    var samlMessage = new SamlMessage()
      ..time = new DateTime.now().toUtc().toString()
      ..parameter = queryKey
      ..binding = "redirect"
      ..content = inflated;

    if (uri.queryParameters.containsKey("RelayState")) {
      samlMessage.relayState = uri.queryParameters["RelayState"];
    }

    if (uri.queryParameters.containsKey("SigAlg")) {
      samlMessage.sigAlg = uri.queryParameters["SigAlg"];
    }

    if (uri.queryParameters.containsKey("Signature")) {
      samlMessage.signature = uri.queryParameters["Signature"];
    }

    storeInLocalStorage(samlMessage);
  }
}