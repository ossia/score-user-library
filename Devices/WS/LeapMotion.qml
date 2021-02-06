import Ossia 1.0 as Ossia

Ossia.WebSockets
{
    property string host: "ws://localhost:6437"
    
    // Called recursively to translate JSON in score name space
    function parseObj(obj, prefix = '') {
        var output = [];
        
        for (var o in obj) {
            var nameSpace = prefix + '/' + o;
            
            if (typeof(obj[o]) == "object") {                
                output = output.concat(parseObj(obj[o], nameSpace));
            } else {
                var out = { address: nameSpace, value: obj[o] };
                
                output.push(out);
            }
        }
        
        return output;
    }
    
    // Called whenever the Websocket server sends us a message
    function onMessage(message) {
        var obj = JSON.parse(message);
        
        return parseObj(obj);
    }
    
    function createTree() {
        return [
        {
            name : "currentFrameRate",
            type : Ossia.Type.Float
        },
        {
            name : "hands",
            children: [
            {
                name : "0",
                children : [
                {
                    name : "direction",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "id",
                    type : Ossia.Type.Int
                }, 
                {
                    name : "palmNormal",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                }, 
                {
                    name : "palmPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                }, 
                {
                    name : "palmVelocity",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "r",
                    children : [
                    {
                        name : "0",
                        children : [
                        {
                            name : "0",
                            type : Ossia.Type.Float
                        },
                        {
                            name : "1",
                            type : Ossia.Type.Float
                        },
                        {
                            name : "2",
                            type : Ossia.Type.Float
                        }
                        ]
                    },
                    {
                        name : "1",
                        children : [
                        {
                            name : "0",
                            type : Ossia.Type.Float
                        },
                        {
                            name : "1",
                            type : Ossia.Type.Float
                        },
                        {
                            name : "2",
                            type : Ossia.Type.Float
                        }
                        ]
                    },
                    {
                        name : "2",
                        children : [
                        {
                            name : "0",
                            type : Ossia.Type.Float
                        },
                        {
                            name : "1",
                            type : Ossia.Type.Float
                        },
                        {
                            name : "2",
                            type : Ossia.Type.Float
                        }
                        ]
                    }
                    ]
                },
                {
                    name : "s",
                    type : Ossia.Type.Float
                },
                {
                    name : "sphereCenter",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "sphereRadius",
                    type : Ossia.Type.Float
                },
                {
                    name : "stabilizedPalmPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "t",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "timeVisible",
                    type : Ossia.Type.Float
                },
                ]
            }
            ]
        },
        {
            name : "id",
            type : Ossia.Type.Int
        },
        {
            name : "interactionBox",
            children: [
            {
                name : "center",
                children : [
                {
                    name : "0",
                    type : Ossia.Type.Float
                },
                {
                    name : "1",
                    type : Ossia.Type.Float
                },
                {
                    name : "2",
                    type : Ossia.Type.Float
                }
                ]
            },
            {
                name : "size",
                children : [
                {
                    name : "0",
                    type : Ossia.Type.Float
                },
                {
                    name : "1",
                    type : Ossia.Type.Float
                },
                {
                    name : "2",
                    type : Ossia.Type.Float
                }
                ]
            }
            ]
        },
        {
            name : "pointables",
            children: [
            {
                name : "0",
                children : [
                {
                    name : "direction",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "handId",
                    type : Ossia.Type.Int
                },
                {
                    name : "id",
                    type : Ossia.Type.Int
                },
                {
                    name : "length",
                    type : Ossia.Type.Float
                },
                {
                    name : "stabilizedTipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "timeVisible",
                    type : Ossia.Type.Float
                },
                {
                    name : "tipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                }, 
                {
                    name : "tipVelocity",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "tool",
                    type : Ossia.Type.Bollean
                },
                {
                    name : "touchDistance",
                    type : Ossia.Type.Float
                },
                {
                    name : "touchZone",
                    type : Ossia.Type.String
                },
                {
                    name : "width",
                    type : Ossia.Type.Float
                }
                ]
            },
            {
                name : "1",
                children : [
                {
                    name : "direction",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "handId",
                    type : Ossia.Type.Int
                },
                {
                    name : "id",
                    type : Ossia.Type.Int
                },
                {
                    name : "length",
                    type : Ossia.Type.Float
                },
                {
                    name : "stabilizedTipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "timeVisible",
                    type : Ossia.Type.Float
                },
                {
                    name : "tipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                }, 
                {
                    name : "tipVelocity",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "tool",
                    type : Ossia.Type.Bollean
                },
                {
                    name : "touchDistance",
                    type : Ossia.Type.Float
                },
                {
                    name : "touchZone",
                    type : Ossia.Type.String
                },
                {
                    name : "width",
                    type : Ossia.Type.Float
                }
                ]
            },
            {
                name : "2",
                children : [
                {
                    name : "direction",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "handId",
                    type : Ossia.Type.Int
                },
                {
                    name : "id",
                    type : Ossia.Type.Int
                },
                {
                    name : "length",
                    type : Ossia.Type.Float
                },
                {
                    name : "stabilizedTipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "timeVisible",
                    type : Ossia.Type.Float
                },
                {
                    name : "tipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                }, 
                {
                    name : "tipVelocity",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "tool",
                    type : Ossia.Type.Bollean
                },
                {
                    name : "touchDistance",
                    type : Ossia.Type.Float
                },
                {
                    name : "touchZone",
                    type : Ossia.Type.String
                },
                {
                    name : "width",
                    type : Ossia.Type.Float
                }
                ]
            },
            {
                name : "3",
                children : [
                {
                    name : "direction",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "handId",
                    type : Ossia.Type.Int
                },
                {
                    name : "id",
                    type : Ossia.Type.Int
                },
                {
                    name : "length",
                    type : Ossia.Type.Float
                },
                {
                    name : "stabilizedTipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "timeVisible",
                    type : Ossia.Type.Float
                },
                {
                    name : "tipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                }, 
                {
                    name : "tipVelocity",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "tool",
                    type : Ossia.Type.Bollean
                },
                {
                    name : "touchDistance",
                    type : Ossia.Type.Float
                },
                {
                    name : "touchZone",
                    type : Ossia.Type.String
                },
                {
                    name : "width",
                    type : Ossia.Type.Float
                }
                ]
            },
            {
                name : "4",
                children : [
                {
                    name : "direction",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "handId",
                    type : Ossia.Type.Int
                },
                {
                    name : "id",
                    type : Ossia.Type.Int
                },
                {
                    name : "length",
                    type : Ossia.Type.Float
                },
                {
                    name : "stabilizedTipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "timeVisible",
                    type : Ossia.Type.Float
                },
                {
                    name : "tipPosition",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                }, 
                {
                    name : "tipVelocity",
                    children : [
                    {
                        name : "0",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "1",
                        type : Ossia.Type.Float
                    },
                    {
                        name : "2",
                        type : Ossia.Type.Float
                    }
                    ]
                },
                {
                    name : "tool",
                    type : Ossia.Type.Bollean
                },
                {
                    name : "touchDistance",
                    type : Ossia.Type.Float
                },
                {
                    name : "touchZone",
                    type : Ossia.Type.String
                },
                {
                    name : "width",
                    type : Ossia.Type.Float
                }
                ]
            }
            ]
        },
        {
            name : "s",
            type : Ossia.Type.Float
        },
        {
            name : "sphereCenter",
            children : [
            {
                name : "0",
                type : Ossia.Type.Float
            },
            {
                name : "1",
                type : Ossia.Type.Float
            },
            {
                name : "2",
                type : Ossia.Type.Float
            }
            ]
        },
        {
            name : "sphereRadius",
            type : Ossia.Type.Float
        },
        {
            name : "stabilizedPalmPosition",
            children : [
            {
                name : "0",
                type : Ossia.Type.Float
            },
            {
                name : "1",
                type : Ossia.Type.Float
            },
            {
                name : "2",
                type : Ossia.Type.Float
            }
            ]
        },
        {
            name : "t",
            children : [
            {
                name : "0",
                type : Ossia.Type.Float
            },
            {
                name : "1",
                type : Ossia.Type.Float
            },
            {
                name : "2",
                type : Ossia.Type.Float
            }
            ]
        },
        {
            name : "timeVisible",
            type : Ossia.Type.Float
        },
        ]
    }
}
