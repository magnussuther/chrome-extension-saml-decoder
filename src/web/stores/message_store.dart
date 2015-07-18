library message_store;

import 'package:dispatch/dispatch.dart';
import 'package:xml/xml.dart';

import '../main.dart';
import '../saml_message.dart';
import '../actions.dart';

class MessageStore {
  var _dispatcher;
  List<SamlMessage> messages;

  MessageStore() {
    messages = new List<SamlMessage>();
    _dispatcher = Dispatch.create();

    // This store reacts to these types of actions only
    actionDispatcher.watch(AddMessageAction.key)
      .listen((action) => addMessageFromAction(action["data"]));

    actionDispatcher.watch(AddAllMessagesAction.key)
      .listen((action) => addAllMessagesFromAction(action["data"]));
  }

  SamlMessage _prettifyMessage(SamlMessage message) {
    message.content = parse(message.content).toXmlString(pretty: true);
    return message;
  }

  addAllMessagesFromAction(AddAllMessagesAction action) {
    List<SamlMessage> list = action.messages.map((Map m) => new SamlMessage(m["time"], m["parameter"], m["content"]));
    list = list.map((SamlMessage m) => _prettifyMessage(m));

    messages.addAll(list);

    // Sort the messages by time of arrival, ascending
    messages.sort((SamlMessage a, SamlMessage b) => compareMessageTimestamps(a, b));

    // Notify all listening Components that this store has changed
    _dispatcher.dispatch({});
  }

  addMessageFromAction(AddMessageAction action) {
    var message = action.message;

    // Fix the indentation of the message before adding it
    message = _prettifyMessage(message);
    messages.add(message);

    // Sort the messages by time of arrival, ascending
    messages.sort((SamlMessage a, SamlMessage b) => compareMessageTimestamps(a, b));

    // Notify all listening Components that this store has changed
    _dispatcher.dispatch({});
  }

  int compareMessageTimestamps(SamlMessage a, SamlMessage b) {
    DateTime aTime = DateTime.parse(a.time);
    DateTime bTime = DateTime.parse(b.time);
    return bTime.compareTo(aTime);
  }

  Dispatch getDispatcher() {
    return _dispatcher;
  }
}