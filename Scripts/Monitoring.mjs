/**
 * Add or remove monitors directly connected to the selected processes' outputs.
 * Add one monitor per output; choose Value or Signal display for messages.
 * New monitors form a column beside the source, in output order.
 * Existing monitors are reused; each action is a single undoable macro.
 */

// Process::PortType: Message = 0, Audio = 1, Midi = 2, Texture = 3.
// UUIDs, unlike labels and object names, identify renamed monitors reliably.
const valueDisplay = { id: "3f4a41f2-fa39-420f-ab0f-0af6b8409edb", name: "Value display", type: 0, compact: true };
const signalDisplay = { id: "9906e563-ddeb-4ecd-908c-952baee2a0a5", name: "Signal display", type: 0, compact: true };
const monitors = [
  valueDisplay,
  signalDisplay,
  { id: "c618774d-086f-4888-8404-23b6e59440f8", name: "LED View", type: 0 },
  { id: "898078f0-b825-4c29-a997-dc856e351a97", name: "Point2D View", type: 0 },
  { id: "67bab0b4-0141-4474-bb11-57f2751a76ad", name: "Pulse View", type: 0 },
  { id: "0d0a3152-8ee9-4472-8a97-457b8bd6e56a", name: "VU Meter", type: 1, automatic: true },
  { id: "a2b6c7f1-3d54-4e9a-9c21-8f0d5e73b104", name: "MIDI display", type: 2, automatic: true },
  { id: "0e64750a-d014-44d9-9a4e-919d4305af1a", name: "Lightness sampler", type: 3, automatic: true }
];
const samplerId = "0e64750a-d014-44d9-9a4e-919d4305af1a";

export function initialize() {
  // A direct position assignment would be lost when creation is redone.
  Score.registerCommandHandler("Monitoring.position", state => {
    const process = Score.findByPath(state.path);
    if (process)
      process.position = Qt.point(state.x, state.y);
  });
  Score.registerCommandHandler("Monitoring.size", state => {
    const process = Score.findByPath(state.path);
    if (process)
      process.size = Qt.size(state.width, state.height);
  });
}

function selectedProcesses() {
  const result = new Set();
  for (const object of Score.selectedObjects()) {
    const process = Score.parentProcess(object);
    if (process)
      result.add(process);
  }
  return result;
}

function processId(process) {
  return JSON.parse(Score.savePreset(process)).Key.Uuid.toLowerCase();
}

// Only the main data inlet counts: driving a display's range or format is
// not the same as monitoring the source with that display.
function connectedMonitors(outlet) {
  const result = new Map();
  for (let i = 0; i < Score.cables(outlet); ++i) {
    const inlet = Score.sink(Score.cable(outlet, i));
    const process = Score.parentProcess(inlet);
    if (process && inlet === Score.inlet(process, 0)) {
      const id = processId(process);
      if (monitors.some(monitor => monitor.id === id))
        result.set(process, id);
    }
  }
  return result;
}

function compactDisplay(view, id) {
  if (!monitors.some(monitor => monitor.id === id && monitor.compact)
      || view.size.height === 20)
    return;
  const path = Score.path(view);
  const width = view.size.width;
  Score.pushCommand("Monitoring.size",
      { path, width, height: view.size.height },
      { path, width, height: 20 });
}

