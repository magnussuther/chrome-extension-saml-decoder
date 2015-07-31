part of magnussuther.chrome_extension_saml_decoder;


enum ActionType {
  addSamlMessage,
  addAllSamlMessages,
  clearAllSamlMessages
}

class Actions {
  Dispatch _dispatcher;

  Actions() {
    _dispatcher = Dispatch.create();
  }

  on(ActionType type, Function callback) {
    _dispatcher.watch(type.toString())
      .listen(callback);
  }

  addSamlMessage(message) {
    _dispatcher.dispatch({
      "message": ActionType.addSamlMessage.toString(),
      "data": message
    });
  }

  addAllSamlMessages(List<SamlMessage> messages) {
    _dispatcher.dispatch({
      "message": ActionType.addAllSamlMessages.toString(),
      "data": messages
    });
  }

  clearAllSamlMessages() {
    window.localStorage['messages'] = "[]";

    _dispatcher.dispatch({
      "message": ActionType.clearAllSamlMessages.toString(),
    });
  }
}
