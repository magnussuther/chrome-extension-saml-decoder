part of magnussuther.chrome_extension_saml_decoder;

MessageStore messageStore;
Actions actions;

void main() {
  actions = new Actions();

  messageStore = new MessageStore();

  reactClient.setClientConfiguration();

  render(appComponent({}), querySelector('#app-container'));

  // Import all messages from LocalStorage, that the background page has produced since we last displayed the GUI.
  if (window.localStorage["messages"] != null) {
    List<Map> storedMessages = JSON.decode(window.localStorage["messages"]);
    var samlMessages = storedMessages.map((e) => new SamlMessage.fromJson(e)).toList();
    actions.addAllSamlMessages(samlMessages);
  }
}