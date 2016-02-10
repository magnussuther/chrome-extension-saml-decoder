part of magnussuther.chrome_extension_saml_decoder;

class AppComponent extends FluxComponent<MessageActions, MessageStore>  {
  render() {
    print("AppComponent renders");

    return (
      div({"className": "app-component-container"},[
        messageListContainer({"store": store, "key": "message-list-container"}),
        footerContainer({"store": store, "key": "footer-container"})
      ])
    );
  }
}

var appComponent = registerComponent(() => new AppComponent());