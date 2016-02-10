import 'dart:html';
import 'dart:async';

import 'package:test/test.dart';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react_test_utils.dart' as reactTestUtils;

import '../web/main.dart' as app;


Future sleep() {
  return new Future.delayed(const Duration(seconds: 1));
}

void main() {
  reactClient.setClientConfiguration();


  setUp(() {
    window.localStorage['messages'] = "[]";
    app.initialize();

    app.messageActions = new app.MessageActions();
    app.messageStore = new app.MessageStore(app.messageActions);

    app.importFromLocalStorage(app.messageActions);
  });

  test("When localStorage hasn't been initialized, a welcome notice is displayed instead of a list", () {
    var appComponent = reactTestUtils.renderIntoDocument(app.appComponent({"store": app.messageStore}));

    var hiElement = reactTestUtils.findRenderedDOMComponentWithClass(
        appComponent, 'welcome-notice-hi');

    var hiNode = reactTestUtils.getDomNode(hiElement);

    expect(hiNode.text, equals('Hi!'));
  });

  test("When a single new message is added to the empty list of messages, this message gets syntax highlighted", () async {
    var appComponent = reactTestUtils.renderIntoDocument(app.appComponent({"store": app.messageStore}));

    var timestamp = new DateTime.now().toUtc().toString();

    await app.messageActions.addSamlMessage.call(
        new app.SamlMessage()
        ..time = timestamp
        ..parameter = 'SAMLRequest'
        ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
        ..binding = 'redirect'
    );

    // Wait and pray that the Components have redrawn
    await sleep();

    var messageObject = reactTestUtils.findRenderedDOMComponentWithClass(
        appComponent, 'samlmessage');
    var messageElement = reactTestUtils.getDomNode(messageObject);
    var panelBodies = messageElement.getElementsByClassName('mdl-panel__content');

    expect(panelBodies[0].innerHtml, contains("hljs-tag"));
    expect(panelBodies[0].innerHtml, contains("hljs-title"));
  });

  test('''When a single new message is added to the empty list of messages, the 'CLEAR ALL' button
  in the footer gets rendered''', () async {
    var appComponent = reactTestUtils.renderIntoDocument(app.appComponent({"store": app.messageStore}));

    var timestamp = new DateTime.now().toUtc().toString();

    await app.messageActions.addSamlMessage(new app.SamlMessage()
      ..time = timestamp
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect');

    // Wait and pray that the Components have redrawn
    await sleep();

    var linkObject = reactTestUtils.findRenderedDOMComponentWithClass(
        appComponent, 'clear-all');
    var linkElement = reactTestUtils.getDomNode(linkObject);

    expect(linkObject, isNotNull);
    expect(linkElement.text, equals('CLEAR ALL'));
  });

  test("An action to add a single new message triggers a render of that message", () async {
    var appComponent = reactTestUtils.renderIntoDocument(app.appComponent({"store": app.messageStore}));

    var timestamp = new DateTime.now().toUtc().toString();

    await app.messageActions.addSamlMessage(new app.SamlMessage()
      ..time = timestamp
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect');

    // Wait and pray that the Components have redrawn
    await sleep();

    var messageObject = reactTestUtils.findRenderedDOMComponentWithClass(
        appComponent, 'samlmessage');
    var messageElement = reactTestUtils.getDomNode(messageObject);
    var panelHeadings = messageElement.getElementsByClassName('mdl-panel__heading');
    var expectedHeading = "# 1 - SAMLRequest via redirect binding, at ${timestamp} (UTC)";
    var panelBodies = messageElement.getElementsByClassName('mdl-panel__content');

    expect(panelHeadings.length, equals(1));
    expect(panelHeadings[0].text, equals(expectedHeading));
    expect(panelBodies.length, equals(1));
    expect(panelBodies[0].text, contains('<AuthnRequest>'));
  });

  test("An action to add a bunch of new messages triggers a render of those messages", () async {
    var appComponent = reactTestUtils.renderIntoDocument(app.appComponent({"store": app.messageStore}));

    var timestamp1 = "2015-07-26 17:26:14.789Z";
    var samlMessage1 = new app.SamlMessage()
      ..time = timestamp1
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect';

    var timestamp2 = "2015-07-26 17:26:15.789Z";
    var samlMessage2 = new app.SamlMessage()
      ..time = timestamp2
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect';

    var timestamp3 = "2015-07-26 17:26:16.789Z";
    var samlMessage3 = new app.SamlMessage()
      ..time = timestamp3
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect';

    await app.messageActions.addAllSamlMessages([samlMessage1, samlMessage2, samlMessage3]);

    // Wait and pray that the Components have redrawn
    await sleep();

    var messageObjects = reactTestUtils.scryRenderedDOMComponentsWithClass(
        appComponent, 'samlmessage');

    expect(messageObjects.length, equals(3));
  });

  test('''When multiple messages are listed, they are sorted ascending based on the timestamps, and each message
      get an incrementing ID''', () async {
    var appComponent = reactTestUtils.renderIntoDocument(app.appComponent({"store": app.messageStore}));

    var timestamp1 = "2015-07-26 17:26:16.789Z";
    var samlMessage1 = new app.SamlMessage()
      ..time = timestamp1
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect';
    var expectedHeading1 = "# 3 - SAMLRequest via redirect binding, at ${timestamp1} (UTC)";

    var timestamp2 = "2015-07-26 17:26:15.789Z";
    var samlMessage2 = new app.SamlMessage()
      ..time = timestamp2
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect';
    var expectedHeading2 = "# 2 - SAMLRequest via redirect binding, at ${timestamp2} (UTC)";

    var timestamp3 = "2015-07-26 17:26:14.789Z";
    var samlMessage3 = new app.SamlMessage()
      ..time = timestamp3
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest><Issuer></Issuer></AuthnRequest>'
      ..binding = 'redirect';
    var expectedHeading3 = "# 1 - SAMLRequest via redirect binding, at ${timestamp3} (UTC)";

    await app.messageActions.addAllSamlMessages([samlMessage1, samlMessage2, samlMessage3]);

    // Wait and pray that the Components have redrawn
    await sleep();

    var messageObjects = reactTestUtils.scryRenderedDOMComponentsWithClass(
        appComponent, 'samlmessage');

    var messageElements = messageObjects.map((e) => reactTestUtils.getDomNode(e));

    Element first = messageElements.elementAt(0);
    var firstHeading = first.getElementsByClassName('mdl-panel__heading').elementAt(0);
    expect(firstHeading.text, equals(expectedHeading1));

    Element second = messageElements.elementAt(1);
    var secondHeading = second.getElementsByClassName('mdl-panel__heading').elementAt(0);
    expect(secondHeading.text, equals(expectedHeading2));

    Element third = messageElements.elementAt(2);
    var thirdHeading = third.getElementsByClassName('mdl-panel__heading').elementAt(0);
    expect(thirdHeading.text, equals(expectedHeading3));
  });

  test("A message renders with only those 'additional parameters' that it contains", () async {
    var appComponent = reactTestUtils.renderIntoDocument(app.appComponent({"store": app.messageStore}));

    List<Future> futures = new List<Future>();

    // Should only render the relayState
    futures.add(app.messageActions.addSamlMessage(new app.SamlMessage()
      ..time = new DateTime.now().toUtc().toString()
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest></AuthnRequest>'
      ..binding = 'redirect'
      ..relayState = "f8f2cf32-0535-40e7-b37b-fd85d1ea3480"));

    // Should only render the SigAlg
    futures.add(app.messageActions.addSamlMessage(new app.SamlMessage()
      ..time = new DateTime.now().toUtc().toString()
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest></AuthnRequest>'
      ..binding = 'redirect'
      ..sigAlg = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"));

    // Should only render the Signature
    futures.add(app.messageActions.addSamlMessage(new app.SamlMessage()
      ..time = new DateTime.now().toUtc().toString()
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest></AuthnRequest>'
      ..binding = 'redirect'
      ..signature = "oJSPcZNvelg09kFZvQ2hoykJCNl..."));

    // Should render all parameters
    futures.add(app.messageActions.addSamlMessage(new app.SamlMessage()
      ..time = new DateTime.now().toUtc().toString()
      ..parameter = 'SAMLRequest'
      ..content = '<AuthnRequest></AuthnRequest>'
      ..binding = 'redirect'
      ..signature = "oJSPcZNvelg09kFZvQ2hoykJCNl..."
      ..relayState = "f8f2cf32-0535-40e7-b37b-fd85d1ea3480"
      ..sigAlg = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"));

    await Future.wait(futures);

    // Wait and pray that the Components have redrawn
    await sleep();

    var messageObjects = reactTestUtils.scryRenderedDOMComponentsWithClass(appComponent, 'samlmessage');
    var messageElements = messageObjects.map((e) => reactTestUtils.getDomNode(e));

    // Note that the rendered list is sorted ascending. The first message added ends up last in the list.

    Element first = messageElements.elementAt(3);
    Element firstAdditionalInformation = first.getElementsByClassName('additional-information').elementAt(0);
    expect(firstAdditionalInformation.outerHtml.contains('SigAlg'), isFalse);
    expect(firstAdditionalInformation.outerHtml.contains('Signature'), isFalse);
    expect(firstAdditionalInformation.outerHtml.contains('RelayState'), isTrue);
    expect(firstAdditionalInformation.outerHtml.contains('f8f2cf32-0535-40e7-b37b-fd85d1ea3480'), isTrue);

    Element second = messageElements.elementAt(2);
    Element secondAdditionalInformation = second.getElementsByClassName('additional-information').elementAt(0);
    expect(secondAdditionalInformation.outerHtml.contains('SigAlg'), isTrue);
    expect(secondAdditionalInformation.outerHtml.contains('Signature'), isFalse);
    expect(secondAdditionalInformation.outerHtml.contains('RelayState'), isFalse);
    expect(secondAdditionalInformation.outerHtml.contains('http://www.w3.org/2000/09/xmldsig#rsa-sha1'), isTrue);

    Element third = messageElements.elementAt(1);
    Element thirdAdditionalInformation = third.getElementsByClassName('additional-information').elementAt(0);
    expect(thirdAdditionalInformation.outerHtml.contains('SigAlg'), isFalse);
    expect(thirdAdditionalInformation.outerHtml.contains('Signature'), isTrue);
    expect(thirdAdditionalInformation.outerHtml.contains('RelayState'), isFalse);
    expect(thirdAdditionalInformation.outerHtml.contains('oJSPcZNvelg09kFZvQ2hoykJCNl...'), isTrue);

    Element forth = messageElements.elementAt(0);
    Element forthAdditionalInformation = forth.getElementsByClassName('additional-information').elementAt(0);
    expect(forthAdditionalInformation.outerHtml.contains('SigAlg'), isTrue);
    expect(forthAdditionalInformation.outerHtml.contains('Signature'), isTrue);
    expect(forthAdditionalInformation.outerHtml.contains('RelayState'), isTrue);
    expect(firstAdditionalInformation.outerHtml.contains('f8f2cf32-0535-40e7-b37b-fd85d1ea3480'), isTrue);
    expect(secondAdditionalInformation.outerHtml.contains('http://www.w3.org/2000/09/xmldsig#rsa-sha1'), isTrue);
    expect(forthAdditionalInformation.outerHtml.contains('oJSPcZNvelg09kFZvQ2hoykJCNl...'), isTrue);
  });
}