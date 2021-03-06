public class AnimationPanel extends Node {
  protected int _gray1, _gray2, _gray3, _gray4, _red, _blue1, _blue2, _green1, _green2, _yellow, _white;
  protected float _width, _height;
  protected int _colorSlider, _colorEmpty, _colorSliderHighlight;
  protected int _colorText;
  protected PFont _font36;
  protected Scene _scene;
  protected TimeLine _timeLine;
  protected PostureInterpolator _postureInterpolator;


  public AnimationPanel(Scene scene, Skeleton skeleton) {
    super();
    tagging = false;
    _gray1 = color(82, 82, 82);
    _gray2 = color(65, 65, 65);
    _gray3 = color(49, 49, 49);
    _gray4 = color(179, 179, 179);
    _red = color(202, 62, 71);
    _blue1 = color(23, 34, 59);
    _blue2 = color(38, 56, 89);
    _green1 = color(0, 129, 138);
    _yellow = color(249, 210, 118);
    _white = color(240, 236, 226);
    _green2 = color(33, 152, 151);

    _colorSlider = _blue1;
    _colorEmpty = _gray1;
    _colorSliderHighlight = _green1;
    _colorText = _white;
    _font36 = scene.pApplet.createFont("Arial", 48, true);//loadFont("FreeSans-36.vlw");

    //set panel dimension
    float rh = scene.radius(), rw = rh * scene.aspectRatio();
    translate(-rw, -rh, 0);

    _width = 2 * rw;
    _height = 2 * rh;

    _scene = scene;
    _postureInterpolator = new PostureInterpolator(skeleton);

    _timeLine = new TimeLine(this, 200, 1000, 28);

    this.setConstraint(new Constraint() {
      @Override
      public Vector constrainTranslation(Vector translation, Node node) {
        //restriction on vertical translation
        return new Vector();
      }

      @Override
      public Quaternion constrainRotation(Quaternion rotation, Node node) {
        //Rotation is not allowed
        return new Quaternion();
      }
    });
  }

  public void savePosture() {
    _timeLine._current.savePosture();
  }

  public void play(float speed) {
    _postureInterpolator.clear();
    addKeyPostures();
    _postureInterpolator.setSpeed(speed);
    _postureInterpolator.run();
  }
  
  public void saveInterpolator(PApplet pApplet, String file){
    _postureInterpolator.clear();
    addKeyPostures();
    _postureInterpolator.save(pApplet, file);
  }

  public void loadInterpolator(PApplet pApplet, String file){
    PostureInterpolator aux = new PostureInterpolator(_postureInterpolator.skeleton());
    aux.load(pApplet, file);
    loadKeyPostures(aux);
  }

  public void addKeyPostures() {
    float prev = 0;
    for (KeyPoint keyPoint : _timeLine._points) {
      float time = keyPoint._time / 1000f;
      if (keyPoint._status == KeyPoint.Status.ENABLED)
        _postureInterpolator.addKeyPosture(keyPoint._posture, time - prev);
      prev = time;
    }
  }

  public void loadKeyPostures(PostureInterpolator pi) {
    float prev = 0;
    SortedSet<Float> keys = new TreeSet<Float>(pi.keyFrames().keySet());
    int i = 0;
    for(float t : keys){
      _timeLine._current = _timeLine._points[i];
      _timeLine._current.deletePosture();
      //_timeLine._current._time = t;
      //_timeLine._current.setTranslation(_timeLine._spaceStep * t, 0, 0);
      pi.keyFrames().get(t).loadValues(pi.skeleton());
      _timeLine._current.savePosture();
      i++;
    }
  }

  public void toggleCurrentKeyPoint() {
    KeyPoint p = _timeLine._current;
    if (p._status.equals(KeyPoint.Status.ENABLED)) p.disable();
    else if (p._status.equals(KeyPoint.Status.DISABLED)) p.enable();
  }

  public void deletePostureAtKeyPoint() {
    KeyPoint p = _timeLine._current;
    p.deletePosture();
  }

  public void enableRecurrence(boolean recurrent) {
    _postureInterpolator.enableRecurrence(recurrent);
  }

  public boolean isRecurrent() {
    return _postureInterpolator.isRecurrent();
  }

  public void stop() {
    _postureInterpolator.reset();
  }

}
