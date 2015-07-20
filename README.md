osm-relation-utils
==================

this is (unfinished) proof of concept: 
generate a gpx file for a given openstreetmap relation so that all ways of the relation are traversed.

typical use case is following:
* user would like to have a bicycle trip on [this trail](http://www.openstreetmap.org/relation/2320064#map=12/48.7728/19.6298).

usage:
* run webserver by `ruby run_webserver.rb`
* visit `http://localhost:8080/relation/<id-of-relation>`, e.g. `http://localhost:8080/relation/2320064`
* you will be redirected to static html with generated gpx and map with journey overview

running example [here](http://nabezky.sk:4888/journey-2320064.html)
