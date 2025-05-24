import Ossia 1.0 as Ossia

/**
* This script uses the World Air Quality Index (WAQI) API
* to provide air quality data for a specific Seoul station (@5508)
* and allows for querying custom station IDs.
* (API Docs: https://aqicn.org/json-api/doc/)
*/
Ossia.Http
{
// IMPORTANT: Replace with your own token.
// Register here: https://aqicn.org/data-platform/token/
property string token: "0000000000000000000000000000000000000"

  /**
  * Safely retrieves a value from the nested iaqi object.
  * @param iaqi - The 'iaqi' object from the API response.
  * @param key - The key for the desired pollutant (e.g., "pm25").
  * @returns The value if found, otherwise 0.
  */
  function getIaqiValue(iaqi, key)
  {
    return (iaqi && iaqi[key] && iaqi[key].hasOwnProperty("v")) ? iaqi[key]["v"] : 0;
  }

  /**
  * Parses the JSON response and returns an array of updates
  * for the Ossia device tree.
  * @param json - The JSON string response from the API.
  * @param basePath - The base address path in the Ossia tree (e.g., "/AirQuality/Seoul").
  * @returns An array of objects to update Ossia parameters.
  */
  function parseApiResponse(json, basePath)
  {
    try {
      var response = JSON.parse(json);
      console.log("API Response for " + basePath + ": " + json);

      if (response["status"] === "ok" && response["data"])
      {
        var data = response["data"];
        var iaqi = data["iaqi"];

        return [
        { address: basePath + "/AQI", value: data["aqi"] || 0 },
        { address: basePath + "/DominantPollutant", value: data["dominentpol"] || "N/A" },
        { address: basePath + "/PM25", value: getIaqiValue(iaqi, "pm25") },
        { address: basePath + "/PM10", value: getIaqiValue(iaqi, "pm10") },
        { address: basePath + "/O3", value: getIaqiValue(iaqi, "o3") },
        { address: basePath + "/NO2", value: getIaqiValue(iaqi, "no2") },
        { address: basePath + "/SO2", value: getIaqiValue(iaqi, "so2") },
        { address: basePath + "/CO", value: getIaqiValue(iaqi, "co") },
        { address: basePath + "/Temperature", value: getIaqiValue(iaqi, "t") },
        { address: basePath + "/Pressure", value: getIaqiValue(iaqi, "p") },
        { address: basePath + "/Humidity", value: getIaqiValue(iaqi, "h") },
        { address: basePath + "/Wind", value: getIaqiValue(iaqi, "w") }
          ];
        } else {
        console.log("API Error or no data for " + basePath + ": " + (response["data"] || "Unknown error"));
        return [];
      }
    } catch (e) {
    console.log("JSON Parsing Error for " + basePath + ": " + e);
    return [];
  }
}

/**
* Creates the node structure for the Ossia device.
*/
function createTree()
{
  return [
  {
      name: "Station",
      type: Ossia.Type.Int,
      value: 5508, // Default to Seoul Station @5508
      request: "https://api.waqi.info/feed/@$val/?token=" + token,
      answer: function (json) {
        return parseApiResponse(json, "/AirQuality/CustomStation");
      },
      children: [
      { name: "AQI", type: Ossia.Type.Int, value: 0 },
      { name: "DominantPollutant", type: Ossia.Type.String, value: "N/A" },
      { name: "PM25", type: Ossia.Type.Float, value: 0 },
      { name: "PM10", type: Ossia.Type.Float, value: 0 },
      { name: "O3", type: Ossia.Type.Float, value: 0 },
      { name: "NO2", type: Ossia.Type.Float, value: 0 },
      { name: "SO2", type: Ossia.Type.Float, value: 0 },
      { name: "CO", type: Ossia.Type.Float, value: 0 },
      { name: "Temperature", type: Ossia.Type.Float, value: 0 },
      { name: "Pressure", type: Ossia.Type.Float, value: 0 },
      { name: "Humidity", type: Ossia.Type.Float, value: 0 },
      { name: "Wind", type: Ossia.Type.Float, value: 0 }
      ]
    }
  ];
}

}