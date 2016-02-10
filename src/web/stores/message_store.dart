part of magnussuther.chrome_extension_saml_decoder;

class MessageStore extends Store {

  List<SamlMessage> _messages;
  List<SamlMessage> get messages => _messages;
  bool get hasMessages => _messages.isNotEmpty;
  int get numberOfMessages => _messages.length;
  SamlMessage messageAtIndex(i) => _messages.elementAt(i);

  MessageActions _actions;

  MessageStore(MessageActions this._actions) {
    _messages = new List<SamlMessage>();

    // This store listens to these actions
    _actions.addSamlMessage.listen(_addMessageFromAction);
    _actions.addAllSamlMessages.listen(_addAllMessagesFromAction);
    _actions.clearAllSamlMessages.listen(_clearAllMessages);
  }

  _clearAllMessages(_) {
    print("_clearAllMessages() entered");
    window.localStorage['messages'] = "[]";
    _messages.clear();

    trigger();
  }

  _addAllMessagesFromAction(payload) {
    print("_addAllMessagesFromAction() entered");
    var list = payload.map((m) => _prettifyMessage(m));

    _messages.addAll(list);

    // Sort the messages by time of arrival, ascending
    _messages.sort((a, b) => -a.compareByTimestamp(b));

    print("_addAllMessagesFromAction(): ${_messages.length} added");

    trigger();
  }

  _addMessageFromAction(payload) {
    print("_addMessageFromAction() entered");
    // Fix the indentation of the message before adding it
    var message = _prettifyMessage(payload);
    _messages.add(message);

    // Sort the messages by time of arrival, ascending
    _messages.sort((a, b) => -a.compareByTimestamp(b));

    trigger();
  }

  SamlMessage _prettifyMessage(SamlMessage message) {
    print("_prettifyMessage() entered");
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
}