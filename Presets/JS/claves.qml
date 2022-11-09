import Score 1.0
import 'total-serialism.js' as Serialism

Script { 
  Impulse { objectName: "Recompute"; onImpulse: recompute(); }
  ValueOutlet { id: out1 } 
  IntSlider { id: c1len; objectName: "C1 len"; min: 1; max: 32; init: 8; onValueChanged: recompute() }   
  IntSlider { id: c1gap; objectName: "C1 gap"; min: 1; max: 16; init: 3; onValueChanged: recompute()  }  
  IntSlider { id: c1not; objectName: "C1 note"; min: 0; max: 127; init: 35; onValueChanged: recompute()  }
  IntSlider { id: c2len; objectName: "C2 len"; min: 1; max: 32; init: 8; onValueChanged: recompute() }  
  IntSlider { id: c2gap; objectName: "C2 gap"; min: 1; max: 16; init: 2; onValueChanged: recompute() }
  IntSlider { id: c2not; objectName: "C2 note"; min: 0; max: 127; init: 36; onValueChanged: recompute()  }
  IntSlider { id: c3len; objectName: "C3 len"; min: 1; max: 32; init: 8; onValueChanged: recompute() }  
  IntSlider { id: c3gap; objectName: "C3 gap"; min: 1; max: 16; init: 4; onValueChanged: recompute() }
  IntSlider { id: c3not; objectName: "C3 note"; min: 0; max: 127; init: 38; onValueChanged: recompute()  }
  IntSlider { id: c4len; objectName: "C4 len"; min: 1; max: 32; init: 16; onValueChanged: recompute() }  
  IntSlider { id: c4gap; objectName: "C4 gap"; min: 1; max: 16; init: 3; onValueChanged: recompute() }
  IntSlider { id: c4not; objectName: "C4 note"; min: 0; max: 127; init: 42; onValueChanged: recompute()  }
  IntSlider { id: c5len; objectName: "C5 len"; min: 1; max: 32; init: 16; onValueChanged: recompute() }  
  IntSlider { id: c5gap; objectName: "C5 gap"; min: 1; max: 16; init: 6; onValueChanged: recompute() }
  IntSlider { id: c5not; objectName: "C5 note"; min: 0; max: 127; init: 44; onValueChanged: recompute()  }

  function recompute() {
     let Rand = Serialism.Stochastic;
     
     out1.value = [
      [c1not.value, Rand.clave(c1len.value, c1gap.value)],
      [c2not.value, Rand.clave(c2len.value, c2gap.value)],
      [c3not.value, Rand.clave(c3len.value, c3gap.value)],
      [c4not.value, Rand.clave(c4len.value, c4gap.value)],
      [c5not.value, Rand.clave(c5len.value, c5gap.value)],
      ];
  }
  
  tick: function(token, state) { }
}