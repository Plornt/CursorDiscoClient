part of CursorDiscoClient;

abstract class Drawable  {
  bool destroy = false;
  Drawable ();
  /// Called every time the canvas requests a draw
  void draw (CanvasRenderingContext2D ctx);

  /// Called BEFORE the draw. Set [destroy] to true to tell the canvas to delete the object.
  void update (num time);
}


/// Basic animation class. Takes a sprite sheet and turns it into an animation
class DrawableAnimation extends Drawable {
  int frameSpeed = 20;
  int frames = 12;
  int frameNow = 1;
  int msSinceChange = 0;
  num x = 0;
  num y = 0;
  ImageElement img;
  
  /// Create a new animation from the image [img] and plays it back at [frameSpeed].
  /// Has to be supplied with the amount of [frames] in the image
  DrawableAnimation(ImageElement this.img, int this.frameSpeed, int this.frames) { }
  
  void update(num timeSinceLastUpdate) {
    if (msSinceChange >= frameSpeed) {
      if (frameNow != frames)  { 
        frameNow++; 
      } else {
        frameNow = 1;
      }
      // Reset our timer
      msSinceChange = 0;
    }
    
    msSinceChange += timeSinceLastUpdate;
  }
  
  void draw (CanvasRenderingContext2D ctx) {
    ctx.drawImageScaledFromSource(img, ((frameNow - 1) * (img.width / frames)), 0, (img.width / frames), img.height, x, y, (img.width / frames), img.height);
  }
}

class DrawableDiscoBall extends DrawableAnimation {   
  DrawableDiscoBall (ImageElement img, int frameSpeed, int frames): super(img, frameSpeed, frames);
  
  void update (num n) {
    // We want our disco ball to be in the middle of the canvas
    num imgPosW = (screenWidth / 2) - ((img.width / 12) / 2); 
    
    this.x = imgPosW.toInt();
   
    // Leave the rest to the animation renderer.  
    super.update(n);
  }
}


class DrawableCursor extends Drawable {
  num x; num y; num lastSent = 0; int lastX; int lastY;
  String name; String ID;
  static Map<String, DrawableCursor> cursors = new Map<String, DrawableCursor>();
  DrawableCursor (int this.x, int this.y, String this.ID) {
    if (!cursors.containsKey(this.ID)) {
      cursors[this.ID] = this; 
    }
  }
  void updatePos (x, y) {
    this.x = x; this.y = y;
  }
  void removeSelf () {
    cursors.remove(this.ID);
    this.destroy = true;
  }
  static void removeCursor (String ID) {
    if (cursors.containsKey(ID)) {
      cursors[ID].removeSelf();
    }
  }
  void update (num time) {
    lastSent += time;
    if (lastSent >= 10) {
      if (myCursor.hashCode == this.hashCode) { 
       if (this.x != lastX && this.y != lastY) {
        lastX = x;
        lastY = y;
        ws.send("MOVECURSOR ${x} ${y} ${window.innerWidth} ${window.innerHeight}");
        lastSent = 0;
       }
      }
    }
  }
  int scale = 4;
  List getAjustedCord (List listoffset) {
    return [((listoffset[0]) * this.scale),((listoffset[1]) * this.scale)];
  }
  List cursorPoints = [[0,0],[1,-4],[0,-3],[-1,-4],[0,0]];
  void draw (CanvasRenderingContext2D ctx) {
    ctx.save();
    ctx.drawImage(mainImages.get("cur.png"), x, y);
    ctx.restore();
   
  }
}

/// Basic FPS Counter.
class DrawableFPSCounter extends Drawable {
  int _timeoflastfpscount = 0, _frameCount = 0, _prevInfo = 0, previousTime = new DateTime.now().millisecondsSinceEpoch;
  double x; double y;
  DrawableFPSCounter (double this.x,double this.y) {
  }
  void update (num sinceLast) {
    _frameCount++;
    _timeoflastfpscount += sinceLast;
    if (_timeoflastfpscount >= 1000) {
     _prevInfo = _frameCount;
     _frameCount = 0;  
     _timeoflastfpscount = 0;
    }
  }
  
  void draw (CanvasRenderingContext2D ctx) {
    ctx.font = "12px 'Open Sans'";
    ctx.fillStyle = "red";
    ctx.fillText("${_prevInfo.toString()} FPS - Frames drawn since last: ${_frameCount} Now Playing: ${aud.currentSrc}", x, y, ctx.canvas.width);
  }
}

/// Creates a rectangle as large as the screen with a specific [color]
class DrawableBackground extends Drawable {
  static String color = "lightblue";
  void update(num t) {
    
  }
  void draw (CanvasRenderingContext2D ctx) {
    ctx.fillStyle = color;
    ctx.fillRect(0,0,screenWidth,screenHeight);
  }
}

