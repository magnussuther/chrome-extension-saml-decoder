library actions;

import 'saml_message.dart';

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