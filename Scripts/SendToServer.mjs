/**
 * This script exports the current Score document to a remote HTTP server.
 * It serializes the score as JSON, converts it to base64, and sends it via POST request.
 */

function exportToHttpServer()
{
  const res = Score.prompt({
    title: "Export to HTTP Server",
    widgets: [
      { name:"Server", type: "lineedit", init: "http://127.0.0.1:8080" },
      { name:"Description", type: "label", init: "This will serialize the current score and send it to the server" }
    ]
  });

  if (res === undefined) {
    return;
  }

  if (res[0].length === 0) {
    console.log("Server address cannot be empty");
    return;
  }

  const serverUrl = res[0];

  try {
    // Get the serialized JSON data from Score
    const jsonData = Score.serializeAsJson();

    if (!jsonData || jsonData.length === 0) {
      console.log("No data to export - the score appears to be empty");
      return;
    }

    // Convert QByteArray to base64 string
    const base64Data = Qt.btoa(jsonData);

    // Create HTTP request
    const xhr = new XMLHttpRequest();

    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          console.log("Export successful: " + xhr.responseText);
        } else {
          console.log("Export failed: HTTP " + xhr.status + " - " + xhr.responseText);
        }
      }
    };

    xhr.onerror = function() {
      console.log("Network error: Could not connect to server at " + serverUrl);
    };

    xhr.ontimeout = function() {
      console.log("Request timeout: Server did not respond in time");
    };

    // Configure and send the request
    xhr.open("POST", serverUrl, true);
    xhr.setRequestHeader("Content-Type", "text/plain");
    xhr.timeout = 10000; // 10 second timeout

    console.log("Sending data to " + serverUrl + "...");
    xhr.send(base64Data);

  } catch (error) {
    console.log("Error during export: " + error.toString());
  }
}

function testConnection()
{
  const res = Score.prompt({
    title: "Test Server Connection",
    widgets: [
      { name:"Server", type: "lineedit", init: "http://127.0.0.1:8080" }
    ]
  });

  if (res === undefined) {
    return;
  }

  if (res[0].length === 0) {
    console.log("Server address cannot be empty");
    return;
  }

  const serverUrl = res[0];

  try {
    // Send a simple test with "hello world" encoded in base64
    const testData = Qt.btoa("Hello World from Score!");

    const xhr = new XMLHttpRequest();

    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          console.log("Connection test successful! Server responded: " + xhr.responseText);
        } else {
          console.log("Connection test failed: HTTP " + xhr.status + " - " + xhr.responseText);
        }
      }
    };

    xhr.onerror = function() {
      console.log("Connection test failed: Could not connect to server at " + serverUrl);
    };

    xhr.ontimeout = function() {
      console.log("Connection test failed: Server timeout");
    };

    xhr.open("POST", serverUrl, true);
    xhr.setRequestHeader("Content-Type", "text/plain");
    xhr.timeout = 5000; // 5 second timeout for test

    console.log("Testing connection to " + serverUrl + "...");
    xhr.send(testData);

  } catch (error) {
    console.log("Connection test error: " + error.toString());
  }
}

export function initialize() {
  // This will be called when the module is loaded.
  console.log("HTTP Export module loaded");
}

// This is used to register actions in the Scripts menu in score
export const actions = [
 { name: "Export/Send to HTTP Server"
 , context: ActionContext.Menu
 , action: exportToHttpServer
 }
]
