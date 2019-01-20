        // this is our global websocket, used to communicate from/to Stream Deck software
        // and some info about our plugin, as sent by Stream Deck software
        var websocket = null,
        uuid = null,
        actionInfo = {};

const getPropFromString = (jsn, str, sep = '.') => {
    const arr = str.split(sep);
    return arr.reduce((obj, key) =>
        (obj && obj.hasOwnProperty(key)) ? obj[key] : undefined, jsn);
};

        function connectSocket(inPort, inUUID, inRegisterEvent, inInfo, inActionInfo) {
            uuid = inUUID;
            // please note: the incoming arguments are of type STRING, so
            // in case of the inActionInfo, we must parse it into JSON first
            actionInfo = JSON.parse(inActionInfo); // cache the info
            websocket = new WebSocket('ws://localhost:' + inPort);

            // if connection was established, the websocket sends
            // an 'onopen' event, where we need to register our PI
            websocket.onopen = function () {
                var json = {
                    event:  inRegisterEvent,
                    uuid:   inUUID
                };
                // register property inspector to Stream Deck
                websocket.send(JSON.stringify(json));
                sendValueToPlugin(true, 'registerPropertyInspector');
            }

          websocket.onmessage = function(evt) {
            console.log(evt);
            var jsonObj = JSON.parse(evt.data);
            var event = jsonObj['event'];
            if (event === 'sendToPropertyInspector')
            {
              var pSettings = getPropFromString(jsonObj, "payload.settings");
              var pluginWantsSave = getPropFromString(jsonObj, "payload.pluginWantsSave");
              if (pSettings)
              {
                restoreSettings(pSettings);
              } else if (pluginWantsSave) {
                requestSave(); 
              } else {
                pluginMessageReceived(jsonObj);
              }
            }

          }
         
        }

        // our method to pass values to the plugin
        function requestSave() {
          sendValueToPlugin(makeSettings(), 'propertyInspectorRequestsSave');
        }
        function sendValueToPlugin(value, param) {
            if (websocket) {
                const json = {
                        "action": actionInfo['action'],
                        "event": "sendToPlugin",
                        "context": uuid,
                        "payload": {
                            [param] : value
                        }
                 };
                 websocket.send(JSON.stringify(json));
            }
        }
window.addEventListener('beforeunload', function (e) {
    e.preventDefault();
    requestSave();
    sendValueToPlugin(makeSettings(), 'propertyInspectorWillDisappear');
    // Don't set a returnValue to the event, otherwise Chromium with throw an error.
});

