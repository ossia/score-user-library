import Ossia 1.0 as Ossia

Ossia.Mapper
{
  function createTree() {
    return [
      {
        name: "hours",
        type: Ossia.Type.Int,
        interval: 1000, // The read function() will be called every 1000 millisecond (every second)
        read: function() {
          return new Date().getHours();
        }
      },
      {
        name: "minutes",
        type: Ossia.Type.Int,
        interval: 1000,
        read: function() {
          return new Date().getMinutes();
        }
      },
      {
        name: "seconds",
        type: Ossia.Type.Int,
        interval: 200,
        read: function() {
          return new Date().getSeconds();
        }
      }
    ];
  }
}
