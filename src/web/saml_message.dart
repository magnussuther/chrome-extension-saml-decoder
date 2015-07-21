library saml_message;

class SamlMessage {
  String time;
  String parameter;
  String content;

  SamlMessage(String this.time, String this.parameter, String this.content);

  SamlMessage.fromJson(Map json) {
    time = json["time"];
    parameter = json["parameter"];
    content = json["content"];
  }
}