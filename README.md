# ride_sharing_app
The purpose of Ride_Sharing_App is to help users share their cars with passengers.
<img width="480" alt="Screen Shot 2022-06-04 at 18 02 39" src="https://user-images.githubusercontent.com/52280308/172015178-89c86dab-fbee-4597-8670-c4d995c64fa3.png">

## Description
Map methods were coded with Flutter and Google Maps API.
Places API is used for autocomplete in address search.
Firebase is used for storage, realtime database.

## Features
- 1- The user searches for location which they want to go, the application filters among the all listings which user want to go.
- 2- If there is no listing from feature #1, Application searches routes among all the listings, if searched location in a route, application shows that listing.
- 3- Application filters listings from 2nd feature, orderBy distance ascending from device location.

<img width="480" alt="Screen Shot 2022-06-04 at 18 02 39" src="https://user-images.githubusercontent.com/52280308/172019870-9d2bdffe-e05c-46d8-a1a8-e5d321cc2dff.gif">

- Used Haversine Formula to Calculate Distance Between 2 Locations
- <img width="480" alt="raycast-untitled" src="https://user-images.githubusercontent.com/52280308/172492766-ca72805f-71a5-4c0d-b0ae-d1c0d812f243.png">

## Prerequisites
- keys.xml file on Android > App > src > main > res > values
``` 
  <?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="google_maps_key" translatable="false"    templateMergeStrategy="preserve">
        YOUR_GOOGLE_MAP_API_KEY_HERE
    </string>
</resources>
 ```

- .env file on main directory
```
GOOGLE_API_KEY=YOUR_API_KEY_HERE
```

- google-services.json and GoogleService-Info.plist configuration files from Firebase


## Screenshots
All screenshots from ride_sharing_app

### All Listings
<img width="436" alt="Screen Shot 2022-06-04 at 18 02 09" src="https://user-images.githubusercontent.com/52280308/172015341-fcc69074-42eb-4d89-80c5-52a625b14235.png">

### Autocomplete Search
<img width="480" alt="Screen Shot 2022-06-04 at 18 34 51" src="https://user-images.githubusercontent.com/52280308/172015363-da3acc07-529e-424c-975d-9f8de78f2b2c.png">

### Listings with Search via by Destination Location
<img width="480" alt="Screen Shot 2022-06-04 at 18 35 03" src="https://user-images.githubusercontent.com/52280308/172015389-a58eb76f-ad2f-4dfb-b768-62969fb0fa0c.png">

### Search Listings by Device Location
<img width="480" alt="Screen Shot 2022-06-04 at 18 36 15" src="https://user-images.githubusercontent.com/52280308/172015420-e9a4bda6-2822-443b-97d2-92e9605e902e.png">

### Chat Screen
<img width="404" alt="chat" src="https://user-images.githubusercontent.com/52280308/172015444-5c0dd348-06ff-41f8-811f-4de172505f0e.png">

### Profile Page Screen
<img width="480" alt="Screen Shot 2022-06-04 at 18 36 24" src="https://user-images.githubusercontent.com/52280308/172015454-0dd97898-2492-4c36-89d8-2d7f83111be9.png">