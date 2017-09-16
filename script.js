'use strict';

/**
 * Get Header path and title element
 */
var header = document.querySelector('header > span.path');
var title  = document.querySelector('title');

/**
 * Set Title and Header on pageload
 */
if (window.location.hash != '') {
    var subpath = document.querySelector(window.location.hash).getAttribute('data-subpath');

    header.innerHTML = subpath;
    title.innerHTML = title.getAttribute('data-basepath') + subpath;
}

/**
 * Get all links and loop them
 */
var links = document.querySelectorAll('a');
for (var i = 0; i < links.length; i++) {
    // Only care about local links
    if (links[i].getAttribute('href')[0] == '#') {
        // Add click-event
        links[i].onclick = function(e) {
            if (e.target.hash == undefined || e.target.hash == '') {
                // Links to startpage
                var subpath = document.querySelector('#start').getAttribute('data-subpath');
            } else {
                // links to other pages
                var subpath = document.querySelector(e.target.hash).getAttribute('data-subpath');
            }

            // Set data
            header.innerHTML = subpath;
            title.innerHTML = title.getAttribute('data-basepath') + subpath;
        }
    }
}
