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

  _renderRelayState(relayState, itemIndex) {
    return (
        div({"key": "message-panel-body-additional-relaystate-${itemIndex}"}, [
          dt({"key": "message-panel-body-additional-relaystate-dt-${itemIndex}"}, "RelayState"),
          dd({"key": "message-panel-body-additional-relaystate-dd-${itemIndex}"}, relayState)
        ])
    );
  }

  _renderSigAlg(sigAlg, itemIndex) {
    return (
        div({"key": "message-panel-body-additional-sigalg-${itemIndex}"}, [
          dt({"key": "message-panel-body-additional-sigalg-dt-${itemIndex}"}, "SigAlg"),
          dd({"key": "message-panel-body-additional-sigalg-dd-${itemIndex}"}, sigAlg)
        ])
    );
  }

  _renderSignature(signature, itemIndex) {
    return (
      div({"key": "message-panel-body-additional-signature-${itemIndex}"}, [
        dt({"key": "message-panel-body-additional-signature-dt-${itemIndex}"}, "Signature"),
        dd({"key": "message-panel-body-additional-signature-dd-${itemIndex}"}, signature)
      ])
    );
  }

  _renderAdditionalInformation(SamlMessage message, itemIndex) {
    return (
      dl({"className": "additional-information", "key": "message-panel-body-parameters-container-${itemIndex}"}, [
        message.relayState != null ? _renderRelayState(message.relayState, itemIndex) : null,
        message.sigAlg != null ? _renderSigAlg(message.sigAlg, itemIndex) : null,
        message.signature != null ? _renderSignature(message.signature, itemIndex) : null,
      ])
    );
  }

  renderMessage(SamlMessage message, int itemIndex) {
    return (
      div({"className": "panel panel-default samlmessage"}, [
        div({"className": "panel-heading", "key": "message-panel-heading-${itemIndex}"},
        "# ${itemIndex} - ${message.parameter} via ${message.binding} binding, at ${message.time} (UTC)"
        ),
        div({"className": "panel-body", "key": "message-panel-body-${itemIndex}"}, [
          pre({"key": "message-panel-body-content-${itemIndex}"},
            code({"className": "xml"}, "${message.content}")
          ),
          h6({"key": "message-panel-body-parameters-heading-${itemIndex}"}, "Related parameters"),
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