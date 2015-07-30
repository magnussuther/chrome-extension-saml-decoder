part of magnussuther.chrome_extension_saml_decoder;

class MessageListComponent extends Component {
  getInitialState() => {
    "currentItem": messageStore.messages.length,
    "messages": messageStore.messages
  };

  changeState(_e) => setState(getInitialState());

  componentWillMount() => messageStore.getDispatcher().listen(changeState);
  componentWillUnmount() => messageStore.getDispatcher().unlisten(changeState);

  _renderSingleMessage(SamlMessage message) {
    // TODO: We use message.time as a key. So if two messages arrive at the same timestamp, only one
    // message will get rendered.
    return (
        messageComponent({"itemIndex": this.state["currentItem"]--, "message": message, "key": message.time })
    );
  }

  render() {
    return (
      div({"className": "message-list-component"},
        _renderMessages(this.state["messages"])
      )
    );
  }

  _renderMessages(messages) {
    if (messages.length != 0) {
      return messages.map((message) => _renderSingleMessage(message));
    } else {
      return _renderNotice();
    }
  }

  _renderNotice() {
    return (
      div({"className": "welcome-notice"}, [
        h1({"className": "welcome-notice-hi", "key": "welcome-notice-hi"}, "Hi!"),
        p({"className": "welcome-notice-msg", "key": "welcome-notice-msg"}, '''There are no SAML messages to display yet. As soon as such messages are
          collected they will be displayed here.''')
      ])
    );
  }
}

var messageListComponent = registerComponent(() => new MessageListComponent());