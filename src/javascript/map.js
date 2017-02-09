
(function (Elm, mapboxgl) {
    var map;
    var flags = {
        currentMonth : getYearAndMonth()
    };
    var app = Elm.Main.fullscreen(flags);
    var popups = [];
    setupPorts(app);

    function setupPorts(app) {
        app.ports.map.subscribe(function (mapId) {
            var mapSuccess = setupMap(mapId);
            app.ports.mapCallback.send(mapSuccess);


            var map = document.getElementById('map');
            map.addEventListener('click', function (e) {
                if (e.target) {
                    var id = getAirportCode(e.target);
                    if (id) {
                        app.ports.popupSelected.send(id);
                    }
                }
            });
        });

        app.ports.clearPopups.subscribe(clearPopups);

        app.ports.popup.subscribe(function (popupData) {
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

        var success = (typeof map !== 'undefined');
        return success;
    }

    function clearPopups() {
        const len = popups.length;
        for (let i = 0; i < len; i++) {
            popups[i].remove();
        }
        popups = [];
    }

    function addPopup(popupData) {
        var x = popupData;
        const options = {
            closeOnClick : false
        };
        var popup = new mapboxgl.Popup(options)
            .setLngLat([popupData[1], popupData[2]])
            .setHTML('<div class="js-popup" data-airport-code="' + popupData[0] + '">' + popupData[3] + '</div>')
            .addTo(map);
        popups.push(popup);
        return (typeof popup !== 'undefined');
    }

    function getAirportCode(elem) {
        const airportAttr = 'data-airport-code';
        const elemClass = elem.getAttribute('class');
        let id = null;
        if (elemClass === 'js-popup') {
            id = elem.getAttribute(airportAttr);
        }
        else if (elemClass === 'mapboxgl-popup-content') {
            id = getIdFromContentDiv(elem, airportAttr);
        }
        else if (elemClass == 'mapboxgl-popup-tip') {
            const contentDiv = elem.nextSibling();
            if (contentDiv) {
                id = getIdFromContentDiv(contentDiv)
            }
        }
        return id;

        function getIdFromContentDiv(elem, attr) {
            let id = null;
            var children = elem.children;
            for (let i = 0; i < children.length; i++) {
                if (children[i].getAttribute('class') == 'js-popup') {
                    id = children[i].getAttribute(attr);
                }
            }
            return id;
        }
    }

    function getYearAndMonth() {
        let date = new Date();
        let res = "";
        res += date.getYear() + 1900;
        res += "-";

        let month = date.getMonth() + 1;
        if (month < 10) {
            month = "" + "0" + month;
        }
        return res + month;
    }
})(Elm, mapboxgl);
