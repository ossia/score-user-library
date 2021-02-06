import Ossia 1.0 as Ossia

/**
 * This example uses the MetaWeather.com API
 * to provide the temperature in Bordeaux or another city
 * (read the doc at https://www.metaweather.com/api/)
 */
Ossia.Http
{
    function createTree() {
        return [
        {
            name: "Cities",
            children: [
                {
                    name: "Bordeaux",
                    type: Ossia.Type.Impulse,
                    request: "https://www.metaweather.com/api/location/580778/",
                    answer: function (json) {
                        console.log(json)
                        var obj = JSON.parse(json)["consolidated_weather"][0];
                        return [
                            { address: "/Cities/Bordeaux/Temperature", value: obj["the_temp"] },
                            { address: "/Cities/Bordeaux/Humidity", value: obj["humidity"] },
                            { address: "/Cities/Bordeaux/Wind", value: obj["wind_speed"] }
                        ];
                    },
                    children: [
                        {
                            name: "Temperature",
                            type: Ossia.Type.Float,
                            value: 20
                        },
                        {
                            name: "Humidity",
                            type: Ossia.Type.Float,
                            value: 50
                        },
                        {
                            name: "Wind",
                            type: Ossia.Type.Float,
                            value: 4
                        }
                    ]
                },
                {
                    name: "Custom",
                    type: Ossia.Type.Int,
                    value: 615702, // Paris
                    request: "https://www.metaweather.com/api/location/$val/",
                    answer: function (json) {
                        console.log(json)
                        var obj = JSON.parse(json)["consolidated_weather"][0];
                        return [
                            { address: "/Cities/Custom/Temperature", value: obj["the_temp"] },
                            { address: "/Cities/Custom/Humidity", value: obj["humidity"] },
                            { address: "/Cities/Custom/Wind", value: obj["wind_speed"] }
                        ];
                    },
                    children: [
                        {
                            name: "Temperature",
                            type: Ossia.Type.Float,
                            value: 20
                        },
                        {
                            name: "Humidity",
                            type: Ossia.Type.Float,
                            value: 50
                        },
                        {
                            name: "Wind",
                            type: Ossia.Type.Float,
                            value: 4
                        }
                    ]
                }
            ]
        }
        ];
    }

    function openListening(address) {

    }

    function closeListening(address) {

    }

}
