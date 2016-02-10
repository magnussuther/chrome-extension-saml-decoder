part of magnussuther.chrome_extension_saml_decoder;

class MessageListComponent extends FluxComponent<MessageActions, MessageStore>  {

  shouldComponentUpdate(nextProps, nextState) {
    return true;
  }

  render() {
    print("MessageListComponent renders");

    return (
      div({"className": "message-list-component"},
        _renderMessages(this.props["messages"])
      )
    );
  }

  _renderMessages(List<SamlMessage> messages) {
    if (messages.isEmpty) {
      return (
          div({"className": "welcome-notice"}, [
            h1({"className": "welcome-notice-hi", "key": "welcome-notice-hi"}, "Hi!"),
            p({"className": "welcome-notice-msg", "key": "welcome-notice-msg"}, '''There are no SAML messages to display yet. As soon as such messages are
          collected they will be displayed here.''')
          ])
      );
    } else {
      int initialNumber = messages.length;
      return messages.map((msg) => messageComponent({"store": store, "message": msg, "key": "message-component-${msg.time}", "displayNumber": initialNumber--}));
    }
  }
}

var messageListComponent = registerComponent(() => new MessageListComponent());