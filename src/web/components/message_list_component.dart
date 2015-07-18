library message_list_component;

import 'package:react/react.dart';
import '../main.dart';
import '../saml_message.dart';
import 'message_component.dart';

class MessageListComponent extends Component {
  getInitialState() => {
    "currentItem": messageStore.messages.length,
    "messages": messageStore.messages
  };

  changeState(_e) => setState(getInitialState());

  componentWillMount() => messageStore.getDispatcher().listen(changeState);
  componentWillUnmount() => messageStore.getDispatcher().unlisten(changeState);

  renderMessages(SamlMessage message) {
    return (
        messageComponent({"itemIndex": this.state["currentItem"]--, "message": message, "key": message.time })
    );
  }

  render() {
    return (
      div({"className": "message-list-component"},
        this.state["messages"].map(renderMessages)
      )
    );
  }
}

var messageListComponent = registerComponent(() => new MessageListComponent());