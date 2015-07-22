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

  renderMessage(SamlMessage message, int itemIndex) {
    return (
      div({"className": "panel panel-default samlmessage"},[
        div({"className": "panel-heading", "key": "panel-heading-${itemIndex}"},
        "# ${itemIndex} - ${message.parameter} via ${message.binding} binding, at ${message.time} (UTC)"
        ),
        div({"className": "panel-body", "key": "panel-body-${itemIndex}"},
          pre({},
            code({"className": "xml"}, "${message.content}")
          )
        )
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