function addMonitors(messageMonitor) {
  const selected = selectedProcesses();
  const available = Score.availableProcesses();
  Score.withMacro(() => {
    for (const process of selected) {
      const interval = Score.parentInterval(process);
      if (!interval)
        continue;
      const x = process.position.x + process.size.width + 40;
      let y = process.position.y;
      for (let i = 0; i < Score.outlets(process); ++i) {
        const outlet = Score.outlet(process, i);
        const monitor = outlet.type === 0 ? messageMonitor
            : monitors.find(monitor => monitor.automatic && monitor.type === outlet.type);
        if (!monitor)
          continue;
        const existing = connectedMonitors(outlet);
        if (existing.size > 0) {
          // An existing specialized view also counts; do not add a generic one.
          let step = 0;
          for (const [view, id] of existing) {
            compactDisplay(view, id);
            const compact = monitors.find(monitor => monitor.id === id).compact;
            step = Math.max(step, view.size.height + (compact ? 8 : 24));
          }
          y += step;
          continue;
        }
        if (!available[monitor.id]) {
          console.log("Monitoring: unavailable process: " + monitor.name);
          continue;
        }
        const view = Score.createProcess(interval, monitor.id, "");
        if (!view)
          throw new Error("Monitoring: could not create " + monitor.name);
        if (!Score.createCable(outlet, Score.inlet(view, 0))) {
          Score.remove(view);
          throw new Error("Monitoring: could not connect " + monitor.name);
        }
        compactDisplay(view, monitor.id);
        const path = Score.path(view);
        Score.pushCommand("Monitoring.position",
            { path, x: view.position.x, y: view.position.y },
            { path, x, y });
        // Include the frame and antialiasing, leaving one visible background pixel.
        y += view.size.height + (monitor.compact ? 8 : 24);
      }
    }
  });
}

export function addMonitoring() {
  addMonitors(valueDisplay);
}

export function addSignalMonitoring() {
  addMonitors(signalDisplay);
}

// AddressAccessor is an opaque QVariant in JS: even JSON.stringify(address)
// yields an empty string for a configured address. Inspect persisted ports
// instead. ObjectName/id ancestry gives the same paths as Score.path().
function samplerPorts() {
  const result = new Map();
  function visit(object, path) {
    if (!object || typeof object !== "object")
      return;
    if (typeof object.ObjectName === "string" && object.id !== undefined)
      path += object.ObjectName + "." + object.id + "/";
    if (object.uuid === samplerId) {
      result.set(path, object.Inlets);
      return;
    }
    for (const key of Object.keys(object))
      visit(object[key], path);
  }
  visit(JSON.parse(Score.serializeAsJson()).Document, "");
  return result;
}

function unusedSampler(process, ports) {
  const positions = Score.inlet(process, 1);
  if (!positions || Score.cables(positions) !== 0)
    return false;
  const inlets = ports.get(Score.path(process));
  if (!inlets || !inlets[1])
    return false; // Unknown serialization must never authorize deletion.
  const saved = inlets[1];
  // Positions is currently a plain ValueInlet, with no stored value. Preserve
  // any value/init too if a document has a control inlet in its place.
  return saved.Address === undefined
      && (saved.Value === undefined || Object.keys(saved.Value).length === 0)
      && (saved.Init === undefined || Object.keys(saved.Init).length === 0);
}

export function removeMonitoring() {
  const selected = selectedProcesses();
  const candidates = new Map();
  for (const process of selected) {
    for (let i = 0; i < Score.outlets(process); ++i) {
      for (const [view, id] of connectedMonitors(Score.outlet(process, i))) {
        if (!selected.has(view))
          candidates.set(view, id);
      }
    }
  }
  // Snapshot before deleting anything: removal invalidates QObject wrappers
  // and changes cable indices. A shared monitor must only be removed once.
  const ports = Array.from(candidates.values()).includes(samplerId)
      ? samplerPorts() : new Map();
  const removable = [];
  for (const [view, id] of candidates) {
    if (id !== samplerId || unusedSampler(view, ports))
      removable.push(view);
  }
  Score.withMacro(() => {
    for (const view of removable)
      Score.remove(view);
  });
}

export const actions = [
  { name: "Monitoring/Add value output monitors"
  , context: ActionContext.Menu
  , shortcut: "Alt+M, V"
  , action: addMonitoring
  },
  { name: "Monitoring/Add signal output monitors"
  , context: ActionContext.Menu
  , shortcut: "Alt+M, S"
  , action: addSignalMonitoring
  },
  { name: "Monitoring/Remove output monitors"
  , context: ActionContext.Menu
  , shortcut: "Alt+Shift+M"
  , action: removeMonitoring
  }
];
