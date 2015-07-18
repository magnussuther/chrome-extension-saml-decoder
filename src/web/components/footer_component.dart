library footer_component;

import 'package:react/react.dart';

class FooterComponent extends Component {

  render() {
    return (
      div({"className": "footer-container"},
        div({"className": "well"},
          h4({"className": "panel-title"}, "SAML Message Decoder")
        )
      )
    );
  }
}

var footerComponent = registerComponent(() => new FooterComponent());