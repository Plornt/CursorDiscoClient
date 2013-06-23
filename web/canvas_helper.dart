part of CursorDiscoClient;

class CanvasHelper {
  //Static
  static Map<String, CanvasHelper> canvases = new Map<String,CanvasHelper>();
  
  /// Calls the given callback for each canvas element
  static void applyToAll (Function actionToApply) {
    canvases.forEach((String ID, CanvasHelper ch) {
      actionToApply(ch.canvas);
    });
  }
  
  /// Calls the update function on all CanvasHelper's
  static void updateAll (num time) {
    canvases.forEach((String ID, CanvasHelper ch) {
      ch.update(time);
    });
  }
  
  /// Calls the draw function on all CanvasHelper's
  static void drawAll () {
    canvases.forEach((String ID, CanvasHelper ch) {
      ch.draw();
    });
  }
  
  /// Returns the matching CanvasHelper for the given [id]
  static CanvasHelper getch (String id) {
    return canvases[id];
  }
  
  //Dynamic
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  String ID;
  num lastFrameTime;
  List<Drawable> drawObjects = [];
  
  CanvasHelper (String this.ID) {
    lastFrameTime = new DateTime.now().millisecondsSinceEpoch;
    canvas = query("#${this.ID}");
    ctx = canvas.getContext("2d");
    CanvasHelper.canvases[this.ID] = this; 
  }
  
  /// Adds the drawable to the update and draw loop
  void addDrawable (Drawable d) {
    drawObjects.add(d);
  }
  
  
  void update (num time) {
    num msSinceLastFrame = time - lastFrameTime;
    
    if (drawObjects.length > 0) {
      List destroyObjects = [];
      drawObjects.forEach((d) { d.update(msSinceLastFrame); if (d.destroy == true) { destroyObjects.add(d); } });
      if (destroyObjects.length > 0) {
        destroyObjects.forEach((d) { if (d.destroy == true) { drawObjects.remove(d); } });
      }
        
    }
    lastFrameTime = time;
  }
  
  /// Calls the draw function of all drawables in [drawObject]
  void draw () {
    this.canvas.width = this.canvas.width;
    drawObjects.forEach((d) { d.draw(this.ctx); });    
  }
}