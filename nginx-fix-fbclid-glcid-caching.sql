### fix fbclid/glcid added to uri -> 301 redirect - inside each server block ###
# remove GET parameters:
if ($args ~* (.*)fbclid|gclid=[^&]*(.*)) {
set $args $1$2;
set $removearg "removearg";
}
# cleanup any repeated & introduced:
if ($args ~ (.*)&&+(.*)) {
set $args $1&$2;
}
# cleanup leading &
if ($args ~ ^&(.*)) {
set $args $1;
}
# cleanup ending &
if ($args ~ (.*)&$) {
set $args $1;
}
if ( $removearg = "removearg" ) {
rewrite ^(.*)$ $uri permanent;
}