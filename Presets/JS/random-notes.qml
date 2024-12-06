import Score 1.0

Script {
  FloatKnob { 
    id: duration
    objectName: "Duration (ms)"
    min: 0.001
    max: 100000.
    init: 100.
  }
  IntSpinBox { 
    id: mid
    objectName: "Middle"
    min: 0
    max: 127
    init: 40
  }
  IntSpinBox { 
    id: span
    objectName: "Span"
    min: 0
    max: 127
    init: 10
  }

  function clamp(value, min, max)
  { return Math.min(Math.max(value, min), max); }
  
  MidiOutlet { id: midiOut }

  property real note: -1;
  property real last_date: 0;
  tick: function(token, state)
  {
    const dur_flicks = duration.value * 765000;
    if(token.date - last_date > dur_flicks)
    {
      last_date = token.date;
      
      if(note !== -1) {
        var note_off = [128, note, 64];
        midiOut.add(note_off);
      }
      
      note = clamp(Math.round(Math.random() * span.value + mid.value), 0, 127);
      var note_on = [144, note, 64];
      midiOut.add(note_on);
    }
  }
}

