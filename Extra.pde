color average(int[] img, int[] mask) {
  float r = 0, g = 0, b = 0;
  for(int i = 0; i < mask.length; i++) {
    int c = img[mask[i]];
    r += red(c);
    g += green(c);
    b += blue(c);
  }
  return color(r / mask.length, g / mask.length, b / mask.length);
}

boolean sameColor(color a, color b, float tolerance) {
  float d = sqrt(sq(red(a) - red(b)) + sq(green(a) - green(b)) + sq(blue(a) - blue(b)));
  d /= sqrt(3);
  return d < tolerance;
}

void trigger(int note) {
  Note curNote = new Note(0, note, 100);
  midiOut.sendNoteOn(curNote);
  midiOut.sendNoteOff(curNote);
}
