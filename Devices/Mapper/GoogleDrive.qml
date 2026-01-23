import Ossia 1.0 as Ossia

Ossia.Mapper
{
  id: root
  property string folderId: "" // Set this to a specific Folder ID to scope operations

  property var auth: Ossia.OAuth {
    id: oauth
    authorizationUrl: "https://accounts.google.com/o/oauth2/auth"
    accessTokenUrl: "https://oauth2.googleapis.com/token"

    clientIdentifier: ""
    clientIdentifierSharedKey: ""

    requestedScopeTokens: [ "https://www.googleapis.com/auth/drive" ]
    onTokenChanged: function(token) {
      Device.write("/status/authorized", token !== "");
    }
  }

  function findFileId(name, callback) {
    var query = "name = '" + name + "' and trashed = false";
    if (folderId !== "") {
      query += " and '" + folderId + "' in parents";
    }

    var url = "https://www.googleapis.com/drive/v3/files?q=" + encodeURIComponent(query);

    oauth.send("GET", url, {}, function(resp, err) {
      if (err) {
        console.error("Search failed:", err.message);
        callback(null);
      } else if (resp.files && resp.files.length > 0) {
        callback(resp.files[0].id);
      } else {
        callback(null);
      }
    });
  }

  function upload(file_name, file_url)
  {
    var driveUrl = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart";

    // Construct parents list if folderId is set
    var metadata = { "name": file_name };
    if (folderId !== "") {
      metadata.parents = [ folderId ];
    }

    var config = {
      body: {
        type: "related",
        parts: [
          {
            headers: { "Content-Type": "application/json; charset=UTF-8" },
            data: JSON.stringify(metadata)
          },
          {
            headers: { "Content-Type": "application/octet-stream" },
            file: file_url
          }
        ]
      }
    };

    oauth.send("POST", driveUrl, config, function(response, error) {
      if (error) console.error("Upload failed:", error.message);
      else console.log("Upload Success! ID:", response.id);
    });
  }

  function read_file(file_name)
  {
    console.log("Reading:", file_name);
    findFileId(file_name, function(id) {
      if (!id) {
        console.error("File not found:", file_name);
        return;
      }

      // alt=media tells Google to download the file content, not the JSON metadata
      var url = "https://www.googleapis.com/drive/v3/files/" + id + "?alt=media";

      oauth.send("GET", url, {}, function(response, error) {
        if (error) {
          console.error("Read failed:", error.message);
        } else {
          const content = (typeof response === 'object') ? JSON.stringify(response) : response;
          Device.write("/data/text", content);
        }
      });
    });
  }

  function write_file(file_name, content)
  {
    findFileId(file_name, function(id) {
      if (id) {
        // --- UPDATE EXISTING FILE (PATCH) ---
        var url = "https://www.googleapis.com/upload/drive/v3/files/" + id + "?uploadType=media";
        console.log("Updating existing file:", id);

        var config = {
          headers: { "Content-Type": "text/plain" },
          body: content
        };

        oauth.send("PATCH", url, config, function(resp, err) {
          if (err) console.error("Update failed:", err.message);
          else console.log("Update Success!");
        });

      } else {
        // --- CREATE NEW FILE (POST) ---
        // Ideally we use multipart to set name + content, but simple uploadType=media
        // defaults name to "Untitled". We must use Multipart to set name correctly in one go.
        console.log("Creating new file:", file_name);

        var url = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart";

        var metadata = { "name": file_name, "mimeType": "text/plain" };
        if (folderId !== "") metadata.parents = [ folderId ];

        var config = {
          body: {
            type: "related",
            parts: [
              {
                headers: { "Content-Type": "application/json" },
                data: JSON.stringify(metadata)
              },
              {
                headers: { "Content-Type": "text/plain" },
                data: content
              }
            ]
          }
        };

        oauth.send("POST", url, config, function(resp, err) {
          if (err) console.error("Write failed:", err.message);
          else console.log("Write Success! ID:", resp.id);
        });
      }
    });
  }

  function createTree() {
    return [
          {
            name: "commands",
            children: [
              {
                name: "auth",
                type: Ossia.Type.Impulse,
                description: "Opens auth request",
                write: function(v) { oauth.grant(); }
              },
              {
                name: "client_id",
                type: Ossia.Type.String,
                value: "",
                description: "Client identifier",
                write: function(v) {
                  v = Device.toValue(v);
                  oauth.clientIdentifier = v;
                }
              },
              {
                name: "client_secret",
                type: Ossia.Type.String,
                value: "",
                description: "Client secret key",
                write: function(v) {
                  v = Device.toValue(v);
                  oauth.clientIdentifierSharedKey = v;
                }
              },
              {
                name: "token",
                type: Ossia.Type.String,
                value: "",
                description: "Set an explicit token",
                write: function(v) {
                  v = Device.toValue(v);
                  oauth.token = v;
                }
              },
              {
                name: "folder_id",
                type: Ossia.Type.String,
                value: "",
                description: "Optional Google Drive Folder ID to scope operations",
                write: function(v) {
                  v = Device.toValue(v);
                  folderId = v;
                }
              },
              {
                name: "upload_file",
                type: Ossia.Type.List,
                description: "[filename, file_url] - Uploads a local file",
                write: function(v) {
                  v = Device.toValue(v);
                  if (v.length >= 2) upload(v[0], v[1]);
                  else console.error("Upload requires [name, url]");
                }
              },
              {
                name: "write_text",
                type: Ossia.Type.List,
                description: "[filename, text_content] - Writes text directly",
                write: function(v) {
                  v = Device.toValue(v);
                  if (v.length >= 2) write_file(v[0], v[1]);
                  else console.error("Write requires [name, content]");
                }
              },
              {
                name: "read_text",
                type: Ossia.Type.String,
                value: "",
                description: "filename - Downloads content to console",
                write: function(v) {
                  v = Device.toValue(v);
                  read_file(v);
                }
              }
            ]

          },

          {
            name: "status",
            children: [
              {
                name: "authorized",
                type: Ossia.Type.Bool,
                description: "True if auth was granted",
                value: false
              }
            ]
          },

          {
            name: "data",
            children: [
              {
                name: "text",
                type: Ossia.Type.String,
                description: "Data read from read_text",
                value: ""
              }
            ]
          }
        ];
  }
}
