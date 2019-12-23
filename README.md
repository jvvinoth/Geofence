# Geofence

# Application that will detect if the device is located inside of a geofence area.

Geofence area is defined as a combination of some geographic point, radius, and specific Wifi network name. A device is considered to be inside of the geofence area if the device is connected to the specified WiFi network or remains geographically inside the defined circle.

Note that if device coordinates are reported outside of the zone, but the device still connected to the specific Wifi network, then the device is treated as being inside the geofence area.

Application activity should provide controls to configure the geofence area and display current status: inside OR outside.

=======
- Home page will disaply connected wifi name (From default settings)
- App will allow user to configure their Latitude & Longtitude inside Settings
- As soon user done the configuration, it will start to find the user within region or not. (Now by default set 100 meter from configured coordinates)
- If user connected with Wifi, app will consider user still within this region.
- If user Off/Disconnected from wifi & moved 100 meter away from configured coordinates means, it will tell that "user not in region". 



Notes: 
1. For now connected Wifi getting from default device settings. We can configure specific Wifi inside the app & can detect if connected wifi is same with configured Wifi in app(SSID).
2. For wifi changing observer on real time, your bundle identifier need to be enable some services such as (Access WiFi Information, Wireless Accessory Configuration)
====



