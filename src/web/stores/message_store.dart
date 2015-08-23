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
    actions.on(ActionType.clearAllSamlMessages, (_) => _clearAllMessages());
  }

  _clearAllMessages() {
    messages.clear();

    _dispatcher.dispatch({});
  }

  SamlMessage _prettifyMessage(SamlMessage message) {
    // Ensure correct formatting
    message.content = parse(message.content).toXmlString(pretty: true);

    // Stack the attributes of each opening tag and indent
    message.content = message.content.replaceAllMapped(new RegExp(r'(\s*<\w+)(.*\"\s?\/?>)'), (Match m) {
      var openingTagName = m.group(1);
      var openingTagAttributes = m.group(2).trim();

      // Replace the space between attributes with a newline
      var stackedAttributes = openingTagAttributes.replaceAllMapped(new RegExp(r'(.\")(\s)(\w)'),
          (Match m) => "${m.group(1)}\n${m.group(3)}");

      // Replace all newlines of the stackedAttributes with spaces for indentation
      var spaces = ' '*(openingTagName.replaceFirst(new RegExp(r'\n'), '').length + 1);
      var indentedAttributes = stackedAttributes.replaceAll(new RegExp(r'\n'), "\n${spaces}");

      return "${openingTagName} ${indentedAttributes}";
    });

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