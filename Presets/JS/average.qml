import Score 1.0
Script {
  ValueInlet { id: in1 }
  ValueOutlet { id: out1 }
  IntSlider { id: range; min: 1; max: 100000; objectName: "milliseconds"; }

  // Where we store the last N values
  property var avg: [];
  
  tick: function(token, state) {
    // Compute the current date
    const date_in_ms = 1000. * (token.previous_date * state.model_to_physical) / state.sample_rate;
    
    if (typeof in1.value !== 'undefined') {
      // Push the value if we got one
      avg.push({date: date_in_ms, value: in1.value});
    }
    
    // Remove all the elements of the array older than the user-specified time span
    const min_ms = Math.max(range.value, 1);
    avg = avg.filter((obj) => (date_in_ms - obj.date) < min_ms);
    
    if(avg.length === 0)
      return;
    
    // Compute the average of the array
    const sum = avg.reduce((a,b) => a + b.value, avg[0].value);
    out1.value = sum / avg.length;
  }
}
