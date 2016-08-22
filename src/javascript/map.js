(function (Elm, mapboxgl) {
  var map;
  var app = Elm.Main.fullscreen();
  setupPorts(app);

  function setupPorts(app) {
    app.ports.map.subscribe(function(mapId) {
        var mapSuccess = setupMap(mapId);
        app.ports.mapCallback.send(mapSuccess);
    });

    app.ports.popup.subscribe(function(popupData) {
      var popupSuccess = addPopup(popupData);
      app.ports.popupCallback.send(popupSuccess);
    });
  }

  function setupMap(mapId) {
    mapboxgl.accessToken = 'pk.eyJ1IjoiY2lhcmFucGhpbGxpcHMiLCJhIjoiY2lyemZkaXRhMDAwZTJ6bHc2emRiOXVjeSJ9.1sxXM4f1RtI5JgGy2_M-Fg';
    map = new mapboxgl.Map({
        container: mapId,
        style: 'mapbox://styles/ciaranphillips/cirzff94i0065gym6r4s5z1u2',
        zoom: 3,
        center: [4.899, 52.372]
    });

    var success  = (typeof map !== 'undefined');
    return success;
  }

  function addPopup(popupData) {
    var x = popupData;
    var popup = new mapboxgl.Popup()
      .setLngLat([popupData[0], popupData[1]])
      .setHTML(popupData[2])
      .addTo(map);
    return (typeof popup !== 'undefined');
  }
})(Elm, mapboxgl);
