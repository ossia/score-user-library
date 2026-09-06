.pragma library

function clone(value) { return JSON.parse(JSON.stringify(value)); }
function stateById(doc, id) {
    for (var i = 0; i < doc.states.length; ++i)
        if (doc.states[i].id === id) return doc.states[i];
    return null;
}
function objectById(state, id) {
    if (state) for (var i = 0; i < state.objects.length; ++i)
        if (state.objects[i].id === id) return state.objects[i];
    return null;
}
function newId(doc, prefix) { return prefix + (doc.nextId++); }
function makeState(doc, name) {
    return { id: newId(doc, "s"), name: name, color: "#17232b", image: "", fit: "fit", objects: [] };
}
function makeObject(doc, type) {
    return { id: newId(doc, "o"), type: type, label: type === "button" ? "Button" : type === "hotspot" ? "Hotspot" : type === "label" ? "Label" : "Image",
        x: 480, y: 300, w: type === "image" ? 320 : 240, h: type === "image" ? 220 : 80,
        fill: "#c58014", textColor: "#ffffff", borderColor: "#e0a54d", borderWidth: 1,
        radius: 8, fontSize: 28, opacity: 1, image: "", fit: "fit", target: "", action: "" };
}
function defaultDoc() {
    var d = { version: 1, width: 1280, height: 720, nextId: 1, initial: "", states: [] };
    var home = makeState(d, "Home"), detail = makeState(d, "Details");
    d.states.push(home, detail); d.initial = home.id;
    var title = makeObject(d, "label"); title.label = "Collection";
    title.x = 160; title.y = 180; title.w = 960; title.h = 90; title.fontSize = 48;
    var forward = makeObject(d, "button"); forward.label = "View details"; forward.target = detail.id; forward.action = "details";
    forward.x = 480; forward.y = 360; forward.w = 320;
    home.objects.push(title, forward);
    var heading = makeObject(d, "label"); heading.label = "Details"; heading.x = 160; heading.y = 180; heading.w = 960; heading.h = 90; heading.fontSize = 48;
    var back = makeObject(d, "button"); back.label = "Back"; back.target = "@back"; back.action = "back";
    back.x = 480; back.y = 360; back.w = 320;
    detail.objects.push(heading, back);
    return d;
}
function parse(value) {
    // Undoing the first saved edit removes panelDoc from the process state.
    if (value === undefined || value === null || value === "") return defaultDoc();
    var d = typeof value === "string" ? JSON.parse(value) : clone(value);
    if (!d || d.version !== 1 || !Array.isArray(d.states) || !d.states.length)
        throw new Error("Unsupported or empty panel document");
    if (!isFinite(d.width) || !isFinite(d.height) || d.width < 64 || d.height < 64)
        throw new Error("Invalid canvas dimensions");
    var ids = {}, maximum = 0;
    function checkId(id) {
        if (typeof id !== "string" || !id.length || id === "@back" || ids[id]) throw new Error("Invalid or duplicate ID");
        ids[id] = true;
        var n = parseInt(id.substring(1), 10); if (isFinite(n)) maximum = Math.max(maximum, n);
    }
    d.states.forEach(function(s) {
        checkId(s.id);
        if (typeof s.name !== "string" || !Array.isArray(s.objects)) throw new Error("Invalid state");
        s.objects.forEach(function(o) {
            checkId(o.id);
            if (["button", "hotspot", "label", "image"].indexOf(o.type) < 0) throw new Error("Invalid object type");
            if (![o.x, o.y, o.w, o.h].every(function(n) { return typeof n === "number" && isFinite(n); }) || o.w <= 0 || o.h <= 0)
                throw new Error("Invalid object geometry");
            constrain(d, o);
        });
    });
    d.nextId = Math.max(maximum + 1, Math.floor(d.nextId) || 1);
    if (!stateById(d, d.initial)) d.initial = d.states[0].id;
    d.states.forEach(function(s) { s.objects.forEach(function(o) {
        if (o.target && o.target !== "@back" && !stateById(d, o.target)) o.target = "";
    }); });
    return d;
}
function constrain(d, o) {
    o.w = isFinite(o.w) ? Math.max(8, o.w) : 8;
    o.h = isFinite(o.h) ? Math.max(8, o.h) : 8;
    if (!isFinite(o.x)) o.x = 0;
    if (!isFinite(o.y)) o.y = 0;
}
function hit(state, x, y, editing) {
    if (!state) return null;
    for (var i = state.objects.length - 1; i >= 0; --i) {
        var o = state.objects[i];
        if (!editing && o.type !== "button" && o.type !== "hotspot" && !o.target && !o.action) continue;
        if (x >= o.x && y >= o.y && x <= o.x + o.w && y <= o.y + o.h) return o;
    }
    return null;
}

// Pure navigation shared by the rendered panel and the transport-independent preview.
function transition(doc, state, history, command) {
    var result = { state: state, history: history, event: null, error: "" };
    function navigate(id, remember) {
        if (!stateById(doc, id)) return;
        if (result.state !== id) {
            if (remember) result.history = result.history.concat([result.state]);
            result.state = id;
        }
    }
    function back() {
        if (!result.history.length) return;
        var id = result.history[result.history.length - 1];
        result.history = result.history.slice(0, -1);
        navigate(id, false);
    }
    if (command && typeof command === "object") {
        if (command.command === "back") { back(); return result; }
        if (command.command === "reset") {
            result.history = []; navigate(doc.initial, false); return result;
        }
        if (command.activate) {
            var object = objectById(stateById(doc, state), String(command.activate));
            if (!object) return result;
            if (object.target === "@back") back();
            else if (object.target) navigate(object.target, true);
            result.event = { state: state, zone: object.id, action: object.action || "", target: result.state };
            return result;
        }
        command = command.state;
    }
    if (typeof command !== "string") return result;
    if (stateById(doc, command)) navigate(command, true);
    else {
        var matches = doc.states.filter(function(s) { return s.name === command; });
        if (matches.length === 1) navigate(matches[0].id, true);
        else result.error = "Unknown or ambiguous state: " + command;
    }
    return result;
}
