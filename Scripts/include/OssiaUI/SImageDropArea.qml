import QtQuick

DropArea {
    id: area
    keys: ["text/uri-list"]

    signal filesDropped(var paths, real x, real y)

    function imagePaths(urls) {
        var paths = [];
        for (var i = 0; i < urls.length; ++i) {
            var url = urls[i].toString();
            if (!/^file:/i.test(url)) continue;
            var path = Util.urlToLocalFile(url);
            if (path && /\.(png|jpe?g|gif|bmp|svgz?|webp)$/i.test(path))
                paths.push(path);
        }
        return paths;
    }

    onEntered: function(drag) { drag.accepted = imagePaths(drag.urls).length > 0; }
    onDropped: function(drop) {
        var paths = imagePaths(drop.urls);
        if (!paths.length) { drop.accepted = false; return; }
        filesDropped(paths, drop.x, drop.y);
        drop.acceptProposedAction();
    }
}
