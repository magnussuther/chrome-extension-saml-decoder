part of magnussuther.chrome_extension_saml_decoder;

class AppContainer extends FluxComponent<MessageActions, MessageStore>  {
  render() {
    print("FooterComponent renders");

    return (
      appComponent({"store": store})
    );
  }
}

var appContainer = registerComponent(() => new AppContainer());