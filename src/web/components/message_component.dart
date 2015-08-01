part of magnussuther.chrome_extension_saml_decoder;

class MessageComponent extends Component {
  componentDidMount(root) => highlight();
  componentDidUpdate(prevProps, prevState, element) => highlight();

  highlight() {
    var element = getDOMNode();
    var codeElement = element.querySelector('pre code');
    JsObject highlightJs = context["hljs"];
    highlightJs.callMethod("highlightBlock", [codeElement]);
  }

  _renderRelayState(var relayState) {
    return (
        div({}, [
          dt({}, "RelayState"),
          dd({}, relayState)
        ])
    );
  }

  _renderSigAlg(var sigAlg) {
    return (
        div({}, [
          dt({}, "SigAlg"),
          dd({}, sigAlg)
        ])
    );
  }

  _renderSignature(var signature) {
    return (
      div({}, [
        dt({}, "Signature"),
        dd({}, signature)
      ])
    );
  }

  _renderAdditionalInformation(SamlMessage message, var itemIndex) {
    return (
      dl({"className": "additional-information", "key": "panel-body-additional-${itemIndex}"}, [
        message.relayState != null ? _renderRelayState(message.relayState) : null,
        message.sigAlg != null ? _renderSigAlg(message.sigAlg) : null,
        message.signature != null ? _renderSignature(message.signature) : null,
      ])
    );
  }

  renderMessage(SamlMessage message, int itemIndex) {
    return (
      div({"className": "panel panel-default samlmessage"}, [
        div({"className": "panel-heading", "key": "panel-heading-${itemIndex}"},
        "# ${itemIndex} - ${message.parameter} via ${message.binding} binding, at ${message.time} (UTC)"
        ),
        div({"className": "panel-body", "key": "panel-body-${itemIndex}"}, [
          pre({"key": "panel-body-content-${itemIndex}"},
            code({"className": "xml"}, "${message.content}")
          ),
          h6({}, "Related parameters"),
          _renderAdditionalInformation(message, itemIndex)
        ])
      ])
    );
  }

  render() {
    return (
      renderMessage(this.props["message"], this.props["itemIndex"])
    );
  }
}

var messageComponent = registerComponent(() => new MessageComponent());