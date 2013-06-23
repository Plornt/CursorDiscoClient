part of CursorDiscoClient;

class ImagePreloader {
  int loadedImages = 0;
  Map<String, ImageElement> img = new Map<String, ImageElement>();
  Function callback;
  
  /// Creates a new ImagePreloader ready to preload your images.
  ImagePreloader (Function this.callback);
  
  /// Starts the loading process for [src]. Once it has loaded it will call [startLoad]
  /// Returns itself to enable chaining.
  ImagePreloader loadImage (String src) {
    ImageElement curr = new ImageElement();
    curr.src = "./assets/$src";
    curr.onLoad.listen((ev) {
      this.startLoad();      
    });
    // Add our current image to the map of all images.
    img[src] = curr;
    return this;
  }
  
  /// Retreives the ImageElement for [src].
  /// Throws an exception if it has not been loaded into the Preloader.
  ImageElement get (String src) {
    if (img.containsKey(src)) {
      return img[src]; 
    } else {
      throw "Image has not been loaded into the PreLoader: $src";
    }
  }
  
  /// Should be called once in your code to tell it you have finished loading all your images into it.
  /// It is also called by the images onLoad events and once everything is loaded it will call the [callback]
  void startLoad() {
    loadedImages++;
   if (loadedImages == (img.length + 1)) {
      this.callback();
   }
  }
  
}