import Score 1.0

Script {
  // Declare our inputs & outputs
  FloatSlider { id: in1; min: 20; max: 800; init: 440; objectName: "Frequency" }
  AudioOutlet { id: out1 }
  
  // Index to keep track of the phase
  property real phase: 0;

  tick: function(token, state) {
    // Create an array to store our samples
    let arr = new Array(state.buffer_size);
    for (let i = 0; i < state.buffer_size; ++i)
      arr[i] = 0;

    // How many samples we must write in this array
    // (the process could run for e.g. only frame 17 through 24 in a 128-frame buffer)
    const tm = state.timings(token);
    
    if(tm.length > 0) {
      // Computer the sin() coefficient
      const freq = in1.value;

      // Notice how we get sample_rate from state.
      const phi = 2 * Math.PI * freq / state.sample_rate;

      // Fill our array
      for(var s = 0; s < tm.length; s++) {
        const sample = freq > 0 ? Math.sin(phase) : 0;
        arr[tm.start_sample + s] = 0.3 * sample;
        phase += phi;
      }
    }

    // Write two audio channels, which will give stereo output by default in score.
    out1.setChannel(0, arr);
    out1.setChannel(1, arr);
  }
}
