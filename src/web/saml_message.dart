part of magnussuther.chrome_extension_saml_decoder;

class SamlMessage {
  String time;
  String parameter;
  String content;
  String binding;
  String relayState;
  String sigAlg;
  String signature;

  // Constructor
  SamlMessage();

  SamlMessage.fromJson(Map<String, String> json) {
    time = json["time"];
    parameter = json["parameter"];
    content = json["content"];
    binding = json["binding"];
    relayState = json["relayState"];
    sigAlg = json["sigAlg"];
    signature = json["signature"];
  }

  Map toJson() {
    return {
      "time": time,
      "parameter": parameter,
      "content": content,
      "binding": binding,
      "relayState": relayState,
      "sigAlg": sigAlg,
      "signature": signature
    };
  }

  int compareByTimestamp(SamlMessage other) {
    return DateTime.parse(time).compareTo(DateTime.parse(other.time));
  }
}