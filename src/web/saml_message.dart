part of magnussuther.chrome_extension_saml_decoder;

class SamlMessage {
  String time;
  String parameter;
  String content;
  String binding;

  SamlMessage(String this.time, String this.parameter, String this.content, String this.binding);

  SamlMessage.fromJson(Map<String, String> json) {
    time = json["time"];
    parameter = json["parameter"];
    content = json["content"];
    binding = json["binding"];
  }

  Map toJson() {
    return {
      "time": time,
      "parameter": parameter,
      "content": content,
      "binding": binding
    };
  }

  int compareByTimestamp(SamlMessage other) {
    return DateTime.parse(time).compareTo(DateTime.parse(other.time));
  }
}