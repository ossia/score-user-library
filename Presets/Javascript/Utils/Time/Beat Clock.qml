import Score 1.0

// Musical position of the playhead: bar, beat, and phases you can animate on.
// Everything here comes from the score itself, so it follows the tempo track
// and the time signature without any configuration.
Script {
  IntSpinBox  { id: subdiv; objectName: "Subdivision"; min: 1; max: 64; init: 1 }
  ValueOutlet { id: barOut; objectName: "Bar" }
  ValueOutlet { id: beatOut; objectName: "Beat" }
  ValueOutlet { id: beatPhase; objectName: "Beat phase" }
  ValueOutlet { id: barPhase; objectName: "Bar phase" }
  ValueOutlet { id: tempoOut; objectName: "Tempo" }
  ValueOutlet { id: signatureOut; objectName: "Signature" }
  ValueOutlet { id: onBeat; objectName: "On beat" }
  ValueOutlet { id: onBar; objectName: "On bar" }

  property int lastBeat: -1
  property int lastBar: -1

  tick: function(token, state) {
    // Musical positions are counted in quarter notes since the start.
    const q = token.musical_start_position;
    const barStart = token.musical_start_last_bar;
    const upper = (token.signature_upper > 0) ? token.signature_upper : 4;
    const lower = (token.signature_lower > 0) ? token.signature_lower : 4;

    // How many quarter notes one beat of the current signature lasts.
    const quartersPerBeat = 4. / lower;
    const quartersPerBar = upper * quartersPerBeat;

    const intoBar = q - barStart;
    const beatFloat = (quartersPerBeat > 0.) ? (intoBar / quartersPerBeat) : 0.;
    const beat = Math.floor(beatFloat);
    const bar = (quartersPerBar > 0.) ? Math.floor(barStart / quartersPerBar) : 0;

    tempoOut.value = token.tempo;
    signatureOut.value = [ upper, lower ];
    barOut.value = bar;
    beatOut.value = beat;
    barPhase.value = (quartersPerBar > 0.) ? (intoBar / quartersPerBar) : 0.;

    // The subdivision splits each beat further: 4 gives sixteenth notes in 4/4.
    const sub = Math.max(1, subdiv.value);
    const stepFloat = beatFloat * sub;
    const step = Math.floor(stepFloat);
    beatPhase.value = stepFloat - step;

    if (step !== lastBeat) {
      lastBeat = step;
      onBeat.value = true;
    }
    if (bar !== lastBar) {
      lastBar = bar;
      onBar.value = true;
    }
  }
}
