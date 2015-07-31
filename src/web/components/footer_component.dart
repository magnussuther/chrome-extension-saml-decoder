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
        div({"className": "well"},
          div({"className": "container-fluid"},
            div({"className": "row"}, [
              div({"className": "col-xs-5", "key": "footer-title-container"},
                span({"className": "panel-title"}, "SAML Message Decoder")
              ),
              div({"className": "col-xs-7", "key": "footer-buttons-container"},
                span({"className": "pull-right"},
                  _renderClearAllButton()
                )
              ),
            ])
          )
        )
      )
    );
  }
}

var footerComponent = registerComponent(() => new FooterComponent());