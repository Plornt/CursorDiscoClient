part of CursorDiscoClient;

class WebSocketHandler {
  WebSocket ws;
  String sIP;
  String sPort;
  String sPath;
  Function messageHandler;
  
  /// Creates a new handler ready for connection via [connect()]
  WebSocketHandler (String this.sIP, String this.sPort, String this.sPath, Function this.messageHandler);
  
  /// Attempts a connection to the server - if it disconnects it will try again. Calls callback once complete
  void connect(Function onOpen) {
    // Not connected so we can no longer send messages to the server. 
    canSend = false;  
    
    ws = new WebSocket ("ws://$sIP:$sPort/$sPath");
    ws.onMessage.listen((MessageEvent message) { messageHandler(message); });
    ws.onClose.listen((e) =>  this.connect(onOpen) );
    ws.onError.listen((e) =>  this.connect(onOpen));
    ws.onOpen.listen((e) { 
      // Connected again so we can now send messages.
      canSend = true; 
    
      // Call our callback
      onOpen();
    });
  }
  
  /// Sends a message on the WebSocket if it can. Returns true if succeeded.
  bool send (String message) {
    if (canSend && ws.readyState == 1) { 
      ws.send(message);
      return true;
    }
    else return false;
  }
}