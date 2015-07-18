library app_component;

import 'package:react/react.dart';
import 'message_list_component.dart';
import 'footer_component.dart';


class AppComponent extends Component {
//
//  componentDidMount(root) => scrollToBottom();
//  componentDidUpdate(prevProps, prevState, element) => scrollToBottom();
//
//  scrollToBottom() {
//    JsObject jsObject = new JsObject.fromBrowserObject(querySelector(".message-list-component"));
//    int scrollHeight = jsObject['scrollHeight'];
//    jsObject['scrollTop'] = '${scrollHeight}';
//    print("scrollToBottom: ${scrollHeight}");
//  }

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