library CursorDiscoClient;

import 'dart:html';
import 'dart:math';
import 'dart:async';

//Peice our entire project together
part 'image_preloader.dart';
part 'websocket_handler.dart';
part 'canvas_helper.dart';
part 'canvas_drawables.dart';

// Contains the Audio HTML element that is used to play all of our music
AudioElement aud;

// Defines whether everything is loaded up and can send to the CursorDiscoServer
bool canSend = false;
// Number of seconds the music should be synced to. 
int syncTo = 0;
// Is true if the music is synced, false if not. Default should be true. 
// Also defines whether or not it should send timeUpdates on the audio element to the server
bool synced = true;
// Server info
String serverIP = "86.31.106.190";
String serverPort = "8000";
String serverPath = "";

// Holds the current WebSocket used for communication to the CursorDiscoServer
WebSocketHandler ws = new WebSocketHandler(serverIP, serverPort, serverPath, messageHandler);

// Our cursor
DrawableCursor myCursor = new DrawableCursor (0, 0, "SELF");

// Screen information
int screenWidth;
int screenHeight;

ImagePreloader mainImages = new ImagePreloader(startDisco);
void main() {
  //Attempt to load websocket
  mainImages.loadImage("cur.png")
            .loadImage("Disco_ball.gif")
            .startLoad();
}

void startDisco() {
  DivElement loginBox = query("#loginWindow");
  DivElement canvasCont = query("#canvasContainer");
  
  // Show the connnection box and hide the canvases.
  loginBox.style.display = "block";
  canvasCont.style.display = "none";
  query("body").style.cursor = "pointer";
  
  // Attempt a connection
  ws.connect(() {
    // Hide the connection box and show the canvases.
    loginBox.style.display = 'none'; 
    canvasCont.style.display = 'block'; 
    canvasCont.style.cursor = "none"; 
  });
  
  // Pause the music and wait for sync update from server
  aud = query('#loop');
  aud.pause();
  loadDisco();
}


void loadDisco() {
  // Load in our canvas's
  CanvasHelper BG = new CanvasHelper ("backgroundImage");
  CanvasHelper cursors = new CanvasHelper ("cursors");
  CanvasHelper UI = new CanvasHelper ("UI");
  
 // Lets start by resizing everything to fit.
  screenWidth = window.innerWidth;
  screenHeight = window.innerHeight;
  CanvasHelper.applyToAll((CanvasElement canvas) {
    canvas.width = screenWidth;
    canvas.height = screenHeight;
  });
  
  window.onResize.listen((event) {
    screenWidth = window.innerWidth;
    screenHeight = window.innerHeight;
    CanvasHelper.applyToAll((CanvasElement canvas) {
      canvas.width = screenWidth;
      canvas.height = screenHeight;
    });
  });
  // Add our initial drawable entities
  cursors.addDrawable(myCursor);
  UI.addDrawable(new DrawableFPSCounter(10.0,10.0));
  BG.addDrawable(new DrawableBackground());
  UI.addDrawable(new DrawableDiscoBall(mainImages.get("Disco_ball.gif"), 20, 12));
  
  //Start ticking the canvases
  window.requestAnimationFrame((num t) { tickAllCanvas(); });
  
  // Add event handler for our own cursor..
  window.onMouseMove.listen((MouseEvent ev) { 
    // Ignore warning
    myCursor.updatePos(ev.clientX, ev.clientY); 
    
  });
  // Load up our song!

  
  aud.onEnded.listen((e){ ws.send("ENDSONG"); });
  aud.onCanPlayThrough.listen((e) { 
    if (synced == false) {
      aud.currentTime = syncTo;
      aud.play();
      synced = true;
    }
  });
  aud.onTimeUpdate.listen((T) { 
    if (synced == true) { 
     if (aud.playbackRate > 0) ws.send("TIMEUPD ${aud.currentTime}"); 
    }
  });
  
}

void messageHandler(MessageEvent message) {
  List<String> splitMsg = message.data.toString().split(" ");
  switch (splitMsg[0]) {
    case "NEWCONNECTION":
      // Check if the cursor already exists on our screen, if it doesnt then create a new one.
      if (!DrawableCursor.cursors.containsKey(splitMsg[1])) {
        String cursorID = splitMsg[1];
        CanvasHelper.getch("cursors").addDrawable(new DrawableCursor(0, 0, cursorID));
      }
    break;
    case "MOVECURSOR":
      // Check if the cursor exists or not. If it does then move it.
      if (DrawableCursor.cursors.containsKey(splitMsg[1])) {
          CanvasHelper ch = CanvasHelper.getch("cursors");
          
          // The server sends the cursor x & y as a percentage so smaller browsers can view and use the entire screen realestate
          // The following code converts it back into a usable screen location (relating to the local computer)
          var x = (screenWidth * (double.parse(splitMsg[2]) / 100));
          var y = (screenHeight * (double.parse(splitMsg[3]) / 100));
          
          // Tell the cursor to move to the new location
          DrawableCursor.cursors[splitMsg[1]].updatePos(x, y);
      }
    break;
    case "DISCONNECT":
      DrawableCursor.removeCursor(splitMsg[1]);
    break;
    case "CHANGEBG":
      DrawableBackground.color = splitMsg[1];
    break;
    case "CHANGESONG":
      String songName = splitMsg[1];
      double songTimeLocation = double.parse(splitMsg[2]);
      
      // Change the audio source to the new song
      aud.src = "./assets/$songName";
      
      // Set our global variables syncTo to be the time the server is telling us to sync to.
      // The actual sync is done elsewhere in the code once the song has synced.
      syncTo = songTimeLocation.toInt();
      synced = false;
      
      // Tell the audio tag to load the next song
      aud.load();
    break;
  }
}

void tickAllCanvas () {
  CanvasHelper.updateAll(new DateTime.now().millisecondsSinceEpoch); 
  CanvasHelper.drawAll();
  window.requestAnimationFrame((num t) { tickAllCanvas(); });
}
