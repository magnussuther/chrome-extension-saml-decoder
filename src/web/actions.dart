part of magnussuther.chrome_extension_saml_decoder;

class AddMessageAction {
  static String key = "ADD_MESSAGE";
  SamlMessage message;

  AddMessageAction(SamlMessage this.message);
}

class AddAllMessagesAction {
  static String key = "ADD_ALL_MESSAGES";
  List<Map> messages;

  AddAllMessagesAction(List<Map> this.messages);
}