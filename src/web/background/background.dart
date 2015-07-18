library background;

import 'dart:js';
import 'dart:convert';
import 'dart:html';

void main() {
  print("background starting");
  // Start listening for SAML messages.

  window.localStorage["messages"] = JSON.encode([]);

  context["navigationListenerCallback"] = (data) => onBeforeRequestHandler(data);
  JsFunction f = context["startListener"];
  f.apply(null);
}

onBeforeRequestHandler(Map data) {
  if (data["method"] == "GET") {
    processGETMessage(data);
  }
  else if (data["method"] == "POST") {
    processPOSTMessage(data);
  }
  else {
    // Ignore
  }
}

StoreInLocalStorage(String decoded, String parameter) {
  List<Map> storedMessages = JSON.decode(window.localStorage["messages"]);

  Map newMessage = {
    "time": new DateTime.now().toUtc().toString(),
    "parameter": parameter,
    "content": '''$decoded'''
  };

  storedMessages.add(newMessage);

  window.localStorage["messages"] = JSON.encode(storedMessages);
}

void processPOSTMessage(Map data) {
  Map body = data["requestBody"];
  if (body != null) {
    Map formData = body["formData"];

    if (formData != null) {
      List<String> responseList = formData["SAMLResponse"];

      if (responseList != null && responseList.length > 0) {
        String response = responseList[0];
        print("RESPONSE: $response");

        var decoded = window.atob(response);
        print("DECODED RESPONSE: $decoded");

        StoreInLocalStorage(decoded, "SAMLResponse");
      }
    }
  }
}

void processGETMessage(Map data) {
  var url = data["url"];
  Uri uri = Uri.parse(url);
  if (uri.hasQuery && uri.queryParameters.containsKey("SAMLRequest")) {
    var request = uri.queryParameters["SAMLRequest"];
    print("REQUEST: $request");
    // Its URL decoded already

    // Base64-decode
    var decoded = window.atob(request);
    print("DECODED: $decoded");

    // Inflate

//    List<int> bytes = UTF8.encode(decoded);
//    print("BYTES:");
//    print(bytes);
//    GZipDecoder d = new GZipDecoder();
//    List<int> inflated = d.decodeBytes(bytes);
//
//    print("DEFLATED: $inflated");
  }
}

onNavigatedHandler(e) {
  print("Got data!");
  print(e);
}

onRequestHandler(e) {
  print("Got data!");
  print(e);
}

onCompletedHandler(data) {
  print("Got data!");
  print(data);
}
