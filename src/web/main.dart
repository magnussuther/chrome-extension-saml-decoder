import 'dart:html';
import 'dart:convert';

import 'package:dispatch/dispatch.dart';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';

import 'stores/message_store.dart';
import 'components/app_component.dart';
import 'actions.dart';

var actionDispatcher;
MessageStore messageStore;

void main() {
  actionDispatcher = Dispatch.create();

  messageStore = new MessageStore();

  reactClient.setClientConfiguration();

  render(appComponent({}), querySelector('#app-container'));

  // Import all messages from LocalStorage, that the background page has produced since we last displayed the GUI.
  if (window.localStorage["messages"] != null) {
    List<Map> storedMessages = JSON.decode(window.localStorage["messages"]);
    actionDispatcher.dispatch({
      "message": AddAllMessagesAction.key,
      "data": new AddAllMessagesAction(storedMessages)
    });
  }

//  actionDispatcher.dispatch({
//    "message": AddMessageAction.key,
//    "data": new AddMessageAction(new SamlMessage(new DateTime.now().toUtc().toString(), "SamlRequest", '''<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" ID="_bec424fa5103428909a30ff1e31168327f79474984" Version="2.0" IssueInstant="2007-12-10T11:39:34Z" ForceAuthn="false" IsPassive="false" ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" AssertionConsumerServiceURL="http://moodle.bridge.feide.no/simplesaml/saml2/sp/AssertionConsumerService.php">
//    <saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
//    urn:mace:feide.no:services:no.feide.moodle
//    </saml:Issuer>
//    <samlp:NameIDPolicy xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:persistent" SPNameQualifier="moodle.bridge.feide.no" AllowCreate="true" />
//    <samlp:RequestedAuthnContext xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Comparison="exact">
//    <saml:AuthnContextClassRef xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
//    urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport
//    </saml:AuthnContextClassRef>
//    </samlp:RequestedAuthnContext>
//    </samlp:AuthnRequest>'''))
//  });
//
//  actionDispatcher.dispatch({
//    "message": AddMessageAction.key,
//    "data": new AddMessageAction(new SamlMessage(new DateTime.now().toUtc().toString(), "SamlRequest", '''<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" ID="_bec424fa5103428909a30ff1e31168327f79474984" Version="2.0" IssueInstant="2007-12-10T11:39:34Z" ForceAuthn="false" IsPassive="false" ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" AssertionConsumerServiceURL="http://moodle.bridge.feide.no/simplesaml/saml2/sp/AssertionConsumerService.php">
//    <saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
//    urn:mace:feide.no:services:no.feide.moodle
//    </saml:Issuer>
//    <samlp:NameIDPolicy xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:persistent" SPNameQualifier="moodle.bridge.feide.no" AllowCreate="true" />
//    <samlp:RequestedAuthnContext xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Comparison="exact">
//    <saml:AuthnContextClassRef xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
//    urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport
//    </saml:AuthnContextClassRef>
//    </samlp:RequestedAuthnContext>
//    </samlp:AuthnRequest>'''))
//  });
//
//  actionDispatcher.dispatch({
//    "message": AddMessageAction.key,
//    "data": new AddMessageAction(new SamlMessage(new DateTime.now().toUtc().toString(), "SamlRequest", '''<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" ID="_bec424fa5103428909a30ff1e31168327f79474984" Version="2.0" IssueInstant="2007-12-10T11:39:34Z" ForceAuthn="false" IsPassive="false" ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" AssertionConsumerServiceURL="http://moodle.bridge.feide.no/simplesaml/saml2/sp/AssertionConsumerService.php">
//    <saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
//    urn:mace:feide.no:services:no.feide.moodle
//    </saml:Issuer>
//    <samlp:NameIDPolicy xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:persistent" SPNameQualifier="moodle.bridge.feide.no" AllowCreate="true" />
//    <samlp:RequestedAuthnContext xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Comparison="exact">
//    <saml:AuthnContextClassRef xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
//    urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport
//    </saml:AuthnContextClassRef>
//    </samlp:RequestedAuthnContext>
//    </samlp:AuthnRequest>'''))
//  });
}