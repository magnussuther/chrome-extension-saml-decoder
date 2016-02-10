library magnussuther.chrome_extension_saml_decoder;

import 'dart:html';
import 'dart:convert';
import 'dart:js';

import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:w_flux/w_flux.dart';
import 'package:xml/xml.dart';
import 'package:mdl/mdl.dart' as mdl;

part 'saml_message.dart';
part 'actions.dart';
part 'stores/message_store.dart';

part 'components/app_component/app_component.dart';
part 'components/app_component/app_container.dart';

part 'components/footer_component/footer_component.dart';
part 'components/footer_component/footer_container.dart';

part 'components/message_list_component/message_list_component.dart';
part 'components/message_list_component/message_list_container.dart';

part 'components/message_component/message_component.dart';




initialize() {
  mdl.registerMdl();
  mdl.componentFactory().run().then((_) {
  });
}

importFromLocalStorage(MessageActions actions) {
  print("Importing SAML messages from LocalStorage...");
  if (window.localStorage["messages"] != null) {
    List<Map> storedMessages = JSON.decode(window.localStorage["messages"]);
    var samlMessages = storedMessages.map((e) => new SamlMessage.fromJson(e)).toList();

    actions.addAllSamlMessages(samlMessages);
    print("${samlMessages.length} SAML messages imported from LocalStorage");
  }
}

MessageActions messageActions = new MessageActions();
MessageStore messageStore = new MessageStore(messageActions);

void main() {
  print("Main initializing");

  initialize();

  reactClient.setClientConfiguration();

  render(appContainer({"store": messageStore}), querySelector('#app-container'));

    // Import all messages from LocalStorage, that the background page has produced since we last displayed the GUI.
  importFromLocalStorage(messageActions);

  print("Main exiting");
}