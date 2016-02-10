part of magnussuther.chrome_extension_saml_decoder;

class FooterComponent extends FluxComponent<MessageActions, MessageStore>  {

  shouldComponentUpdate(nextProps, nextState) {
    return true;
  }

  _renderClearAllButton() {
    if(this.props["hasMessages"]) {
      return (
          a({"className": "clear-all", "onClick": (e) => messageActions.clearAllSamlMessages()}, "CLEAR ALL")
      );
    }
  }

  render() {
    print("FooterComponent renders");

    return (
      div({"className": "footer-container"},
        footer({"className": "mdl-mini-footer"},[
          div({"className": "mdl-mini-footer__left-section", "key": "footer-container-section-left"},
            div({"className": "mdl-logo"}, "SAML Message Decoder")
          ),
          div({"className": "mdl-mini-footer__right-section", "key": "footer-container-section-right"},
            ul({"className": "mdl-mini-footer__link-list"}, [
              li({"key": "footer-container-section-right-link1"},
                _renderClearAllButton()
              )
            ])
          )
        ])
      )
    );
  }
}

var footerComponent = registerComponent(() => new FooterComponent());