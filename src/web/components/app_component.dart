part of magnussuther.chrome_extension_saml_decoder;

class AppComponent extends Component {
  render() {
    return (
      div({"className": "app-component-container"},[
        messageListComponent({"key": "message-list-component"}),
        footerComponent({"key": "footer-component"})
      ])
    );
  }
}

var appComponent = registerComponent(() => new AppComponent());