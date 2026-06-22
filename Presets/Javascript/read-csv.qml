// @documentation https://ossia.io/score-docs/processes/javascript/read-csv.html
import Score 1.0

Script {
  LineEdit { 
    id: filepath
    objectName: "File path"
  }
  LineEdit { 
    id: sep
    objectName: "Separator"
    text: ","
  }
  IntSpinBox { id: row; min: -1; max: 10000000; objectName: "Row" }
  IntSpinBox { id: column; min: -1; max: 10000000; objectName: "Column" }
  ValueOutlet { id: output }
  
  property var csv: Util.readFile(filepath.value)
  property var table: splitData(csv, sep.value)
  
  function splitData(buffer, separator) 
  {
    const uint8Array = new Uint8Array(buffer);
    const len = uint8Array.length;
    const sepCode = separator.charCodeAt(0);
    const quoteCode = 34; // "
    const lfCode = 10;    // \n
    const crCode = 13;    // \r
    const emptyRow = [ String.fromCharCode(0) ];
    
    const rows = [];
    let row = [];
    let cellBytes = [];
    let i = 0;
    let inQuotes = false;
    
    while (i < len) {
      const b = uint8Array[i];
      const nextByte = uint8Array[i + 1];
      
      if (inQuotes) {
        if (b === quoteCode) {
          if (nextByte === quoteCode) {
            // Escaped quote
            cellBytes.push(quoteCode);
            i += 2;
            continue;
          }
          // End quote
          inQuotes = false;
          i++;
          continue;
        }
        cellBytes.push(b);
        i++;
      } else {
        if (b === quoteCode) {
          inQuotes = true;
          i++;
        } else if (b === sepCode) {
          row.push(String.fromCharCode.apply(null, cellBytes));
          cellBytes = [];
          i++;
        } else if (b === lfCode) {
          if(cellBytes.length > 0 || row.length > 0) {
            row.push(String.fromCharCode.apply(null, cellBytes));
            if (row.length > 0) 
              rows.push(row);
          }
          row = [];
          cellBytes = [];
          i++;
          // Skip \r if present (CRLF)
          if (uint8Array[i] === crCode) i++;
        } else if (b === crCode) {
          if(cellBytes.length > 0 || row.length > 0) {
            row.push(String.fromCharCode.apply(null, cellBytes));
            if (row.length > 0) 
              rows.push(row);
          }
          row = [];
          cellBytes = [];
          i++;
          // Skip \n if present (CRLF)
          if (uint8Array[i] === lfCode) i++;
        } else {
          cellBytes.push(b);
          i++;
        }
      }
    }
    
    // Handle last cell and row
    if (cellBytes.length > 0 || row.length > 0) {
      row.push(String.fromCharCode.apply(null, cellBytes));
      if (row.length > 0 && row !== emptyRow) rows.push(row);
    }
    
    return rows;
  }
  
  
  tick: function(token, state) {
    const r = row.value;
    const c = column.value;
    if(r === -1) {
      output.value = table;
    }
    else if(r >= 0 && r < table.length) {
      if(c === -1)
        output.value = table[r];
      else if(c >= 0 && c < table[r].length)
        output.value = table[r][c];
      else
        output.value = "";
    }
    else {
      if(c === -1)
        output.value = [ ];
      else
        output.value = "";
    }
  }
}

