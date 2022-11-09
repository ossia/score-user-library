import Score 1.0
import 'total-serialism.js' as Serialism

Script { 
  Impulse { objectName: "Recompute"; onImpulse: recompute(); }
  ValueOutlet { id: out1 } 
  IntSlider { id: root; objectName: "root"; min: 0; max: 127; init: 44; onValueChanged: recompute() }   
  
  IntSlider { id: da; objectName: "da"; min: 0; max: 32; init: 9; onValueChanged: recompute() }
  IntSlider { id: db; objectName: "db"; min: 0; max: 32; init: 4; onValueChanged: recompute() }
  IntSlider { id: dc; objectName: "dc"; min: 0; max: 32; init: 0; onValueChanged: recompute() }
  IntSlider { id: dd; objectName: "dd"; min: 0; max: 32; init: 12; onValueChanged: recompute() }
  IntSlider { id: de; objectName: "de"; min: 0; max: 32; init: 6; onValueChanged: recompute() }

  IntSlider { id: e1a; objectName: "e1a"; min: 0; max: 32; init: 16; onValueChanged: recompute() }
  IntSlider { id: e1b; objectName: "e1b"; min: 0; max: 32; init: 5; onValueChanged: recompute() }
  IntSlider { id: e1c; objectName: "e1c"; min: 0; max: 32; init: 0; onValueChanged: recompute() }
  
  IntSlider { id: e2a; objectName: "e2a"; min: 0; max: 32; init: 11; onValueChanged: recompute() }
  IntSlider { id: e2b; objectName: "e2b"; min: 0; max: 32; init: 3; onValueChanged: recompute() }
  IntSlider { id: e2c; objectName: "e2c"; min: 0; max: 32; init: 2; onValueChanged: recompute() }
  
  function recompute() {
     const Rand = Serialism.Stochastic;
     const Algo = Serialism.Algorithmic;
     const Util = Serialism.Utility;

     // [ 35, 46, 45, ... ]
     const notes = Rand.drunk(da.value, db.value, dc.value, dd.value, de.value, false);
 
     // [ 1, 0, 0, 1, 0, 1, 2, 0 ]

     const rhythm = Util.constrain(Util.add(
        Algo.euclid(e1a.value, e1b.value, e1c.value), 
        Algo.euclid(e2a.value, e2b.value, e2c.value) 
        ), 0, 127);

     // Sequence of notes, one per subdividion
     // [
     //   [ [ 36, 127 ] ], 
     //   [ ]  
     //   [ [ 38, 127 ], [ 42, 64 ] ],
     //   [ [ ] ]
     // ]
     let ret = [];
     for(let i = 0; i < rhythm.length; i++)
     {
        if(rhythm[i] > 0)
        {
          ret.push([ [ root.value + notes[i % notes.length], 127 ] ]);
        }
        else
        {
          ret.push([]);
        }
     }
     console.log(ret);
     
     out1.value = ret;
  }
  
  tick: function(token, state) { }
}