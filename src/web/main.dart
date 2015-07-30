part of magnussuther.chrome_extension_saml_decoder;

MessageStore messageStore;
Actions actions;

initialize() {
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
  initialize();

  reactClient.setClientConfiguration();

  render(appComponent({}), querySelector('#app-container'));

  // Import all messages from LocalStorage, that the background page has produced since we last displayed the GUI.
  importFromLocalStorage();
}