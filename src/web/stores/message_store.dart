part of magnussuther.chrome_extension_saml_decoder;

class MessageStore {
  var _dispatcher;
  List<SamlMessage> messages;

  MessageStore() {
    messages = new List<SamlMessage>();
    _dispatcher = Dispatch.create();

    // This store reacts to these types of actions only
    actions.on(ActionType.addSamlMessage, (action) => _addMessageFromAction(action));
    actions.on(ActionType.addAllSamlMessages, (action) => _addAllMessagesFromAction(action));
  }

  SamlMessage _prettifyMessage(SamlMessage message) {
    message.content = parse(message.content).toXmlString(pretty: true);
    return message;
  }

  _addAllMessagesFromAction(action) {
    var list = action["data"].map((m) => _prettifyMessage(m));

    messages.addAll(list);

    // Sort the messages by time of arrival, ascending
    messages.sort((a, b) => -a.compareByTimestamp(b));

    // Notify all listening Components that this store has changed
    _dispatcher.dispatch({});
  }

  _addMessageFromAction(action) {
    // Fix the indentation of the message before adding it
    var message = _prettifyMessage(action["data"]);
    messages.add(message);

    // Sort the messages by time of arrival, ascending
    messages.sort((a, b) => -a.compareByTimestamp(b));

    // Notify all listening Components that this store has changed
    _dispatcher.dispatch({});
  }

  Dispatch getDispatcher() {
    return _dispatcher;
  }
}