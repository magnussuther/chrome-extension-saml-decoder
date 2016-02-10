part of magnussuther.chrome_extension_saml_decoder;

class MessageComponent extends FluxComponent<MessageActions, MessageStore>  {
  componentDidMount(root) => highlight();
  componentDidUpdate(prevProps, prevState, element) => highlight();

  shouldComponentUpdate(nextProps, nextState) {
    return true;
  }

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

  _renderAdditionalInformation(SamlMessage message) {
    return (
      dl({"className": "additional-information", "key": "message-panel-body-parameters-container-${message.time}"}, [
        message.relayState != null ? _renderRelayState(message.relayState, message.time) : null,
        message.sigAlg != null ? _renderSigAlg(message.sigAlg, message.time) : null,
        message.signature != null ? _renderSignature(message.signature, message.time) : null,
      ])
    );
  }

  renderMessage(SamlMessage message, int displayNumber) {
    return (
      div({"className": "samlmessage"},
        div({"className": "mdl-panel mdl-panel--with-heading mdl-panel--dark mdl-panel--light-text"}, [
          div({"className": "mdl-panel__heading",
            "key": "message-panel-heading-${message.time}"},
          "# ${displayNumber} - ${message.parameter} via ${message.binding} binding, at ${message.time} (UTC)"
          ),
          div({"className": "mdl-panel__content", "key": "message-panel-body-${message.time}"}, [
            pre({"key": "message-panel-body-content-${message.time}"},
              code({"className": "xml"}, "${message.content}")
            ),
            _renderAdditionalInformation(message)
          ])
        ])
      )
    );
  }

  render() {
    print("MessageComponent renders");

    return (
      renderMessage(this.props["message"], this.props["displayNumber"])
    );
  }
}

var messageComponent = registerComponent(() => new MessageComponent());