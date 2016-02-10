part of magnussuther.chrome_extension_saml_decoder;

class FooterContainer extends FluxComponent<MessageActions, MessageStore>  {
  render() {
    print("FooterContainer renders");

    return (
        footerComponent({"store": store, "key": "footer-component", "hasMessages": messageStore.hasMessages})
    );
  }
}

var footerContainer = registerComponent(() => new FooterContainer());