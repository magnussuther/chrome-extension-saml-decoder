part of magnussuther.chrome_extension_saml_decoder;

class MessageListContainer extends FluxComponent<MessageActions, MessageStore>  {

  shouldComponentUpdate(nextProps, nextState) {
    return true;
  }

  render() {
    print("MessageListContainer renders");

    return (
        messageListComponent({"store": store, "key": "message-list-component", "messages": messageStore.messages})
    );
  }
}

var messageListContainer = registerComponent(() => new MessageListContainer());