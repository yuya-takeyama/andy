#!/bin/sh
lessc ./vendor/bootstrap/less/bootstrap.less > public/css/bootstrap.css
lessc ./vendor/bootstrap/less/responsive.less > public/css/bootstrap-responsive.css
cat ./vendor/bootstrap/js/bootstrap-{transition,alert,button,carousel,collapse,dropdown,modal,tooltip,popover,scrollspy,tab,typeahead}.js > public/js/bootstrap.js
