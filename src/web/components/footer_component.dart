part of magnussuther.chrome_extension_saml_decoder;

class FooterComponent extends Component {

  _changeState(_e) => setState({});

  componentWillMount() => messageStore.getDispatcher().listen(_changeState);
  componentWillUnmount() => messageStore.getDispatcher().unlisten(_changeState);

  _onClearAll() => actions.clearAllSamlMessages();

  _renderClearAllButton() {
    if(messageStore.messages.isNotEmpty) {
      return (
          a({"className": "clear-all", "onClick": (e) => _onClearAll()}, "CLEAR ALL")
      );
    }
  }

  render() {
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