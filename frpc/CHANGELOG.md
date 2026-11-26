# Changelog

## 1.1.1

- Keeps retrying if it can't reach the WellTechnically server when it starts — for example
  when Home Assistant boots before your network is ready, or after a router restart.
  Previously it stopped after one failed attempt and remote access stayed off until the app
  was restarted by hand.

## 1.1.0

- Adds the **client_secret** setting: your own password for the connection, in addition to
  the shared token. Required by the server from this version on — copy it from your details
  card.

## 1.0.0

- First release: secure outbound tunnel from Home Assistant to the WellTechnically proxy, for
  remote access with no router changes.
