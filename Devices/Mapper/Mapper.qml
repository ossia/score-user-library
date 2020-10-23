import Ossia 1.0 as Ossia

Ossia.Mapper
{
    function createTree() {
        return [
        {
            name: "node",
            children: [
                {
                    name: "sensor",
                    bind: "MidiDevice:/1/control/8",
                    type: Ossia.Type.Int

                    // this node == midi:/foo/bar
                },
                {
                    name: "sensor2",
                    bind: "MidiDevice:/1/control/7",
                    type: Ossia.Type.Float,

                    // this node == MidiDevice:/1/control/7 in [0; 1]
                    read: function(orig, v) { return v.value + 1000.; },
                    write: function(v) { return v.value - 1000.; }
                },
                {
                    name: "name",
                    type: Ossia.Type.String,

                    // when writing to this node, this sends the following :
                    write: function(v) {
                        return [ { address: "foo:/bob", value : v.value.length } ];
                    }
                },
                {
                    name: "other",
                    type: Ossia.Type.Int,
                    bind: ["foo:/bar", "foo:/baz"],

                    // when a message is received on either bound nodes, this
                    // is called and the returned objects are applied to the tree
                    read: function(orig, v) {
                        return v.value + 10;
                    },
                    write: function(v) {
                        // applied to foo:/bar ; foo:/baz
                        return [ v.value + 100, v.value - 100 ];
                    }
                }
            ]
        }
        ];
    }
}
