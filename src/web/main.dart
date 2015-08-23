library magnussuther.chrome_extension_saml_decoder;

import 'dart:html';
import 'dart:convert';
import 'dart:js';

import 'package:dispatch/dispatch.dart';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:xml/xml.dart';
import 'package:mdl/mdl.dart' as mdl;

part 'saml_message.dart';
part 'actions.dart';
part 'stores/message_store.dart';
part 'components/app_component.dart';
part 'components/footer_component.dart';
part 'components/message_component.dart';
part 'components/message_list_component.dart';


MessageStore messageStore;
Actions actions;

initialize() {
  mdl.registerMdl();
  mdl.componentFactory().run().then((_) {
  });

  actions = new Actions();
  messageStore = new MessageStore();
}

importFromLocalStorage() {
  if (window.localStorage["messages"] != null) {
    List<Map> storedMessages = JSON.decode(window.localStorage["messages"]);
    var samlMessages = storedMessages.map((e) => new SamlMessage.fromJson(e)).toList();
    actions.addAllSamlMessages(samlMessages);
  }
}

void main() {
  print("Main initializing");

  initialize();

  reactClient.setClientConfiguration();

  render(appComponent({}), querySelector('#app-container'));

  // Import all messages from LocalStorage, that the background page has produced since we last displayed the GUI.
  importFromLocalStorage();

  print("Main exiting");
}