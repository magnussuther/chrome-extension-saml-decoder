import 'dart:html';
import 'dart:js';
import 'dart:convert';

import 'package:test/test.dart';
import '../web/background/background.dart' as app;
import '../web/main.dart';

void main() {
  setUp(() {
    window.localStorage['messages'] = "[]";
  });

  test("GET requests not including SAML messages are ignored", () {
    var request = new JsObject.jsify({
      "method": "GET",
      "url": "https://www.example.com?SAML=foo&SAMLRedirect=bar&SAMLMessage=foobar"
    });

    app.onBeforeRequestHandler(request);

    expect(window.localStorage['messages'], equals("[]"));
  });

  test("POST requests not including SAML messages are ignored", () {
    var request = new JsObject.jsify({
      "method": "POST",
      "url": "https://www.example.com",
      "requestBody": {
        "formData": {
          "SAML": "foo",
          "SAMLPost": "bar",
          "SAMLMessage": "foobar"
        }
      }
    });

    app.onBeforeRequestHandler(request);

    expect(window.localStorage['messages'], equals("[]"));
  });

  test('''SAML messages over the redirect binding are added along with the RelayState, SigAlg and
      Signature parameters, if present''', () {

    var request = new JsObject.jsify({
      "method": "GET",
      "url": '''https://www.example.com?SAMLRequest=fZJNT%2BMwEIbvSPwHy%2Fd8tMvHympSdUGISuwS0cCBm%2BtMUwfbk%2FU4zfLvSVM
      q2Euv45n3fd7xzOb%2FrGE78KTRZXwSp5yBU1hpV2f8ubyLfvJ5fn42I2lNKxZd2Lon%2BNsBBTZMOhLjQ8Y77wRK0iSctEAiKLFa%2FH4Q0zgVrc
      eACg1ny9uMy7rCdaM2%2Bs0BWrtppK2UAdeoVjW2ruq1bevGImcvR6zpHmtJ1MHSUZAuDKU0vY7Si2h6VU5%2BiMuJuLx65az4dPql3SHBKaz1oYn
      EfVkWUfG4KkeBna7A%2Fxm6M14j1gZihZazBRH4MODcoKPOgl%2BB32kFz08PGd%2BG0JJIkr7v46%2BhRCaEpod17DCRivYZCkmkd4N28B3wfNyr
      GKP5bws9DS6PKDz%2FMpsl36Tyz%2F%2Fax1jeFmi0emcLY7C%2F8SDD0Z7dobcynHbbV3QVbcZW0TlqQemNhoqzJD%2B4%2Fn8Yw7l8AA%3D%3D

      &Signature=WwBB0aTGJ7G4f%2Fk0ogB3yZhrLCYV4KFV0j5aQF1Thaqll2fItQjj7JU2JDrx1HcQMvn8bpeUyTv%2F2wVihV7OCJpGszthf48Jdo
      4NivU%2F8%2FCr%2Bmjp5Qn6AAeRrfw%2BYx0aBT%2Bdb969zLUs8gkc4x0ld0%2FwC%2B1qA6hityHRC6p46sDfXkXIYNwjgCxLk8MOXIbEwV2q4
      APDdviMH8fQTEQJr%2F8MYOSuSid5FQU0BPxyVXsib4U%2Fg3KUJ3%2BvBaP8IrRBRn9pn8WNXL8tC2Tnj5GqIU4Do78dLnD%2FJyHv6gyBAH6cZo
      UTbb%2BwOIUmY4skuL23zZEk6%2F9vlAMDJ%2Fjm5D%2FL%2Bg%3D%3D

      &SigAlg=http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23rsa-sha1

      &RelayState=739054b8-30f6-4d0d-82f8-30de596a2658'''.replaceAll(new RegExp(r'(\n|\s)'), "")
    });

    app.onBeforeRequestHandler(request);

    var storedMessages = JSON.decode(window.localStorage["messages"])
      .map((msg) => new SamlMessage.fromJson(msg));

    expect(storedMessages.length, equals(1));

    SamlMessage message = storedMessages.elementAt(0);

    expect(message.content, contains('''
    <saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
      google.com
    </saml:Issuer>'''.replaceAll(new RegExp(r'(\n|\s{2,})'), "")));

    expect(message.binding, equals("redirect"));
    expect(message.parameter, equals("SAMLRequest"));
    expect(message.relayState, equals("739054b8-30f6-4d0d-82f8-30de596a2658"));
    expect(message.sigAlg, equals("http://www.w3.org/2000/09/xmldsig#rsa-sha1"));
    expect(message.signature, equals('''WwBB0aTGJ7G4f/k0ogB3yZhrLCYV4KFV0j5aQF1Thaqll2fItQjj7JU2JDrx1HcQMvn8bpeUyTv/2wV
    ihV7OCJpGszthf48Jdo4NivU/8/Cr+mjp5Qn6AAeRrfw+Yx0aBT+db969zLUs8gkc4x0ld0/wC+1qA6hityHRC6p46sDfXkXIYNwjgCxLk8MOXIbEwV
    2q4APDdviMH8fQTEQJr/8MYOSuSid5FQU0BPxyVXsib4U/g3KUJ3+vBaP8IrRBRn9pn8WNXL8tC2Tnj5GqIU4Do78dLnD/JyHv6gyBAH6cZoUTbb+wO
    IUmY4skuL23zZEk6/9vlAMDJ/jm5D/L+g=='''.replaceAll(new RegExp(r'(\n|\s)'), "")));
  });

  test("SAML messages over the post binding are added along with the RelayState parameter", () {
    var request = new JsObject.jsify({
      "method": "POST",
      "url": "https://www.example.com",
      "requestBody": {
        "formData": {
          "SAMLResponse": [
            '''
            PHNhbWxwOlJlc3BvbnNlIHhtbG5zOnNhbWxwPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6
            cHJvdG9jb2wiIElEPSJzMmEwZGEzNTA0YWZmOTc4YjBmOGM4MGY2YTYyYzcxM2M0YTJmNjRjNWIi
            IEluUmVzcG9uc2VUbz0iX2JlYzQyNGZhNTEwMzQyODkwOWEzMGZmMWUzMTE2ODMyN2Y3OTQ3NDk4
            NCIgVmVyc2lvbj0iMi4wIiBJc3N1ZUluc3RhbnQ9IjIwMDctMTItMTBUMTE6Mzk6NDhaIiBEZXN0
            aW5hdGlvbj0iaHR0cDovL21vb2RsZS5icmlkZ2UuZmVpZGUubm8vc2ltcGxlc2FtbC9zYW1sMi9z
            cC9Bc3NlcnRpb25Db25zdW1lclNlcnZpY2UucGhwIj4NCiAgICA8c2FtbDpJc3N1ZXIgeG1sbnM6
            c2FtbD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmFzc2VydGlvbiI+DQogICAgICAgIG1h
            eC5mZWlkZS5ubw0KICAgIDwvc2FtbDpJc3N1ZXI+DQogICAgPHNhbWxwOlN0YXR1cyB4bWxuczpz
            YW1scD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj4NCiAgICAgICAgPHNh
            bWxwOlN0YXR1c0NvZGUgeG1sbnM6c2FtbHA9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpw
            cm90b2NvbCIgVmFsdWU9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpzdGF0dXM6U3VjY2Vz
            cyI+DQogICAgICAgIDwvc2FtbHA6U3RhdHVzQ29kZT4NCiAgICA8L3NhbWxwOlN0YXR1cz4NCiAg
            ICA8c2FtbDpBc3NlcnRpb24geG1sbnM6c2FtbD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4w
            OmFzc2VydGlvbiIgVmVyc2lvbj0iMi4wIiBJRD0iczJiN2FmZThlMjFhMDkxMGQwMjdkZmJjOTRl
            YzRiODYyZTFmYmJkOWFiIiBJc3N1ZUluc3RhbnQ9IjIwMDctMTItMTBUMTE6Mzk6NDhaIj4NCiAg
            ICAgICAgPHNhbWw6SXNzdWVyPg0KICAgICAgICAgICAgbWF4LmZlaWRlLm5vDQogICAgICAgIDwv
            c2FtbDpJc3N1ZXI+DQogICAgICAgIDxTaWduYXR1cmUgeG1sbnM9Imh0dHA6Ly93d3cudzMub3Jn
            LzIwMDAvMDkveG1sZHNpZyMiPg0KICAgICAgICAgICAgPFNpZ25lZEluZm8+DQogICAgICAgICAg
            ICAgICAgPENhbm9uaWNhbGl6YXRpb25NZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9y
            Zy8yMDAxLzEwL3htbC1leGMtYzE0biMiIC8+DQogICAgICAgICAgICAgICAgPFNpZ25hdHVyZU1l
            dGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNyc2Etc2hh
            MSIgLz4NCiAgICAgICAgICAgICAgICA8UmVmZXJlbmNlIFVSST0iI3MyYjdhZmU4ZTIxYTA5MTBk
            MDI3ZGZiYzk0ZWM0Yjg2MmUxZmJiZDlhYiI+DQogICAgICAgICAgICAgICAgICAgIDxUcmFuc2Zv
            cm1zPg0KICAgICAgICAgICAgICAgICAgICAgICAgPFRyYW5zZm9ybSBBbGdvcml0aG09Imh0dHA6
            Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNlbnZlbG9wZWQtc2lnbmF0dXJlIiAvPg0KICAg
            ICAgICAgICAgICAgICAgICAgICAgPFRyYW5zZm9ybSBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMu
            b3JnLzIwMDEvMTAveG1sLWV4Yy1jMTRuIyIgLz4NCiAgICAgICAgICAgICAgICAgICAgPC9UcmFu
            c2Zvcm1zPg0KICAgICAgICAgICAgICAgICAgICA8RGlnZXN0TWV0aG9kIEFsZ29yaXRobT0iaHR0
            cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnI3NoYTEiIC8+DQogICAgICAgICAgICAgICAg
            ICAgIDxEaWdlc3RWYWx1ZT4NCiAgICAgICAgICAgICAgICAgICAgICAgIGs3ei90M2lQS2l5WTlQ
            N0I4N0ZJc014bmxuaz0NCiAgICAgICAgICAgICAgICAgICAgPC9EaWdlc3RWYWx1ZT4NCiAgICAg
            ICAgICAgICAgICA8L1JlZmVyZW5jZT4NCiAgICAgICAgICAgIDwvU2lnbmVkSW5mbz4NCiAgICAg
            ICAgICAgIDxTaWduYXR1cmVWYWx1ZT4NCiAgICAgICAgICAgICAgICBLdlVyekdjd0dzdThXTU5v
            Z0lSZkF4eFdsTzR1S1hoSnJvdU9ZYWFka3pVSHZ6MXhiVlVSSDM1c2k2VTgwODR1dE5BalhUalp5
            eGZqIHF1ckVYN1ZnQ3c2WG43RnhuNG5KeEQ2Rk9QNXgvaVJrOEtxQ3VmaXBSTkh3SUNxL1Z1ZnFQ
            a3JQN3NWTGR5bUp5WjJDdTVRckVVMjMgcWFJempGZjg0S2ZwNExWbmxKWT0gDQogICAgICAgICAg
            ICA8L1NpZ25hdHVyZVZhbHVlPg0KICAgICAgICAgICAgPEtleUluZm8+DQogICAgICAgICAgICAg
            ICAgPFg1MDlEYXRhPg0KICAgICAgICAgICAgICAgICAgICA8WDUwOUNlcnRpZmljYXRlPg0KICAg
            ICAgICAgICAgICAgICAgICAgICAgTUlJQi9qQ0NBV2NDQkViempOc3dEUVlKS29aSWh2Y05BUUVG
            QlFBd1JqRUxNQWtHQTFVRUJoTUNUazh4RURBT0JnTlZCQW9UQjFWTyBTVTVGVkZReERqQU1CZ05W
            QkFzVEJVWmxhV1JsTVJVd0V3WURWUVFERXd4dFlYZ3VabVZwWkdVdWJtOHdIaGNOTURjd09USXhN
            RGt5IE1ESTNXaGNOTURjeE1qSXdNRGt5TURJM1dqQkdNUXN3Q1FZRFZRUUdFd0pPVHpFUU1BNEdB
            MVVFQ2hNSFZVNUpUa1ZVVkRFT01Bd0cgQTFVRUN4TUZSbVZwWkdVeEZUQVRCZ05WQkFNVERHMWhl
            QzVtWldsa1pTNXViekNCbnpBTkJna3Foa2lHOXcwQkFRRUZBQU9CalFBdyBnWWtDZ1lFQXZabEJ6
            UTJqR002UTlTVEJKNnRxdHVna09CTUVVL2twdnZ3T2xUNmMxWDVVSVhNd0FwTCtOVjJFYXFrK29B
            ME4rTTQyIEo3U3kwZExEcUtWQ3dzaDdxcHNJWWxEUy9vbXlVTWR5NkF6dnB0UlVVaExMaEM2elFG
            RkFVKzZyY1VLRWlTa0VSNWV6aUI0TTNhZTAgRWtXMGRybTFyT1p3YjIydHI4Tko2NXEzZ25zQ0F3
            RUFBVEFOQmdrcWhraUc5dzBCQVFVRkFBT0JnUUNtVlN0YTlUV2luL3d2dkdPaSBlOENxN2NFZzBN
            SkxrQldMb2ZOTnpyemg2aGlRZ2Z1ejlLTW9tL2toOUp1R0VqeUU3cklEYlhwMmlseFNIZ1pTYVZm
            RWt3bk1mUTUxIHZ1SFVydFJvbEQvc2t5c0lvY20rSEpLYnNtUE1qU1JmVUZ5ekJoNFJOalBvQ3Za
            dlRkbnlCZk1QL2kvSDM5bmpBZEJSaSs0OWFvcGMgdnc9PSANCiAgICAgICAgICAgICAgICAgICAg
            PC9YNTA5Q2VydGlmaWNhdGU+DQogICAgICAgICAgICAgICAgPC9YNTA5RGF0YT4NCiAgICAgICAg
            ICAgIDwvS2V5SW5mbz4NCiAgICAgICAgPC9TaWduYXR1cmU+DQogICAgICAgIDxzYW1sOlN1Ympl
            Y3Q+DQogICAgICAgICAgICA8c2FtbDpOYW1lSUQgTmFtZVF1YWxpZmllcj0ibWF4LmZlaWRlLm5v
            IiBTUE5hbWVRdWFsaWZpZXI9InVybjptYWNlOmZlaWRlLm5vOnNlcnZpY2VzOm5vLmZlaWRlLm1v
            b2RsZSIgRm9ybWF0PSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6bmFtZWlkLWZvcm1hdDpw
            ZXJzaXN0ZW50Ij4NCiAgICAgICAgICAgICAgICBVQi9XSkFhS0FQclNIYnFsYmNLV3U3Smt0Y0tZ
            DQogICAgICAgICAgICA8L3NhbWw6TmFtZUlEPg0KICAgICAgICAgICAgPHNhbWw6U3ViamVjdENv
            bmZpcm1hdGlvbiBNZXRob2Q9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpjbTpiZWFyZXIi
            Pg0KICAgICAgICAgICAgICAgIDxzYW1sOlN1YmplY3RDb25maXJtYXRpb25EYXRhIE5vdE9uT3JB
            ZnRlcj0iMjAwNy0xMi0xMFQxOTozOTo0OFoiIEluUmVzcG9uc2VUbz0iX2JlYzQyNGZhNTEwMzQy
            ODkwOWEzMGZmMWUzMTE2ODMyN2Y3OTQ3NDk4NCIgUmVjaXBpZW50PSJodHRwOi8vbW9vZGxlLmJy
            aWRnZS5mZWlkZS5uby9zaW1wbGVzYW1sL3NhbWwyL3NwL0Fzc2VydGlvbkNvbnN1bWVyU2Vydmlj
            ZS5waHAiPg0KICAgICAgICAgICAgICAgIDwvc2FtbDpTdWJqZWN0Q29uZmlybWF0aW9uRGF0YT4N
            CiAgICAgICAgICAgIDwvc2FtbDpTdWJqZWN0Q29uZmlybWF0aW9uPg0KICAgICAgICA8L3NhbWw6
            U3ViamVjdD4NCiAgICAgICAgPHNhbWw6Q29uZGl0aW9ucyBOb3RCZWZvcmU9IjIwMDctMTItMTBU
            MTE6Mjk6NDhaIiBOb3RPbk9yQWZ0ZXI9IjIwMDctMTItMTBUMTk6Mzk6NDhaIj4NCiAgICAgICAg
            ICAgIDxzYW1sOkF1ZGllbmNlUmVzdHJpY3Rpb24+DQogICAgICAgICAgICAgICAgPHNhbWw6QXVk
            aWVuY2U+DQogICAgICAgICAgICAgICAgICAgIHVybjptYWNlOmZlaWRlLm5vOnNlcnZpY2VzOm5v
            LmZlaWRlLm1vb2RsZQ0KICAgICAgICAgICAgICAgIDwvc2FtbDpBdWRpZW5jZT4NCiAgICAgICAg
            ICAgIDwvc2FtbDpBdWRpZW5jZVJlc3RyaWN0aW9uPg0KICAgICAgICA8L3NhbWw6Q29uZGl0aW9u
            cz4NCiAgICAgICAgPHNhbWw6QXV0aG5TdGF0ZW1lbnQgQXV0aG5JbnN0YW50PSIyMDA3LTEyLTEw
            VDExOjM5OjQ4WiIgU2Vzc2lvbkluZGV4PSJzMjU5ZmFkOWNhZDBjZjdkMmIzYjY4ZjQyYjE3ZDBj
            ZmE2NjY4ZTAyMDEiPg0KICAgICAgICAgICAgPHNhbWw6QXV0aG5Db250ZXh0Pg0KICAgICAgICAg
            ICAgICAgIDxzYW1sOkF1dGhuQ29udGV4dENsYXNzUmVmPg0KICAgICAgICAgICAgICAgICAgICB1
            cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YWM6Y2xhc3NlczpQYXNzd29yZA0KICAgICAgICAg
            ICAgICAgIDwvc2FtbDpBdXRobkNvbnRleHRDbGFzc1JlZj4NCiAgICAgICAgICAgIDwvc2FtbDpB
            dXRobkNvbnRleHQ+DQogICAgICAgIDwvc2FtbDpBdXRoblN0YXRlbWVudD4NCiAgICAgICAgPHNh
            bWw6QXR0cmlidXRlU3RhdGVtZW50Pg0KICAgICAgICAgICAgPHNhbWw6QXR0cmlidXRlIE5hbWU9
            ImdpdmVuTmFtZSI+DQogICAgICAgICAgICAgICAgPHNhbWw6QXR0cmlidXRlVmFsdWUgeG1sbnM6
            c2FtbD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmFzc2VydGlvbiI+DQogICAgICAgICAg
            ICAgICAgICAgIFJrVkpSRVVnVkdWemRDQlZjMlZ5SUNobmFYWmxiazVoYldVcElNTzR3NmJEcGNP
            WXc0YkRoUT09DQogICAgICAgICAgICAgICAgPC9zYW1sOkF0dHJpYnV0ZVZhbHVlPg0KICAgICAg
            ICAgICAgPC9zYW1sOkF0dHJpYnV0ZT4NCiAgICAgICAgICAgIDxzYW1sOkF0dHJpYnV0ZSBOYW1l
            PSJlZHVQZXJzb25QcmluY2lwYWxOYW1lIj4NCiAgICAgICAgICAgICAgICA8c2FtbDpBdHRyaWJ1
            dGVWYWx1ZSB4bWxuczpzYW1sPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9u
            Ij4NCiAgICAgICAgICAgICAgICAgICAgZEdWemRFQm1aV2xrWlM1dWJ3PT0NCiAgICAgICAgICAg
            ICAgICA8L3NhbWw6QXR0cmlidXRlVmFsdWU+DQogICAgICAgICAgICA8L3NhbWw6QXR0cmlidXRl
            Pg0KICAgICAgICAgICAgPHNhbWw6QXR0cmlidXRlIE5hbWU9Im8iPg0KICAgICAgICAgICAgICAg
            IDxzYW1sOkF0dHJpYnV0ZVZhbHVlIHhtbG5zOnNhbWw9InVybjpvYXNpczpuYW1lczp0YzpTQU1M
            OjIuMDphc3NlcnRpb24iPg0KICAgICAgICAgICAgICAgICAgICBWVTVKVGtWVVZBPT0NCiAgICAg
            ICAgICAgICAgICA8L3NhbWw6QXR0cmlidXRlVmFsdWU+DQogICAgICAgICAgICA8L3NhbWw6QXR0
            cmlidXRlPg0KICAgICAgICAgICAgPHNhbWw6QXR0cmlidXRlIE5hbWU9Im91Ij4NCiAgICAgICAg
            ICAgICAgICA8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4bWxuczpzYW1sPSJ1cm46b2FzaXM6bmFtZXM6
            dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIj4NCiAgICAgICAgICAgICAgICAgICAgVlU1SlRrVlVWQT09
            DQogICAgICAgICAgICAgICAgPC9zYW1sOkF0dHJpYnV0ZVZhbHVlPg0KICAgICAgICAgICAgPC9z
            YW1sOkF0dHJpYnV0ZT4NCiAgICAgICAgICAgIDxzYW1sOkF0dHJpYnV0ZSBOYW1lPSJlZHVQZXJz
            b25PcmdETiI+DQogICAgICAgICAgICAgICAgPHNhbWw6QXR0cmlidXRlVmFsdWUgeG1sbnM6c2Ft
            bD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmFzc2VydGlvbiI+DQogICAgICAgICAgICAg
            ICAgICAgIFpHTTlkVzVwYm1WMGRDeGtZejF1Ync9PQ0KICAgICAgICAgICAgICAgIDwvc2FtbDpB
            dHRyaWJ1dGVWYWx1ZT4NCiAgICAgICAgICAgIDwvc2FtbDpBdHRyaWJ1dGU+DQogICAgICAgICAg
            ICA8c2FtbDpBdHRyaWJ1dGUgTmFtZT0iZWR1UGVyc29uUHJpbWFyeUFmZmlsaWF0aW9uIj4NCiAg
            ICAgICAgICAgICAgICA8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4bWxuczpzYW1sPSJ1cm46b2FzaXM6
            bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIj4NCiAgICAgICAgICAgICAgICAgICAgYzNSMVpH
            VnVkQT09DQogICAgICAgICAgICAgICAgPC9zYW1sOkF0dHJpYnV0ZVZhbHVlPg0KICAgICAgICAg
            ICAgPC9zYW1sOkF0dHJpYnV0ZT4NCiAgICAgICAgICAgIDxzYW1sOkF0dHJpYnV0ZSBOYW1lPSJt
            YWlsIj4NCiAgICAgICAgICAgICAgICA8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4bWxuczpzYW1sPSJ1
            cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIj4NCiAgICAgICAgICAgICAgICAg
            ICAgYlc5eWFXRXRjM1Z3Y0c5eWRFQjFibWx1WlhSMExtNXYNCiAgICAgICAgICAgICAgICA8L3Nh
            bWw6QXR0cmlidXRlVmFsdWU+DQogICAgICAgICAgICA8L3NhbWw6QXR0cmlidXRlPg0KICAgICAg
            ICAgICAgPHNhbWw6QXR0cmlidXRlIE5hbWU9InByZWZlcnJlZExhbmd1YWdlIj4NCiAgICAgICAg
            ICAgICAgICA8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4bWxuczpzYW1sPSJ1cm46b2FzaXM6bmFtZXM6
            dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIj4NCiAgICAgICAgICAgICAgICAgICAgYm04PQ0KICAgICAg
            ICAgICAgICAgIDwvc2FtbDpBdHRyaWJ1dGVWYWx1ZT4NCiAgICAgICAgICAgIDwvc2FtbDpBdHRy
            aWJ1dGU+DQogICAgICAgICAgICA8c2FtbDpBdHRyaWJ1dGUgTmFtZT0iZWR1UGVyc29uT3JnVW5p
            dEROIj4NCiAgICAgICAgICAgICAgICA8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4bWxuczpzYW1sPSJ1
            cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIj4NCiAgICAgICAgICAgICAgICAg
            ICAgYjNVOWRXNXBibVYwZEN4dmRUMXZjbWRoYm1sNllYUnBiMjRzWkdNOWRXNXBibVYwZEN4a1l6
            MXVidz09DQogICAgICAgICAgICAgICAgPC9zYW1sOkF0dHJpYnV0ZVZhbHVlPg0KICAgICAgICAg
            ICAgPC9zYW1sOkF0dHJpYnV0ZT4NCiAgICAgICAgICAgIDxzYW1sOkF0dHJpYnV0ZSBOYW1lPSJz
            biI+DQogICAgICAgICAgICAgICAgPHNhbWw6QXR0cmlidXRlVmFsdWUgeG1sbnM6c2FtbD0idXJu
            Om9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmFzc2VydGlvbiI+DQogICAgICAgICAgICAgICAgICAg
            IFJrVkpSRVVnVkdWemRDQlZjMlZ5SUNoemJpa2d3N2pEcHNPbHc1akRoc09GDQogICAgICAgICAg
            ICAgICAgPC9zYW1sOkF0dHJpYnV0ZVZhbHVlPg0KICAgICAgICAgICAgPC9zYW1sOkF0dHJpYnV0
            ZT4NCiAgICAgICAgICAgIDxzYW1sOkF0dHJpYnV0ZSBOYW1lPSJjbiI+DQogICAgICAgICAgICAg
            ICAgPHNhbWw6QXR0cmlidXRlVmFsdWUgeG1sbnM6c2FtbD0idXJuOm9hc2lzOm5hbWVzOnRjOlNB
            TUw6Mi4wOmFzc2VydGlvbiI+DQogICAgICAgICAgICAgICAgICAgIFJrVkpSRVVnVkdWemRDQlZj
            MlZ5SUNoamJpa2d3N2pEcHNPbHc1akRoc09GDQogICAgICAgICAgICAgICAgPC9zYW1sOkF0dHJp
            YnV0ZVZhbHVlPg0KICAgICAgICAgICAgPC9zYW1sOkF0dHJpYnV0ZT4NCiAgICAgICAgICAgIDxz
            YW1sOkF0dHJpYnV0ZSBOYW1lPSJlZHVQZXJzb25BZmZpbGlhdGlvbiI+DQogICAgICAgICAgICAg
            ICAgPHNhbWw6QXR0cmlidXRlVmFsdWUgeG1sbnM6c2FtbD0idXJuOm9hc2lzOm5hbWVzOnRjOlNB
            TUw6Mi4wOmFzc2VydGlvbiI+DQogICAgICAgICAgICAgICAgICAgIFpXMXdiRzk1WldVPV9jM1Jo
            Wm1ZPV9jM1IxWkdWdWRBPT0NCiAgICAgICAgICAgICAgICA8L3NhbWw6QXR0cmlidXRlVmFsdWU+
            DQogICAgICAgICAgICA8L3NhbWw6QXR0cmlidXRlPg0KICAgICAgICA8L3NhbWw6QXR0cmlidXRl
            U3RhdGVtZW50Pg0KICAgIDwvc2FtbDpBc3NlcnRpb24+DQo8L3NhbWxwOlJlc3BvbnNlPg==
            '''.replaceAll(new RegExp(r'(\n|\s)'), "")
          ],

          "RelayState": ["739054b8-30f6-4d0d-82f8-30de596a2658"]
        }
      }
    });

    app.onBeforeRequestHandler(request);

    var storedMessages = JSON.decode(window.localStorage["messages"])
    .map((msg) => new SamlMessage.fromJson(msg));

    expect(storedMessages.length, equals(1));

    SamlMessage message = storedMessages.elementAt(0);

    expect(message.content.replaceAll(new RegExp(r'(\n|\s{2,})'), ""), contains('''
    <saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
      max.feide.no
    </saml:Issuer>
    '''.replaceAll(new RegExp(r'(\n|\s{2,})'), "")));

    expect(message.binding, equals("post"));
    expect(message.parameter, equals("SAMLResponse"));
    expect(message.relayState, equals("739054b8-30f6-4d0d-82f8-30de596a2658"));
  });
}